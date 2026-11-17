-- Network: RemoteEvent and RemoteFunction definitions for client-server communication
-- Single source of truth for all network messages

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = {}

-- Folder names
Network.REMOTE_FOLDER_NAME = "BrainrotRemotes"
Network.FUNCTION_FOLDER_NAME = "BrainrotFunctions"

-- RemoteEvent names (Server -> Client or Client -> Server)
Network.Events = {
	-- Player data
	"PlayerDataLoaded",
	"PlayerDataUpdated",
	"MoneyChanged",
	"MoneyPerSecChanged",

	-- Brainrot management
	"BrainrotPlaced",
	"BrainrotRemoved",
	"BrainrotMoved",
	"BrainrotMutationChanged",
	"BrainrotCollected",

	-- Shop
	"ShopOffersUpdated",
	"ShopRerolled",
	"ShopPurchaseResult",

	-- Upgrades
	"UpgradePurchased",
	"UpgradeFailed",

	-- Rebirth
	"RebirthRequested",
	"RebirthCompleted",
	"RebirthFailed",

	-- Stealing
	"StealAttempted",
	"StealResult",
	"PlayerStolenFrom",

	-- Hazard waves
	"WaveWarning",
	"WaveStarted",
	"WaveEnded",
	"WaveSafeZoneUpdate",

	-- Notifications/UI
	"ShowNotification",
	"ShowToast",
	"PlaySound",

	-- Base
	"BaseExpanded",
	"BaseDefenseChanged",

	-- Admin/Dev
	"AdminCommandResult",
}

-- RemoteFunction names (Client -> Server with return)
Network.Functions = {
	"RequestPlayerData",
	"RequestShopReroll",
	"RequestPurchaseBrainrot",
	"RequestPlaceBrainrot",
	"RequestRemoveBrainrot",
	"RequestUpgrade",
	"RequestRebirth",
	"RequestSteal",
	"RequestCollectAll",
	"RequestOfflineProgress",
}

-- Create network folders and remotes
function Network.Initialize()
	local remoteFolder = Instance.new("Folder")
	remoteFolder.Name = Network.REMOTE_FOLDER_NAME
	remoteFolder.Parent = ReplicatedStorage

	local functionFolder = Instance.new("Folder")
	functionFolder.Name = Network.FUNCTION_FOLDER_NAME
	functionFolder.Parent = ReplicatedStorage

	-- Create RemoteEvents
	for _, eventName in ipairs(Network.Events) do
		local remote = Instance.new("RemoteEvent")
		remote.Name = eventName
		remote.Parent = remoteFolder
	end

	-- Create RemoteFunctions
	for _, funcName in ipairs(Network.Functions) do
		local remote = Instance.new("RemoteFunction")
		remote.Name = funcName
		remote.Parent = functionFolder
	end

	print("[Network] Initialized " .. #Network.Events .. " events and " .. #Network.Functions .. " functions")
end

-- Helper to get RemoteEvent
function Network.GetEvent(name: string): RemoteEvent?
	local folder = ReplicatedStorage:FindFirstChild(Network.REMOTE_FOLDER_NAME)
	if folder then
		return folder:FindFirstChild(name)
	end
	return nil
end

-- Helper to get RemoteFunction
function Network.GetFunction(name: string): RemoteFunction?
	local folder = ReplicatedStorage:FindFirstChild(Network.FUNCTION_FOLDER_NAME)
	if folder then
		return folder:FindFirstChild(name)
	end
	return nil
end

-- Fire event to all clients
function Network.FireAllClients(eventName: string, ...: any)
	local event = Network.GetEvent(eventName)
	if event then
		event:FireAllClients(...)
	else
		warn("[Network] Event not found: " .. eventName)
	end
end

-- Fire event to specific client
function Network.FireClient(player: Player, eventName: string, ...: any)
	local event = Network.GetEvent(eventName)
	if event then
		event:FireClient(player, ...)
	else
		warn("[Network] Event not found: " .. eventName)
	end
end

-- Fire event to all clients except one
function Network.FireAllClientsExcept(excludePlayer: Player, eventName: string, ...: any)
	local event = Network.GetEvent(eventName)
	if event then
		for _, player in ipairs(game.Players:GetPlayers()) do
			if player ~= excludePlayer then
				event:FireClient(player, ...)
			end
		end
	else
		warn("[Network] Event not found: " .. eventName)
	end
end

-- Invoke function on client (rarely used)
function Network.InvokeClient(player: Player, funcName: string, ...: any): any
	local func = Network.GetFunction(funcName)
	if func then
		return func:InvokeClient(player, ...)
	else
		warn("[Network] Function not found: " .. funcName)
	end
	return nil
end

-- Server-side: Connect to function invocations
function Network.OnServerInvoke(funcName: string, callback: (player: Player, ...any) -> any)
	local func = Network.GetFunction(funcName)
	if func then
		func.OnServerInvoke = callback
	else
		warn("[Network] Function not found for OnServerInvoke: " .. funcName)
	end
end

-- Client-side: Connect to events
function Network.OnClientEvent(eventName: string, callback: (...any) -> ())
	local event = Network.GetEvent(eventName)
	if event then
		event.OnClientEvent:Connect(callback)
	else
		warn("[Network] Event not found for OnClientEvent: " .. eventName)
	end
end

-- Client-side: Invoke server function
function Network.InvokeServer(funcName: string, ...: any): any
	local func = Network.GetFunction(funcName)
	if func then
		return func:InvokeServer(...)
	else
		warn("[Network] Function not found for InvokeServer: " .. funcName)
	end
	return nil
end

-- Client-side: Fire server event
function Network.FireServer(eventName: string, ...: any)
	local event = Network.GetEvent(eventName)
	if event then
		event:FireServer(...)
	else
		warn("[Network] Event not found for FireServer: " .. eventName)
	end
end

return Network