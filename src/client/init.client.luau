-- Main Client Entry Point
-- Initializes all client systems for Brainrot Base Defense

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Network = require(script.Parent.Parent.shared.Network)
local HUD = require(script.HUD)
local PlayerDataClient = require(script.PlayerData)

-- Wait for network to be ready
local function waitForNetwork()
	local remoteFolder = ReplicatedStorage:WaitForChild("BrainrotRemotes", 10)
	local functionFolder = ReplicatedStorage:WaitForChild("BrainrotFunctions", 10)
	return remoteFolder and functionFolder
end

-- Initialize client
local function initialize()
	print("[Client] Waiting for network...")
	if not waitForNetwork() then
		warn("[Client] Network not ready, retrying...")
		task.wait(2)
		if not waitForNetwork() then
			error("[Client] Network initialization failed")
		end
	end

	print("[Client] Network ready, initializing HUD...")

	-- HUD initializes itself and connects to network events
	-- Network callbacks are set up in HUD.Initialize()

	-- Handle incoming player data
	Network.OnClientEvent("PlayerDataLoaded", function(data)
		PlayerDataClient.UpdateData(data)
	end)

	Network.OnClientEvent("ShopOffersUpdated", function(offers)
		local data = PlayerDataClient.GetData()
		data.shopOffers = offers
		PlayerDataClient.UpdateData(data)
	end)

	Network.OnClientEvent("BrainrotPlaced", function(brainrot)
		local data = PlayerDataClient.GetData()
		table.insert(data.brainrots, brainrot)
		PlayerDataClient.UpdateData(data)
	end)

	Network.OnClientEvent("BrainrotRemoved", function(index)
		local data = PlayerDataClient.GetData()
		table.remove(data.brainrots, index)
		PlayerDataClient.UpdateData(data)
	end)

	Network.OnClientEvent("BrainrotMoved", function(index, position)
		local data = PlayerDataClient.GetData()
		if data.brainrots[index] then
			data.brainrots[index].position = position
			PlayerDataClient.UpdateData(data)
		end
	end)

	Network.OnClientEvent("UpgradePurchased", function(upgradeName, newLevel)
		local data = PlayerDataClient.GetData()
		data.upgrades[upgradeName] = newLevel
		if upgradeName == "BaseSize" then
			data.baseGridSize = require(script.Parent.Parent.shared.GameConfig).BasePlot.GridSize + (newLevel * require(script.Parent.Parent.shared.GameConfig).Upgrades.BaseSize.cellIncreasePerLevel)
		elseif upgradeName == "BaseDefense" then
			data.baseDefenseLevel = newLevel
		end
		PlayerDataClient.UpdateData(data)
	end)

	Network.OnClientEvent("RebirthCompleted", function(rebirths)
		local data = PlayerDataClient.GetData()
		data.rebirths = rebirths
		PlayerDataClient.UpdateData(data)
	end)

	Network.OnClientEvent("PlayerStolenFrom", function(thiefName, brainrotId)
		-- Notification handled by HUD
	end)

	print("========================================")
	print("  BRAINROT BASE DEFENSE - CLIENT READY")
	print("========================================")
end

-- Start initialization
initialize()

return {}