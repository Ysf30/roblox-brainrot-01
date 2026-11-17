-- UIComponents: Reusable UI components for the game

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Utility = require(game:GetService("ReplicatedStorage").Shared.Utility)

local UIComponents = {}

-- Create a styled frame
function UIComponents.CreateFrame(props: table): Frame
	local frame = Instance.new("Frame")
	frame.Name = props.Name or "Frame"
	frame.Size = props.Size or UDim2.fromScale(1, 1)
	frame.Position = props.Position or UDim2.fromScale(0, 0)
	frame.AnchorPoint = props.AnchorPoint or Vector2.new(0, 0)
	frame.BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(30, 30, 40)
	frame.BackgroundTransparency = props.BackgroundTransparency or 0
	frame.BorderSizePixel = props.BorderSizePixel or 0
	frame.ZIndex = props.ZIndex or 1
	frame.Visible = props.Visible ~= false
	frame.Parent = props.Parent

	if props.CornerRadius then
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, props.CornerRadius)
		corner.Parent = frame
	end

	if props.Stroke then
		local stroke = Instance.new("UIStroke")
		stroke.Color = props.Stroke.Color or Color3.fromRGB(100, 100, 120)
		stroke.Thickness = props.Stroke.Thickness or 2
		stroke.Transparency = props.Stroke.Transparency or 0
		stroke.Parent = frame
	end

	return frame
end

-- Create a styled text label
function UIComponents.CreateLabel(props: table): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = props.Name or "Label"
	label.Size = props.Size or UDim2.fromScale(1, 1)
	label.Position = props.Position or UDim2.fromScale(0, 0)
	label.AnchorPoint = props.AnchorPoint or Vector2.new(0, 0)
	label.BackgroundTransparency = 1
	label.Text = props.Text or ""
	label.TextColor3 = props.TextColor3 or Color3.fromRGB(255, 255, 255)
	label.TextSize = props.TextSize or 18
	label.Font = props.Font or Enum.Font.FredokaOne
	label.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Center
	label.TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center
	label.TextWrapped = props.TextWrapped or false
	label.TextScaled = props.TextScaled or false
	label.TextStrokeTransparency = props.TextStrokeTransparency or 0
	label.TextStrokeColor3 = props.TextStrokeColor3 or Color3.fromRGB(0, 0, 0)
	label.ZIndex = props.ZIndex or 1
	label.Visible = props.Visible ~= false
	label.Parent = props.Parent

	return label
end

-- Create a styled text button
function UIComponents.CreateButton(props: table): TextButton
	local button = Instance.new("TextButton")
	button.Name = props.Name or "Button"
	button.Size = props.Size or UDim2.fromOffset(150, 40)
	button.Position = props.Position or UDim2.fromScale(0, 0)
	button.AnchorPoint = props.AnchorPoint or Vector2.new(0, 0)
	button.BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(0, 180, 255)
	button.BackgroundTransparency = props.BackgroundTransparency or 0
	button.BorderSizePixel = 0
	button.Text = props.Text or "Button"
	button.TextColor3 = props.TextColor3 or Color3.fromRGB(255, 255, 255)
	button.TextSize = props.TextSize or 18
	button.Font = props.Font or Enum.Font.FredokaOne
	button.TextStrokeTransparency = props.TextStrokeTransparency or 0
	button.TextStrokeColor3 = props.TextStrokeColor3 or Color3.fromRGB(0, 0, 0)
	button.ZIndex = props.ZIndex or 1
	button.Visible = props.Visible ~= false
	button.AutoButtonColor = props.AutoButtonColor ~= false
	button.Parent = props.Parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, props.CornerRadius or 8)
	corner.Parent = button

	if props.Stroke then
		local stroke = Instance.new("UIStroke")
		stroke.Color = props.Stroke.Color or Color3.fromRGB(0, 120, 200)
		stroke.Thickness = props.Stroke.Thickness or 2
		stroke.Parent = button
	end

	-- Hover effects
	if props.HoverColor then
		button.MouseEnter:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.1), { BackgroundColor3 = props.HoverColor }):Play()
		end)
		button.MouseLeave:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.1), { BackgroundColor3 = props.BackgroundColor3 }):Play()
		end)
	end

	return button
end

-- Create a money display label
function UIComponents.CreateMoneyDisplay(props: table): Frame
	local container = UIComponents.CreateFrame({
		Name = props.Name or "MoneyDisplay",
		Size = props.Size or UDim2.fromOffset(200, 50),
		Position = props.Position or UDim2.fromScale(0, 0),
		AnchorPoint = props.AnchorPoint,
		BackgroundColor3 = Color3.fromRGB(20, 20, 30),
		BackgroundTransparency = 0.2,
		CornerRadius = 10,
		Stroke = { Color = Color3.fromRGB(0, 200, 150), Thickness = 2 },
		Parent = props.Parent,
	})

	local icon = UIComponents.CreateLabel({
		Name = "Icon",
		Size = UDim2.fromOffset(40, 40),
		Position = UDim2.fromOffset(10, 5),
		Text = "💰",
		TextSize = 28,
		Parent = container,
	})

	local amountLabel = UIComponents.CreateLabel({
		Name = "Amount",
		Size = UDim2.fromOffset(140, 40),
		Position = UDim2.fromOffset(55, 5),
		Text = Utility.FormatNumber(props.Amount or 0),
		TextColor3 = Color3.fromRGB(0, 255, 150),
		TextSize = 24,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = container,
	})

	local perSecLabel = UIComponents.CreateLabel({
		Name = "PerSec",
		Size = UDim2.fromOffset(140, 20),
		Position = UDim2.fromOffset(55, 30),
		Text = "+" .. Utility.FormatNumber(props.PerSec or 0) .. "/s",
		TextColor3 = Color3.fromRGB(150, 255, 200),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = container,
	})

	container.Update = function(amount: number, perSec: number)
		amountLabel.Text = Utility.FormatNumber(amount)
		perSecLabel.Text = "+" .. Utility.FormatNumber(perSec) .. "/s"
	end

	return container
end

-- Create a brainrot card for shop/inventory
function UIComponents.CreateBrainrotCard(props: table): Frame
	local BrainrotData = require(game:GetService("ReplicatedStorage").Shared.BrainrotData)
	local brainrot = BrainrotData.GetBrainrot(props.BrainrotId)
	local mutation = props.Mutation or "None"
	local mutationData = BrainrotData.GetMutation(mutation)
	local rarityData = brainrot and BrainrotData.GetRarity(brainrot.rarity)

	local card = UIComponents.CreateFrame({
		Name = "BrainrotCard_" .. (props.BrainrotId or "Unknown"),
		Size = props.Size or UDim2.fromOffset(160, 200),
		Position = props.Position,
		BackgroundColor3 = Color3.fromRGB(40, 40, 50),
		CornerRadius = 12,
		Stroke = {
			Color = rarityData and rarityData.color or Color3.fromRGB(100, 100, 120),
			Thickness = 2
		},
		Parent = props.Parent,
	})

	-- Rarity badge
	if rarityData then
		local badge = UIComponents.CreateFrame({
			Name = "RarityBadge",
			Size = UDim2.fromOffset(80, 24),
			Position = UDim2.new(0.5, -40, 0, -12),
			AnchorPoint = Vector2.new(0, 0),
			BackgroundColor3 = rarityData.color,
			CornerRadius = 12,
			Parent = card,
		})

		UIComponents.CreateLabel({
			Name = "RarityText",
			Size = UDim2.fromScale(1, 1),
			Text = rarityData.icon .. " " .. rarityData.displayName,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 12,
			Font = Enum.Font.FredokaOne,
			TextStrokeTransparency = 0,
			Parent = badge,
		})
	end

	-- Mutation badge
	if mutation ~= "None" and mutationData then
		local mutBadge = UIComponents.CreateFrame({
			Name = "MutationBadge",
			Size = UDim2.fromOffset(80, 20),
			Position = UDim2.new(0.5, -40, 0, 14),
			AnchorPoint = Vector2.new(0, 0),
			BackgroundColor3 = mutationData.color,
			CornerRadius = 10,
			Parent = card,
		})

		UIComponents.CreateLabel({
			Name = "MutationText",
			Size = UDim2.fromScale(1, 1),
			Text = "✨ " .. mutationData.name,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 11,
			Font = Enum.Font.FredokaOne,
			TextStrokeTransparency = 0,
			Parent = mutBadge,
		})
	end

	-- Brainrot name
	local nameLabel = UIComponents.CreateLabel({
		Name = "Name",
		Size = UDim2.fromOffset(140, 30),
		Position = UDim2.fromOffset(10, mutation ~= "None" and 40 or 15),
		Text = brainrot and brainrot.name or props.BrainrotId,
		TextColor3 = rarityData and rarityData.nameColor or Color3.fromRGB(255, 255, 255),
		TextSize = 16,
		Font = Enum.Font.FredokaOne,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = card,
	})

	-- Money per sec
	local mps = brainrot and BrainrotData.CalculateMoneyPerSec(props.BrainrotId, mutation) or 0
	local mpsLabel = UIComponents.CreateLabel({
		Name = "MPS",
		Size = UDim2.fromOffset(140, 24),
		Position = UDim2.fromOffset(10, 60 + (mutation ~= "None" and 26 or 0)),
		Text = "+" .. Utility.FormatNumber(mps) .. "/s",
		TextColor3 = Color3.fromRGB(0, 255, 150),
		TextSize = 18,
		Font = Enum.Font.FredokaOne,
		Parent = card,
	})

	-- Description
	if brainrot then
		UIComponents.CreateLabel({
			Name = "Description",
			Size = UDim2.fromOffset(140, 40),
			Position = UDim2.fromOffset(10, 90 + (mutation ~= "None" and 26 or 0)),
			Text = brainrot.description,
			TextColor3 = Color3.fromRGB(180, 180, 200),
			TextSize = 11,
			Font = Enum.Font.SourceSans,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Center,
			Parent = card,
		})
	end

	-- Price (for shop)
	if props.Price then
		local priceLabel = UIComponents.CreateLabel({
			Name = "Price",
			Size = UDim2.fromOffset(140, 24),
			Position = UDim2.fromOffset(10, 150 + (mutation ~= "None" and 26 or 0)),
			Text = "💰 " .. Utility.FormatNumber(props.Price),
			TextColor3 = Color3.fromRGB(255, 200, 0),
			TextSize = 16,
			Font = Enum.Font.FredokaOne,
			Parent = card,
		})
	end

	-- Action button
	if props.OnClick then
		local button = UIComponents.CreateButton({
			Name = "ActionButton",
			Size = UDim2.fromOffset(120, 32),
			Position = UDim2.new(0.5, -60, 1, -42),
			AnchorPoint = Vector2.new(0, 0),
			Text = props.ButtonText or "BUY",
			BackgroundColor3 = props.ButtonColor or Color3.fromRGB(0, 180, 255),
			HoverColor = props.ButtonHoverColor or Color3.fromRGB(0, 200, 255),
			CornerRadius = 6,
			Parent = card,
		})

		button.MouseButton1Click:Connect(function()
			props.OnClick()
		end)
	end

	return card
end

-- Create a notification toast
function UIComponents.CreateToast(props: table): Frame
	local toast = UIComponents.CreateFrame({
		Name = "Toast_" .. (props.Id or "Toast"),
		Size = UDim2.fromOffset(350, 60),
		Position = UDim2.new(1, -370, 1, -80 - (props.Index or 0) * 70),
		AnchorPoint = Vector2.new(0, 0),
		BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(30, 30, 40),
		CornerRadius = 10,
		Stroke = {
			Color = props.StrokeColor or Color3.fromRGB(0, 200, 150),
			Thickness = 2
		},
		Parent = props.Parent,
	})

	UIComponents.CreateLabel({
		Name = "Text",
		Size = UDim2.fromOffset(330, 50),
		Position = UDim2.fromOffset(10, 5),
		Text = props.Text or "Notification",
		TextColor3 = props.TextColor3 or Color3.fromRGB(255, 255, 255),
		TextSize = 16,
		Font = Enum.Font.FredokaOne,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = toast,
	})

	-- Auto-dismiss
	if props.Duration then
		task.delay(props.Duration, function()
			if toast.Parent then
				local tween = TweenService:Create(toast, TweenInfo.new(0.3), { Position = UDim2.new(1, 20, toast.Position.Y.Scale, toast.Position.Y.Offset) })
				tween:Play()
				tween.Completed:Connect(function()
					toast:Destroy()
				end)
			end
		end)
	end

	return toast
end

-- Create a progress bar
function UIComponents.CreateProgressBar(props: table): Frame
	local container = UIComponents.CreateFrame({
		Name = "ProgressBar",
		Size = props.Size or UDim2.fromOffset(200, 20),
		Position = props.Position,
		BackgroundColor3 = Color3.fromRGB(20, 20, 30),
		CornerRadius = 10,
		Parent = props.Parent,
	})

	local fill = UIComponents.CreateFrame({
		Name = "Fill",
		Size = UDim2.fromScale(props.Progress or 0, 1),
		Position = UDim2.fromScale(0, 0),
		BackgroundColor3 = props.FillColor or Color3.fromRGB(0, 200, 150),
		CornerRadius = 10,
		Parent = container,
	})

	if props.Label then
		UIComponents.CreateLabel({
			Name = "Label",
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromScale(0, 0),
			Text = props.Label,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 12,
			Font = Enum.Font.FredokaOne,
			TextStrokeTransparency = 0,
			Parent = container,
		})
	end

	container.SetProgress = function(progress: number)
		progress = math.clamp(progress, 0, 1)
		fill.Size = UDim2.fromScale(progress, 1)
	end

	return container
end

-- Create an upgrade button
function UIComponents.CreateUpgradeButton(props: table): Frame
	local container = UIComponents.CreateFrame({
		Name = "UpgradeButton_" .. props.UpgradeName,
		Size = UDim2.fromOffset(280, 60),
		Position = props.Position,
		BackgroundColor3 = Color3.fromRGB(40, 40, 50),
		CornerRadius = 10,
		Stroke = { Color = Color3.fromRGB(80, 80, 100), Thickness = 1 },
		Parent = props.Parent,
	})

	UIComponents.CreateLabel({
		Name = "Name",
		Size = UDim2.fromOffset(150, 30),
		Position = UDim2.fromOffset(10, 5),
		Text = props.Name or props.UpgradeName,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 16,
		Font = Enum.Font.FredokaOne,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = container,
	})

	local levelLabel = UIComponents.CreateLabel({
		Name = "Level",
		Size = UDim2.fromOffset(100, 30),
		Position = UDim2.fromOffset(10, 30),
		Text = "Level " .. (props.CurrentLevel or 0) .. " / " .. (props.MaxLevel or 10),
		TextColor3 = Color3.fromRGB(150, 150, 180),
		TextSize = 12,
		Font = Enum.Font.SourceSans,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = container,
	})

	local costLabel = UIComponents.CreateLabel({
		Name = "Cost",
		Size = UDim2.fromOffset(120, 30),
		Position = UDim2.new(1, -130, 0, 5),
		AnchorPoint = Vector2.new(0, 0),
		Text = "💰 " .. Utility.FormatNumber(props.Cost or 0),
		TextColor3 = Color3.fromRGB(255, 200, 0),
		TextSize = 16,
		Font = Enum.Font.FredokaOne,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = container,
	})

	local benefitLabel = UIComponents.CreateLabel({
		Name = "Benefit",
		Size = UDim2.fromOffset(120, 30),
		Position = UDim2.new(1, -130, 0, 30),
		AnchorPoint = Vector2.new(0, 0),
		Text = props.Benefit or "",
		TextColor3 = Color3.fromRGB(0, 255, 150),
		TextSize = 12,
		Font = Enum.Font.SourceSans,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = container,
	})

	local button = UIComponents.CreateButton({
		Name = "PurchaseButton",
		Size = UDim2.fromOffset(80, 32),
		Position = UDim2.new(1, -90, 0.5, -16),
		AnchorPoint = Vector2.new(0, 0),
		Text = props.CanAfford and "BUY" or "LOCKED",
		BackgroundColor3 = props.CanAfford and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(80, 80, 80),
		HoverColor = props.CanAfford and Color3.fromRGB(0, 200, 120) or Color3.fromRGB(100, 100, 100),
		CornerRadius = 6,
		Parent = container,
	})

	if props.OnClick and props.CanAfford then
		button.MouseButton1Click:Connect(function()
			props.OnClick()
		end)
	end

	container.Update = function(newLevel: number, newCost: number, canAfford: boolean)
		levelLabel.Text = "Level " .. newLevel .. " / " .. (props.MaxLevel or 10)
		costLabel.Text = "💰 " .. Utility.FormatNumber(newCost)
		button.Text = canAfford and "BUY" or "LOCKED"
		button.BackgroundColor3 = canAfford and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(80, 80, 80)
		button.MouseButton1Click:Connect(function() end) -- Clear old connections
		if props.OnClick and canAfford then
			button.MouseButton1Click:Connect(props.OnClick)
		end
	end

	return container
end

return UIComponents