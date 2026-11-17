-- DataManager: Handles player data loading, saving, and DataStore operations

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local GameConfig = require(game:GetService("ReplicatedStorage").Shared.GameConfig)
local PlayerData = require(game:GetService("ReplicatedStorage").Shared.PlayerData)
local Network = require(game:GetService("ReplicatedStorage").Shared.Network)
local Utility = require(game:GetService("ReplicatedStorage").Shared.Utility)

local DataManager = {}

-- DataStore
local dataStore = DataStoreService:GetDataStore(GameConfig.Save.DataStoreName)
local backupStore = DataStoreService:GetDataStore(GameConfig.Save.DataStoreName .. "_Backup")

-- In-memory player data cache
local playerDataCache = {}
local dirtyPlayers = {}

-- Auto-save interval
local AUTO_SAVE_INTERVAL = GameConfig.Save.AutoSaveInterval

-- Initialize DataManager
function DataManager.Initialize()
	-- Set up auto-save
	task.spawn(function()
		while true do
			task.wait(AUTO_SAVE_INTERVAL)
			DataManager.SaveAllPlayers()
		end
	end)

	-- Handle player joining
	Players.PlayerAdded:Connect(function(player)
		DataManager.LoadPlayerData(player)
	end)

	-- Handle player leaving
	Players.PlayerRemoving:Connect(function(player)
		DataManager.SavePlayerData(player)
		playerDataCache[player] = nil
		dirtyPlayers[player] = nil
	end)

	-- Handle game closing
	game:BindToClose(function()
		DataManager.SaveAllPlayers()
		task.wait(2) -- Give time for saves to complete
	end)

	-- Set up network functions
	Network.OnServerInvoke("RequestPlayerData", function(player)
		return DataManager.GetPlayerData(player)
	end)

	Network.OnServerInvoke("RequestOfflineProgress", function(player)
		return DataManager.CalculateAndApplyOfflineProgress(player)
	end)

	print("[DataManager] Initialized")
end

-- Load player data from DataStore
function DataManager.LoadPlayerData(player: Player)
	local userId = player.UserId
	local key = "Player_" .. userId

	local success, data = pcall(function()
		return dataStore:GetAsync(key)
	end)

	if success and data then
		-- Validate and sanitize loaded data
		data = PlayerData.Validate(data)
		playerDataCache[player] = data
		print("[DataManager] Loaded data for " .. player.Name)
	else
		-- New player or load failed - use defaults
		local defaultData = PlayerData.GetDefault()
		defaultData.joinTime = os.time()
		playerDataCache[player] = defaultData
		print("[DataManager] Created new data for " .. player.Name)
	end

	-- Apply rebirth bonuses to mutation chances
	PlayerData.ApplyRebirthBonuses(playerDataCache[player])

	-- Calculate and apply offline progress
	task.spawn(function()
		task.wait(1) -- Wait for other systems to initialize
		DataManager.CalculateAndApplyOfflineProgress(player)
	end)

	-- Send data to client
	Network.FireClient(player, "PlayerDataLoaded", playerDataCache[player])

	-- Set up periodic money tick for this player
	DataManager.StartMoneyTick(player)
end

-- Get player data (from cache)
function DataManager.GetPlayerData(player: Player): table?
	return playerDataCache[player]
end

-- Update player data and mark as dirty
function DataManager.UpdatePlayerData(player: Player, updates: table)
	local data = playerDataCache[player]
	if not data then return false end

	for key, value in pairs(updates) do
		data[key] = value
	end

	dirtyPlayers[player] = true
	return true
end

-- Add money to player
function DataManager.AddMoney(player: Player, amount: number): number
	local data = playerDataCache[player]
	if not data then return 0 end

	amount = math.floor(math.max(0, amount))
	data.money += amount
	data.totalMoneyEarned += amount

	dirtyPlayers[player] = true

	Network.FireClient(player, "MoneyChanged", data.money)
	Network.FireClient(player, "MoneyPerSecChanged", PlayerData.CalculateMoneyPerSec(data))

	return data.money
end

-- Spend money (returns success)
function DataManager.SpendMoney(player: Player, amount: number): boolean
	local data = playerDataCache[player]
	if not data then return false end

	amount = math.floor(math.max(0, amount))

	if data.money >= amount then
		data.money -= amount
		dirtyPlayers[player] = true

		Network.FireClient(player, "MoneyChanged", data.money)
		return true
	end

	return false
end

-- Start money tick for a player
function DataManager.StartMoneyTick(player: Player)
	task.spawn(function()
		while player and player.Parent do
			task.wait(GameConfig.Money.TickInterval)

			local data = playerDataCache[player]
			if data then
				local moneyPerSec = PlayerData.CalculateMoneyPerSec(data)
				if moneyPerSec > 0 then
					DataManager.AddMoney(player, moneyPerSec * GameConfig.Money.TickInterval)

					-- Update highest money per sec stat
					if moneyPerSec > (data.stats.highestMoneyPerSec or 0) then
						data.stats.highestMoneyPerSec = moneyPerSec
					end
				end

				-- Update play time
				data.stats.playTime += GameConfig.Money.TickInterval
			else
				break
			end
		end
	end)
end

-- Calculate and apply offline progress
function DataManager.CalculateAndApplyOfflineProgress(player: Player): number
	local data = playerDataCache[player]
	if not data then return 0 end

	local offlineMoney = PlayerData.CalculateOfflineProgress(data)

	if offlineMoney > 0 then
		data.money += offlineMoney
		data.totalMoneyEarned += offlineMoney
		dirtyPlayers[player] = true

		Network.FireClient(player, "MoneyChanged", data.money)
		Network.FireClient(player, "ShowNotification", "Welcome back! You earned " .. Utility.FormatNumber(offlineMoney) .. " while away!", 5)
	end

	data.lastOnlineTime = os.time()
	return offlineMoney
end

-- Save single player's data
function DataManager.SavePlayerData(player: Player): boolean
	local data = playerDataCache[player]
	if not data then return false end

	-- Only save if dirty
	if not dirtyPlayers[player] then return true end

	local userId = player.UserId
	local key = "Player_" .. userId
	local serialized = PlayerData.Serialize(data)

	local success, err = pcall(function()
		dataStore:SetAsync(key, serialized)
	end)

	if success then
		dirtyPlayers[player] = nil
		data.lastSaveTime = os.time()

		-- Backup save
		if GameConfig.Save.BackupEnabled then
			pcall(function()
				backupStore:SetAsync(key .. "_backup", serialized)
			end)
		end

		print("[DataManager] Saved data for " .. player.Name)
		return true
	else
		warn("[DataManager] Failed to save data for " .. player.Name .. ": " .. tostring(err))
		return false
	end
end

-- Save all players' data
function DataManager.SaveAllPlayers()
	for player, _ in pairs(playerDataCache) do
		if dirtyPlayers[player] then
			DataManager.SavePlayerData(player)
		end
	end
end

-- Add brainrot to player's collection
function DataManager.AddBrainrot(player: Player, brainrotId: string, mutation: string?, position: Vector3?): boolean
	local data = playerDataCache[player]
	if not data then return false end

	local brainrot = {
		id = brainrotId,
		mutation = mutation or "None",
		position = position or Vector3.new(0, 0, 0),
		placedTime = os.time(),
	}

	table.insert(data.brainrots, brainrot)
	data.stats.brainrotsCollected += 1

	dirtyPlayers[player] = true

	Network.FireClient(player, "BrainrotPlaced", brainrot)
	Network.FireClient(player, "MoneyPerSecChanged", PlayerData.CalculateMoneyPerSec(data))

	return true
end

-- Remove brainrot from player's base
function DataManager.RemoveBrainrot(player: Player, index: number): table?
	local data = playerDataCache[player]
	if not data then return nil end

	if index < 1 or index > #data.brainrots then return nil end

	local brainrot = table.remove(data.brainrots, index)
	data.stats.brainrotsLost += 1

	dirtyPlayers[player] = true

	Network.FireClient(player, "BrainrotRemoved", index)
	Network.FireClient(player, "MoneyPerSecChanged", PlayerData.CalculateMoneyPerSec(data))

	return brainrot
end

-- Move brainrot to new position
function DataManager.MoveBrainrot(player: Player, index: number, newPosition: Vector3): boolean
	local data = playerDataCache[player]
	if not data then return false end

	if index < 1 or index > #data.brainrots then return false end

	data.brainrots[index].position = newPosition
	dirtyPlayers[player] = true

	Network.FireClient(player, "BrainrotMoved", index, newPosition)
	return true
end

-- Purchase upgrade
function DataManager.PurchaseUpgrade(player: Player, upgradeName: string): boolean
	local data = playerDataCache[player]
	if not data then return false end

	local upgradeConfig = GameConfig.Upgrades[upgradeName]
	if not upgradeConfig then return false end

	local currentLevel = data.upgrades[upgradeName] or 0
	if currentLevel >= upgradeConfig.maxLevel then return false end

	-- Calculate cost
	local cost = math.floor(upgradeConfig.baseCost * (upgradeConfig.costMultiplier ^ currentLevel))

	if not DataManager.SpendMoney(player, cost) then return false end

	data.upgrades[upgradeName] = currentLevel + 1
	dirtyPlayers[player] = true

	Network.FireClient(player, "UpgradePurchased", upgradeName, data.upgrades[upgradeName])

	-- Special handling for certain upgrades
	if upgradeName == "BaseSize" then
		data.baseGridSize = GameConfig.BasePlot.GridSize + (data.upgrades.BaseSize * GameConfig.Upgrades.BaseSize.cellIncreasePerLevel)
		Network.FireClient(player, "BaseExpanded", data.baseGridSize)
	elseif upgradeName == "BaseDefense" then
		data.baseDefenseLevel = data.upgrades.BaseDefense
		Network.FireClient(player, "BaseDefenseChanged", data.baseDefenseLevel)
	elseif upgradeName == "MoneyMultiplier" then
		Network.FireClient(player, "MoneyPerSecChanged", PlayerData.CalculateMoneyPerSec(data))
	end

	return true
end

-- Process rebirth
function DataManager.ProcessRebirth(player: Player): boolean
	local data = playerDataCache[player]
	if not data then return false end

	-- Check requirements
	local nextRebirth = data.rebirths + 1
	local requirement = nil
	for _, req in ipairs(GameConfig.Rebirth.Requirements) do
		if req.rebirth == nextRebirth then
			requirement = req
			break
		end
	end

	if not requirement then return false end

	if data.totalMoneyEarned < requirement.money then return false end

	-- Count unique brainrots owned
	local uniqueBrainrots = {}
	for _, b in ipairs(data.brainrots) do uniqueBrainrots[b.id] = true end
	for _, b in ipairs(data.inventory) do uniqueBrainrots[b.id] = true end

	if Utility.TableLength(uniqueBrainrots) < requirement.brainrots then return false end

	-- Apply rebirth
	data.rebirths = nextRebirth

	-- Reset money but give starting bonus
	local startingMoney = GameConfig.Money.StartingMoney * (GameConfig.Rebirth.Rewards.startingMoneyMultiplier ^ nextRebirth)
	data.money = math.floor(startingMoney)
	data.totalMoneyEarned = 0

	-- Reset brainrots (keep inventory? No, full reset for prestige)
	data.brainrots = {}
	data.inventory = {}

	-- Reset upgrades (or keep some? Full reset)
	for upgradeName in pairs(data.upgrades) do
		data.upgrades[upgradeName] = 0
	end
	data.baseLevel = 1
	data.baseGridSize = GameConfig.BasePlot.GridSize
	data.baseDefenseLevel = 0

	-- Reset shop
	data.shopOffers = {}
	data.shopRerollsUsed = 0
	data.lastRerollTime = 0

	-- Apply rebirth bonuses
	PlayerData.ApplyRebirthBonuses(data)

	dirtyPlayers[player] = true

	Network.FireClient(player, "RebirthCompleted", data.rebirths)
	Network.FireClient(player, "PlayerDataLoaded", data)
	Network.FireClient(player, "ShowNotification", "Rebirth " .. nextRebirth .. " achieved! +" .. (GameConfig.Rebirth.Rewards.moneyMultiplier * 100) .. "% money multiplier!", 5)

	return true
end

-- Handle steal attempt
function DataManager.AttemptSteal(thief: Player, victim: Player, brainrotIndex: number): {success: boolean, brainrot: table?, message: string}
	local thiefData = playerDataCache[thief]
	local victimData = playerDataCache[victim]

	if not thiefData or not victimData then
		return { success = false, message = "Player data not loaded" }
	end

	-- Check cooldown
	local now = os.time()
	if thiefData.lastStealAttempt and now - thiefData.lastStealAttempt < GameConfig.Money.StealCooldown then
		return { success = false, message = "Steal on cooldown" }
	end

	thiefData.lastStealAttempt = now
	thiefData.stats.totalStealAttempts += 1

	-- Validate brainrot index
	if brainrotIndex < 1 or brainrotIndex > #victimData.brainrots then
		return { success = false, message = "Invalid brainrot" }
	end

	local targetBrainrot = victimData.brainrots[brainrotIndex]
	local stealChance = GameConfig.Money.StealSuccessBaseChance

	-- Apply thief's steal power upgrade
	local stealPowerLevel = thiefData.upgrades.StealPower or 0
	stealChance += stealPowerLevel * GameConfig.Upgrades.StealPower.chanceIncreasePerLevel

	-- Apply victim's defense
	local defenseLevel = victimData.baseDefenseLevel or 0
	stealChance -= defenseLevel * GameConfig.Upgrades.BaseDefense.stealResistancePerLevel

	-- Apply brainrot's rarity steal chance
	local BrainrotData = require(game:GetService("ReplicatedStorage").Shared.BrainrotData)
	stealChance -= BrainrotData.GetStealChance(targetBrainrot.id)

	stealChance = math.clamp(stealChance, 0.01, 0.95)

	local success = math.random() < stealChance

	if success then
		-- Remove from victim
		local stolen = table.remove(victimData.brainrots, brainrotIndex)
		victimData.stats.brainrotsLost += 1

		-- Add to thief
		stolen.placedTime = os.time()
		table.insert(thiefData.brainrots, stolen)
		thiefData.stats.brainrotsStolen += 1
		thiefData.stats.successfulSteals += 1

		dirtyPlayers[thief] = true
		dirtyPlayers[victim] = true

		Network.FireClient(thief, "StealResult", true, stolen)
		Network.FireClient(victim, "PlayerStolenFrom", thief.Name, stolen.id)
		Network.FireClient(thief, "MoneyPerSecChanged", PlayerData.CalculateMoneyPerSec(thiefData))
		Network.FireClient(victim, "MoneyPerSecChanged", PlayerData.CalculateMoneyPerSec(victimData))

		return { success = true, brainrot = stolen, message = "Stolen " .. stolen.id .. "!" }
	else
		Network.FireClient(thief, "StealResult", false, nil)
		Network.FireClient(victim, "ShowNotification", thief.Name .. " tried to steal from you but failed!", 3)
		return { success = false, message = "Steal failed!" }
	end
end

return DataManager