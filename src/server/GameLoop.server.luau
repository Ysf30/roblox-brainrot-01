-- GameLoop: Main server game loop, handles shop, stealing, and network callbacks

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local GameConfig = require(game:GetService("ReplicatedStorage").Shared.GameConfig)
local BrainrotData = require(game:GetService("ReplicatedStorage").Shared.BrainrotData)
local PlayerData = require(game:GetService("ReplicatedStorage").Shared.PlayerData)
local Network = require(game:GetService("ReplicatedStorage").Shared.Network)
local Utility = require(game:GetService("ReplicatedStorage").Shared.Utility)

local DataManager = require(script.Parent.DataManager)
local WorldManager = require(script.Parent.WorldManager)

local GameLoop = {}

-- Initialize game loop
function GameLoop.Initialize()
	-- Initialize network
	Network.Initialize()

	-- Initialize data manager
	DataManager.Initialize()

	-- Make DataManager globally accessible for WorldManager
	_G.DataManager = DataManager
	_G.PlayerDataCache = {}

	-- Initialize world
	WorldManager.Initialize()

	-- Set up network callbacks
	GameLoop.SetupNetworkCallbacks()

	-- Handle player character loading
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAppearanceLoaded:Connect(function(character)
			GameLoop.OnCharacterLoaded(player, character)
		end)
	end)

	-- Periodic shop refresh for all players
	task.spawn(function()
		while true do
			task.wait(60) -- Refresh shop every minute
			for _, player in ipairs(Players:GetPlayers()) do
				local offers = WorldManager.GenerateShopOffers(player)
				Network.FireClient(player, "ShopOffersUpdated", offers)
			end
		end
	end)

	print("[GameLoop] Initialized")
end

-- Called when player's character loads
function GameLoop.OnCharacterLoaded(player: Player, character: Model)
	-- Set up humanoid
	local humanoid = character:WaitForChild("Humanoid")

	-- Prevent default death behavior (we handle waves)
	humanoid.BreakJointsOnDeath = false

	-- Teleport to base
	local rootPart = character:WaitForChild("HumanoidRootPart")
	rootPart.CFrame = CFrame.new(0, 5, 0)

	-- Give starter brainrot if new player
	local data = DataManager.GetPlayerData(player)
	if data and #data.brainrots == 0 and #data.inventory == 0 then
		-- Give a starter common brainrot
		DataManager.AddBrainrot(player, "skibidi_toilet", "None", Vector3.new(-6, 0, -6))
		DataManager.AddBrainrot(player, "ohio_rizzler", "None", Vector3.new(6, 0, -6))
	end

	-- Generate initial shop offers
	local offers = WorldManager.GenerateShopOffers(player)
	Network.FireClient(player, "ShopOffersUpdated", offers)
end

-- Set up all network callbacks
function GameLoop.SetupNetworkCallbacks()
	-- Shop reroll
	Network.OnServerInvoke("RequestShopReroll", function(player)
		return GameLoop.HandleShopReroll(player)
	end)

	-- Purchase brainrot from shop
	Network.OnServerInvoke("RequestPurchaseBrainrot", function(player, offerIndex: number)
		return GameLoop.HandlePurchaseBrainrot(player, offerIndex)
	end)

	-- Place brainrot on base
	Network.OnServerInvoke("RequestPlaceBrainrot", function(player, brainrotId: string, mutation: string, gridX: number, gridZ: number)
		return GameLoop.HandlePlaceBrainrot(player, brainrotId, mutation, gridX, gridZ)
	end)

	-- Remove brainrot from base
	Network.OnServerInvoke("RequestRemoveBrainrot", function(player, index: number)
		return GameLoop.HandleRemoveBrainrot(player, index)
	end)

	-- Purchase upgrade
	Network.OnServerInvoke("RequestUpgrade", function(player, upgradeName: string)
		return DataManager.PurchaseUpgrade(player, upgradeName)
	end)

	-- Rebirth
	Network.OnServerInvoke("RequestRebirth", function(player)
		return DataManager.ProcessRebirth(player)
	end)

	-- Steal attempt
	Network.OnServerInvoke("RequestSteal", function(player, victimName: string, brainrotIndex: number)
		return GameLoop.HandleSteal(player, victimName, brainrotIndex)
	end)

	-- Collect all money (instant collect)
	Network.OnServerInvoke("RequestCollectAll", function(player)
		return GameLoop.HandleCollectAll(player)
	end)
end

-- Handle shop reroll
function GameLoop.HandleShopReroll(player: Player): {success: boolean, offers: {table}?, message: string}
	local data = DataManager.GetPlayerData(player)
	if not data then return { success = false, message = "Data not loaded" } end

	local now = os.time()

	-- Check free rerolls
	if data.freeRerolls > 0 then
		data.freeRerolls -= 1
		data.lastRerollTime = now
		data.shopRerollsUsed += 1

		local offers = WorldManager.GenerateShopOffers(player)
		Network.FireClient(player, "ShopRerolled", offers)
		return { success = true, offers = offers }
	end

	-- Check cooldown
	if now - data.lastRerollTime < GameConfig.Shop.RerollCooldown then
		return { success = false, message = "Reroll on cooldown" }
	end

	-- Check cost
	if not DataManager.SpendMoney(player, GameConfig.Shop.RerollCost) then
		return { success = false, message = "Not enough money" }
	end

	data.lastRerollTime = now
	data.shopRerollsUsed += 1

	local offers = WorldManager.GenerateShopOffers(player)
	Network.FireClient(player, "ShopRerolled", offers)
	return { success = true, offers = offers }
end

-- Handle brainrot purchase from shop
function GameLoop.HandlePurchaseBrainrot(player: Player, offerIndex: number): {success: boolean, brainrot: table?, message: string}
	local data = DataManager.GetPlayerData(player)
	if not data then return { success = false, message = "Data not loaded" } end

	if offerIndex < 1 or offerIndex > #data.shopOffers then
		return { success = false, message = "Invalid offer" }
	end

	local offer = data.shopOffers[offerIndex]
	local brainrotInfo = BrainrotData.GetBrainrot(offer.id)
	if not brainrotInfo then return { success = false, message = "Invalid brainrot" } end

	-- Calculate price based on rarity and mutation
	local basePrice = brainrotInfo.baseMoneyPerSec * 100
	local rarityMultiplier = BrainrotData.GetRarity(brainrotInfo.rarity).moneyMultiplier
	local mutationMultiplier = BrainrotData.GetMutation(offer.mutation).multiplier
	local price = math.floor(basePrice * rarityMultiplier * mutationMultiplier)

	-- Apply rebirth discount
	local rebirthDiscount = 1 - (data.rebirths * 0.05) -- 5% per rebirth
	price = math.floor(price * math.max(0.3, rebirthDiscount))

	if not DataManager.SpendMoney(player, price) then
		return { success = false, message = "Not enough money (" .. Utility.FormatNumber(price) .. " needed)" }
	end

	-- Add to inventory
	local brainrot = {
		id = offer.id,
		mutation = offer.mutation,
	}
	table.insert(data.inventory, brainrot)

	Network.FireClient(player, "ShopPurchaseResult", true, brainrot, price)
	return { success = true, brainrot = brainrot, message = "Purchased for " .. Utility.FormatNumber(price) }
end

-- Handle placing brainrot on base
function GameLoop.HandlePlaceBrainrot(player: Player, brainrotId: string, mutation: string, gridX: number, gridZ: number): {success: boolean, message: string}
	local data = DataManager.GetPlayerData(player)
	if not data then return { success = false, message = "Data not loaded" } end

	-- Find brainrot in inventory
	local invIndex = nil
	for i, b in ipairs(data.inventory) do
		if b.id == brainrotId and b.mutation == mutation then
			invIndex = i
			break
		end
	end

	if not invIndex then
		return { success = false, message = "Brainrot not in inventory" }
	end

	-- Check base capacity
	if #data.brainrots >= GameConfig.BasePlot.MaxBrainrots then
		return { success = false, message = "Base is full" }
	end

	-- Check grid bounds
	local gridSize = data.baseGridSize or GameConfig.BasePlot.GridSize
	if gridX < 0 or gridX >= gridSize or gridZ < 0 or gridZ >= gridSize then
		return { success = false, message = "Invalid grid position" }
	end

	-- Check if position occupied
	local cellSize = GameConfig.BasePlot.CellSize
	local basePos = GameConfig.BasePlot.Position
	local worldPos = Vector3.new(
		basePos.X - GameConfig.BasePlot.Size.X/2 + gridX * cellSize + cellSize/2,
		basePos.Y + 2,
		basePos.Z - GameConfig.BasePlot.Size.Z/2 + gridZ * cellSize + cellSize/2
	)

	for _, existing in ipairs(data.brainrots) do
		local existingGridX = math.floor((existing.position.X - (basePos.X - GameConfig.BasePlot.Size.X/2)) / cellSize)
		local existingGridZ = math.floor((existing.position.Z - (basePos.Z - GameConfig.BasePlot.Size.Z/2)) / cellSize)
		if existingGridX == gridX and existingGridZ == gridZ then
			return { success = false, message = "Position occupied" }
		end
	end

	-- Remove from inventory
	local brainrot = table.remove(data.inventory, invIndex)

	-- Add to base
	brainrot.position = worldPos
	brainrot.placedTime = os.time()
	table.insert(data.brainrots, brainrot)
	data.stats.brainrotsCollected += 1

	DataManager.UpdatePlayerData(player, { brainrots = data.brainrots, inventory = data.inventory })

	Network.FireClient(player, "BrainrotPlaced", brainrot)
	Network.FireClient(player, "MoneyPerSecChanged", PlayerData.CalculateMoneyPerSec(data))

	return { success = true, message = "Placed on base!" }
end

-- Handle removing brainrot from base
function GameLoop.HandleRemoveBrainrot(player: Player, index: number): {success: boolean, brainrot: table?, message: string}
	local data = DataManager.GetPlayerData(player)
	if not data then return { success = false, message = "Data not loaded" } end

	if index < 1 or index > #data.brainrots then
		return { success = false, message = "Invalid index" }
	end

	local brainrot = table.remove(data.brainrots, index)
	data.stats.brainrotsLost += 1

	-- Add back to inventory
	table.insert(data.inventory, { id = brainrot.id, mutation = brainrot.mutation })

	DataManager.UpdatePlayerData(player, { brainrots = data.brainrots, inventory = data.inventory })

	Network.FireClient(player, "BrainrotRemoved", index)
	Network.FireClient(player, "MoneyPerSecChanged", PlayerData.CalculateMoneyPerSec(data))

	return { success = true, brainrot = brainrot, message = "Returned to inventory" }
end

-- Handle steal attempt
function GameLoop.HandleSteal(player: Player, victimName: string, brainrotIndex: number): {success: boolean, brainrot: table?, message: string}
	local victim = Players:FindFirstChild(victimName)
	if not victim then
		return { success = false, message = "Victim not found" }
	end

	if victim == player then
		return { success = false, message = "Cannot steal from yourself" }
	end

	return DataManager.AttemptSteal(player, victim, brainrotIndex)
end

-- Handle collect all (instant money tick)
function GameLoop.HandleCollectAll(player: Player): {success: boolean, amount: number, message: string}
	local data = DataManager.GetPlayerData(player)
	if not data then return { success = false, amount = 0, message = "Data not loaded" } end

	local moneyPerSec = PlayerData.CalculateMoneyPerSec(data)
	local amount = moneyPerSec * 10 -- Collect 10 seconds worth instantly

	if amount <= 0 then
		return { success = false, amount = 0, message = "No brainrots generating money" }
	end

	DataManager.AddMoney(player, amount)

	return { success = true, amount = amount, message = "Collected " .. Utility.FormatNumber(amount) .. "!" }
end

-- Admin commands
Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		if not GameConfig.Admin.TestMode then return end

		local args = string.split(message, " ")
		local cmd = args[1]:lower()

		if cmd == GameConfig.Admin.GiveMoneyCommand then
			local amount = tonumber(args[2]) or 10000
			DataManager.AddMoney(player, amount)
		elseif cmd == GameConfig.Admin.GiveBrainrotCommand then
			local brainrotId = args[2] or "skibidi_toilet"
			local mutation = args[3] or "None"
			DataManager.AddBrainrot(player, brainrotId, mutation)
		elseif cmd == GameConfig.Admin.SetRebirthCommand then
			local rebirths = tonumber(args[2]) or 1
			local data = DataManager.GetPlayerData(player)
			if data then
				data.rebirths = math.clamp(rebirths, 0, GameConfig.Rebirth.MaxRebirths)
				PlayerData.ApplyRebirthBonuses(data)
				Network.FireClient(player, "PlayerDataLoaded", data)
			end
		end
	end)
end)

return GameLoop