-- HUD: Main Heads-Up Display for the game

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local GameConfig = require(script.Parent.Parent.shared.GameConfig)
local Network = require(script.Parent.Parent.shared.Network)
local Utility = require(script.Parent.Parent.shared.Utility)
local UIComponents = require(script.UIComponents)

local HUD = {}

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = nil
local moneyDisplay = nil
local rebirthDisplay = nil
local waveDisplay = nil
local shopButton = nil
local upgradesButton = nil
local inventoryButton = nil
local baseButton = nil
local notificationContainer = nil
local toasts = {}

-- Initialize HUD
function HUD.Initialize()
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GameHUD"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	HUD.CreateTopBar()
	HUD.CreateBottomBar()
	HUD.CreateNotificationArea()

	-- Connect to network events
	Network.OnClientEvent("MoneyChanged", HUD.OnMoneyChanged)
	Network.OnClientEvent("MoneyPerSecChanged", HUD.OnMoneyPerSecChanged)
	Network.OnClientEvent("PlayerDataLoaded", HUD.OnPlayerDataLoaded)
	Network.OnClientEvent("ShowNotification", HUD.ShowNotification)
	Network.OnClientEvent("ShowToast", HUD.ShowToast)
	Network.OnClientEvent("WaveWarning", HUD.OnWaveWarning)
	Network.OnClientEvent("WaveStarted", HUD.OnWaveStarted)
	Network.OnClientEvent("WaveEnded", HUD.OnWaveEnded)

	-- Request initial data
	Network.InvokeServer("RequestPlayerData")

	print("[HUD] Initialized")
end

-- Create top bar with money, rebirth, wave info
function HUD.CreateTopBar()
	local topBar = UIComponents.CreateFrame({
		Name = "TopBar",
		Size = UDim2.new(1, 0, 0, 80),
		Position = UDim2.fromScale(0, 0),
		BackgroundColor3 = Color3.fromRGB(15, 15, 25),
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		Parent = screenGui,
	})

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(0, 150, 200)
	stroke.Thickness = 1
	stroke.Transparency = 0.5
	stroke.Parent = topBar

	-- Game title
	UIComponents.CreateLabel({
		Name = "Title",
		Size = UDim2.fromOffset(300, 40),
		Position = UDim2.fromOffset(20, 5),
		Text = "🧠 BRAINROT BASE DEFENSE 🧠",
		TextColor3 = Color3.fromRGB(255, 100, 255),
		TextSize = 22,
		Font = Enum.Font.FredokaOne,
		TextStrokeTransparency = 0,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = topBar,
	})

	-- Money display (left)
	moneyDisplay = UIComponents.CreateMoneyDisplay({
		Name = "MoneyDisplay",
		Size = UDim2.fromOffset(220, 55),
		Position = UDim2.fromOffset(20, 45),
		Amount = 0,
		PerSec = 0,
		Parent = topBar,
	})

	-- Rebirth display (center)
	rebirthDisplay = UIComponents.CreateFrame({
		Name = "RebirthDisplay",
		Size = UDim2.fromOffset(180, 55),
		Position = UDim2.new(0.5, -90, 0, 45),
		BackgroundColor3 = Color3.fromRGB(255, 100, 255),
		BackgroundTransparency = 0.2,
		CornerRadius = 10,
		Stroke = { Color = Color3.fromRGB(255, 100, 255), Thickness = 2 },
		Parent = topBar,
	})

	UIComponents.CreateLabel({
		Name = "RebirthIcon",
		Size = UDim2.fromOffset(40, 40),
		Position = UDim2.fromOffset(10, 8),
		Text = "🔄",
		TextSize = 24,
		Parent = rebirthDisplay,
	})

	local rebirthLabel = UIComponents.CreateLabel({
		Name = "RebirthLabel",
		Size = UDim2.fromOffset(120, 25),
		Position = UDim2.fromOffset(55, 5),
		Text = "Rebirths: 0",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 18,
		Font = Enum.Font.FredokaOne,
		TextStrokeTransparency = 0,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = rebirthDisplay,
	})

	local rebirthBonusLabel = UIComponents.CreateLabel({
		Name = "RebirthBonus",
		Size = UDim2.fromOffset(120, 20),
		Position = UDim2.fromOffset(55, 30),
		Text = "+0% Money",
		TextColor3 = Color3.fromRGB(200, 255, 200),
		TextSize = 12,
		Font = Enum.Font.SourceSans,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = rebirthDisplay,
	})

	rebirthDisplay.Update = function(rebirths: number)
		rebirthLabel.Text = "Rebirths: " .. rebirths
		local bonus = rebirths * GameConfig.Rebirth.Rewards.moneyMultiplier * 100
		rebirthBonusLabel.Text = "+" .. bonus .. "% Money"
	end

	-- Wave display (right)
	waveDisplay = UIComponents.CreateFrame({
		Name = "WaveDisplay",
		Size = UDim2.fromOffset(200, 55),
		Position = UDim2.new(1, -220, 0, 45),
		AnchorPoint = Vector2.new(0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 80, 80),
		BackgroundTransparency = 0.2,
		CornerRadius = 10,
		Stroke = { Color = Color3.fromRGB(255, 80, 80), Thickness = 2 },
		Visible = false,
		Parent = topBar,
	})

	UIComponents.CreateLabel({
		Name = "WaveIcon",
		Size = UDim2.fromOffset(40, 40),
		Position = UDim2.fromOffset(10, 8),
		Text = "🌊",
		TextSize = 24,
		Parent = waveDisplay,
	})

	local waveLabel = UIComponents.CreateLabel({
		Name = "WaveLabel",
		Size = UDim2.fromOffset(140, 25),
		Position = UDim2.fromOffset(55, 5),
		Text = "WAVE INCOMING",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 16,
		Font = Enum.Font.FredokaOne,
		TextStrokeTransparency = 0,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = waveDisplay,
	})

	local waveTimerLabel = UIComponents.CreateLabel({
		Name = "WaveTimer",
		Size = UDim2.fromOffset(140, 20),
		Position = UDim2.fromOffset(55, 30),
		Text = "10s",
		TextColor3 = Color3.fromRGB(255, 200, 200),
		TextSize = 14,
		Font = Enum.Font.SourceSans,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = waveDisplay,
	})

	waveDisplay.Update = function(waveType: table?, timeLeft: number, isWarning: boolean)
		if waveType then
			waveDisplay.Visible = true
			waveLabel.Text = isWarning and ("⚠️ " .. waveType.name .. " INCOMING") or ("🌊 " .. waveType.name .. " ACTIVE")
			waveTimerLabel.Text = Utility.FormatTime(timeLeft) .. (isWarning and " until impact" or " remaining")

			-- Pulse animation
			if isWarning then
				local tween = TweenService:Create(waveDisplay, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { BackgroundTransparency = 0.5 })
				tween:Play()
			else
				waveDisplay.BackgroundTransparency = 0.2
			end
		else
			waveDisplay.Visible = false
		end
	end
end

-- Create bottom bar with action buttons
function HUD.CreateBottomBar()
	local bottomBar = UIComponents.CreateFrame({
		Name = "BottomBar",
		Size = UDim2.new(1, -40, 0, 90),
		Position = UDim2.new(0.5, 0, 1, -100),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Color3.fromRGB(15, 15, 25),
		BackgroundTransparency = 0.1,
		CornerRadius = 15,
		Stroke = { Color = Color3.fromRGB(0, 150, 200), Thickness = 1, Transparency = 0.5 },
		Parent = screenGui,
	})

	-- Button layout
	local buttons = {
		{ name = "Base", text = "🏠 BASE", color = Color3.fromRGB(100, 200, 100), pos = UDim2.fromOffset(10, 10) },
		{ name = "Shop", text = "🛒 SHOP", color = Color3.fromRGB(255, 200, 0), pos = UDim2.fromOffset(160, 10) },
		{ name = "Upgrades", text = "⬆️ UPGRADES", color = Color3.fromRGB(0, 180, 255), pos = UDim2.fromOffset(310, 10) },
		{ name = "Inventory", text = "🎒 INVENTORY", color = Color3.fromRGB(200, 100, 255), pos = UDim2.fromOffset(480, 10) },
		{ name = "Rebirth", text = "🔄 REBIRTH", color = Color3.fromRGB(255, 100, 255), pos = UDim2.fromOffset(650, 10) },
		{ name = "Steal", text = "🕵️ RAID", color = Color3.fromRGB(255, 80, 80), pos = UDim2.fromOffset(820, 10) },
	}

	for _, btnData in ipairs(buttons) do
		local button = UIComponents.CreateButton({
			Name = btnData.name .. "Button",
			Size = UDim2.fromOffset(140, 50),
			Position = btnData.pos,
			Text = btnData.text,
			BackgroundColor3 = btnData.color,
			HoverColor = Utility.LerpColor(btnData.color, Color3.fromRGB(255, 255, 255), 0.2),
			CornerRadius = 10,
			TextSize = 16,
			Parent = bottomBar,
		})

		HUD[btnData.name .. "Button"] = button
	end

	-- Connect button events
	baseButton.MouseButton1Click:Connect(function() HUD.ToggleBasePanel() end)
	shopButton.MouseButton1Click:Connect(function() HUD.ToggleShopPanel() end)
	upgradesButton.MouseButton1Click:Connect(function() HUD.ToggleUpgradesPanel() end)
	inventoryButton.MouseButton1Click:Connect(function() HUD.ToggleInventoryPanel() end)
	rebirthButton.MouseButton1Click:Connect(function() HUD.ToggleRebirthPanel() end)
	stealButton.MouseButton1Click:Connect(function() HUD.ToggleStealPanel() end)
end

-- Create notification area
function HUD.CreateNotificationArea()
	notificationContainer = Instance.new("Frame")
	notificationContainer.Name = "Notifications"
	notificationContainer.Size = UDim2.fromOffset(370, 400)
	notificationContainer.Position = UDim2.new(1, -380, 1, -500)
	notificationContainer.BackgroundTransparency = 1
	notificationContainer.ZIndex = 100
	notificationContainer.Parent = screenGui

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	layout.Padding = UDim.new(0, 10)
	layout.Parent = notificationContainer
end

-- Show notification toast
function HUD.ShowNotification(text: string, duration: number?)
	duration = duration or 3
	local index = #toasts

	local toast = UIComponents.CreateToast({
		Id = "Notif_" .. os.clock(),
		Text = text,
		Duration = duration,
		Index = index,
		StrokeColor = Color3.fromRGB(0, 200, 150),
		Parent = notificationContainer,
	})

	toast.LayoutOrder = -os.clock()
	table.insert(toasts, toast)

	-- Clean up old toasts
	if #toasts > 5 then
		local old = table.remove(toasts, 1)
		if old.Parent then old:Destroy() end
	end
end

function HUD.ShowToast(data: table)
	HUD.ShowNotification(data.text, data.duration)
end

-- Network event handlers
function HUD.OnMoneyChanged(amount: number)
	if moneyDisplay then
		local perSec = tonumber(moneyDisplay.PerSec.Text:match("+(.+)/s"):gsub("[KM]", "")) or 0
		moneyDisplay.Update(amount, perSec)
	end
end

function HUD.OnMoneyPerSecChanged(perSec: number)
	if moneyDisplay then
		local amount = tonumber(moneyDisplay.Amount.Text:gsub(",", "")) or 0
		moneyDisplay.Update(amount, perSec)
	end
end

function HUD.OnPlayerDataLoaded(data: table)
	if moneyDisplay then
		moneyDisplay.Update(data.money, PlayerData.CalculateMoneyPerSec(data))
	end

	if rebirthDisplay then
		rebirthDisplay.Update(data.rebirths or 0)
	end

	-- Update upgrade buttons when panel is open
	HUD.RefreshUpgradesPanel(data)
end

function HUD.OnWaveWarning(waveType: table, warningTime: number)
	waveDisplay.Update(waveType, warningTime, true)

	HUD.ShowNotification("⚠️ " .. waveType.name .. " INCOMING IN " .. warningTime .. "s! " .. waveType.description, warningTime)
end

function HUD.OnWaveStarted(waveType: table)
	waveDisplay.Update(waveType, GameConfig.HazardWaves.WaveDuration, false)
	HUD.ShowNotification("🌊 " .. waveType.name .. " STARTED! Find safe zones!", 5)
end

function HUD.OnWaveEnded(waveType: table)
	waveDisplay.Update(nil, 0, false)
	HUD.ShowNotification("✅ " .. waveType.name .. " ENDED! Survival bonus awarded!", 3)
end

-- Panel management (placeholders - will be implemented)
local activePanel = nil

function HUD.ToggleBasePanel()
	HUD.CloseAllPanels()
	HUD.OpenBasePanel()
end

function HUD.ToggleShopPanel()
	HUD.CloseAllPanels()
	HUD.OpenShopPanel()
end

function HUD.ToggleUpgradesPanel()
	HUD.CloseAllPanels()
	HUD.OpenUpgradesPanel()
end

function HUD.ToggleInventoryPanel()
	HUD.CloseAllPanels()
	HUD.OpenInventoryPanel()
end

function HUD.ToggleRebirthPanel()
	HUD.CloseAllPanels()
	HUD.OpenRebirthPanel()
end

function HUD.ToggleStealPanel()
	HUD.CloseAllPanels()
	HUD.OpenStealPanel()
end

function HUD.CloseAllPanels()
	if activePanel then
		activePanel:Destroy()
		activePanel = nil
	end
end

function HUD.OpenBasePanel()
	-- TODO: Implement base panel showing placed brainrots, grid, money/sec
	activePanel = HUD.CreatePanel("BASE", "Your brainrot base. Place brainrots to earn money!")
end

function HUD.OpenShopPanel()
	-- TODO: Implement shop panel with brainrot offers
	activePanel = HUD.CreatePanel("SHOP", "Buy brainrots to place on your base!")
	HUD.RequestShopOffers()
end

function HUD.OpenUpgradesPanel()
	-- TODO: Implement upgrades panel
	activePanel = HUD.CreatePanel("UPGRADES", "Upgrade your base, money multiplier, and more!")
end

function HUD.OpenInventoryPanel()
	-- TODO: Implement inventory panel
	activePanel = HUD.CreatePanel("INVENTORY", "Your collected brainrots waiting to be placed!")
end

function HUD.OpenRebirthPanel()
	-- TODO: Implement rebirth panel
	activePanel = HUD.CreatePanel("REBIRTH", "Reset progress for permanent bonuses!")
end

function HUD.OpenStealPanel()
	-- TODO: Implement steal/raid panel
	activePanel = HUD.CreatePanel("RAID", "Raid other players' bases for their brainrots!")
end

function HUD.CreatePanel(title: string, description: string): Frame
	local panel = UIComponents.CreateFrame({
		Name = title .. "Panel",
		Size = UDim2.fromOffset(500, 400),
		Position = UDim2.new(0.5, -250, 0.5, -200),
		AnchorPoint = Vector2.new(0, 0),
		BackgroundColor3 = Color3.fromRGB(20, 20, 30),
		CornerRadius = 15,
		Stroke = { Color = Color3.fromRGB(0, 150, 200), Thickness = 2 },
		ZIndex = 50,
		Parent = screenGui,
	})

	-- Close button
	local closeBtn = UIComponents.CreateButton({
		Name = "CloseButton",
		Size = UDim2.fromOffset(30, 30),
		Position = UDim2.new(1, -40, 0, 10),
		Text = "✕",
		BackgroundColor3 = Color3.fromRGB(200, 50, 50),
		HoverColor = Color3.fromRGB(255, 80, 80),
		CornerRadius = 6,
		TextSize = 16,
		Parent = panel,
	})

	closeBtn.MouseButton1Click:Connect(function()
		panel:Destroy()
		activePanel = nil
	end)

	-- Title
	UIComponents.CreateLabel({
		Name = "Title",
		Size = UDim2.fromOffset(400, 40),
		Position = UDim2.fromOffset(20, 10),
		Text = title,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 28,
		Font = Enum.Font.FredokaOne,
		TextStrokeTransparency = 0,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = panel,
	})

	-- Description
	UIComponents.CreateLabel({
		Name = "Description",
		Size = UDim2.fromOffset(460, 30),
		Position = UDim2.fromOffset(20, 50),
		Text = description,
		TextColor3 = Color3.fromRGB(180, 180, 200),
		TextSize = 14,
		Font = Enum.Font.SourceSans,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = panel,
	})

	return panel
end

function HUD.RequestShopOffers()
	Network.InvokeServer("RequestShopReroll"):andThen(function(result)
		if result and result.success and result.offers then
			HUD.PopulateShopPanel(result.offers)
		end
	end)
end

function HUD.PopulateShopPanel(offers: {table})
	if not activePanel or activePanel.Name ~= "SHOPPanel" then return end

	-- Clear existing offers
	for _, child in ipairs(activePanel:GetChildren()) do
		if child.Name:find("Offer") then child:Destroy() end
	end

	-- Create offer cards
	for i, offer in ipairs(offers) do
		local BrainrotData = require(script.Parent.Parent.shared.BrainrotData)
		local brainrot = BrainrotData.GetBrainrot(offer.id)
		if not brainrot then continue end

		local basePrice = brainrot.baseMoneyPerSec * 100
		local rarityMultiplier = BrainrotData.GetRarity(brainrot.rarity).moneyMultiplier
		local mutationMultiplier = BrainrotData.GetMutation(offer.mutation).multiplier
		local price = math.floor(basePrice * rarityMultiplier * mutationMultiplier)

		local card = UIComponents.CreateBrainrotCard({
			Name = "Offer_" .. i,
			Size = UDim2.fromOffset(160, 220),
			Position = UDim2.fromOffset(20 + (i-1) % 3 * 170, 90 + math.floor((i-1)/3) * 230),
			BrainrotId = offer.id,
			Mutation = offer.mutation,
			Price = price,
			ButtonText = "BUY",
			OnClick = function()
				Network.InvokeServer("RequestPurchaseBrainrot", i):andThen(function(result)
					if result and result.success then
						HUD.ShowNotification("Purchased " .. brainrot.name .. " for " .. Utility.FormatNumber(price) .. "!")
						HUD.RequestShopOffers()
					else
						HUD.ShowNotification("Purchase failed: " .. (result and result.message or "Unknown error"))
					end
				end)
			end,
			Parent = activePanel,
		})
	end
end

function HUD.RefreshUpgradesPanel(data: table)
	if not activePanel or activePanel.Name ~= "UPGRADESPanel" then return end
	-- TODO: Implement
end

-- Initialize on load
HUD.Initialize()

return HUD