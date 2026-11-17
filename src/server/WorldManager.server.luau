-- WorldManager: Handles 3D world creation, brainrot spawning, conveyor, hazard waves

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GameConfig = require(script.Parent.Parent.shared.GameConfig)
local BrainrotData = require(script.Parent.Parent.shared.BrainrotData)
local Network = require(script.Parent.Parent.shared.Network)
local Utility = require(script.Parent.Parent.shared.Utility)

local WorldManager = {}

-- World objects
local basePlot = nil
local spawnLane = nil
local conveyorParts = {}
local shopBuilding = nil
local hazardZones = {}
local currentWave = nil
local waveConnection = nil

-- Spawn lane state
local spawnLaneBrainrots = {}
local lastSpawnTime = 0

-- Initialize world
function WorldManager.Initialize()
	WorldManager.CreateBasePlot()
	WorldManager.CreateSpawnLane()
	WorldManager.CreateShop()
	WorldManager.CreateHazardZones()
	WorldManager.SetupConveyor()
	WorldManager.StartHazardWaves()

	print("[WorldManager] World initialized")
end

-- Create player base plot
function WorldManager.CreateBasePlot()
	basePlot = Instance.new("Part")
	basePlot.Name = "BasePlot"
	basePlot.Size = GameConfig.BasePlot.Size
	basePlot.Position = GameConfig.BasePlot.Position
	basePlot.Anchored = true
	basePlot.Material = Enum.Material.Concrete
	basePlot.Color = Color3.fromRGB(60, 60, 70)
	basePlot.Parent = Workspace

	-- Grid lines
	for i = 0, GameConfig.BasePlot.GridSize do
		local line1 = Instance.new("Part")
		line1.Name = "GridLine_" .. i
		line1.Size = Vector3.new(GameConfig.BasePlot.Size.X, 0.1, 0.2)
		line1.Position = Vector3.new(
			GameConfig.BasePlot.Position.X - GameConfig.BasePlot.Size.X/2 + i * GameConfig.BasePlot.CellSize,
			GameConfig.BasePlot.Position.Y + 0.1,
			GameConfig.BasePlot.Position.Z
		)
		line1.Anchored = true
		line1.Material = Enum.Material.Neon
		line1.Color = Color3.fromRGB(100, 100, 120)
		line1.Transparency = 0.5
		line1.CanCollide = false
		line1.Parent = basePlot

		local line2 = Instance.new("Part")
		line2.Name = "GridLineZ_" .. i
		line2.Size = Vector3.new(0.2, 0.1, GameConfig.BasePlot.Size.Z)
		line2.Position = Vector3.new(
			GameConfig.BasePlot.Position.X,
			GameConfig.BasePlot.Position.Y + 0.1,
			GameConfig.BasePlot.Position.Z - GameConfig.BasePlot.Size.Z/2 + i * GameConfig.BasePlot.CellSize
		)
		line2.Anchored = true
		line2.Material = Enum.Material.Neon
		line2.Color = Color3.fromRGB(100, 100, 120)
		line2.Transparency = 0.5
		line2.CanCollide = false
		line2.Parent = basePlot
	end

	-- Base core (center)
	local core = Instance.new("Part")
	core.Name = "BaseCore"
	core.Size = Vector3.new(6, 8, 6)
	core.Position = Vector3.new(0, 4, 0)
	core.Anchored = true
	core.Material = Enum.Material.ForceField
	core.Color = Color3.fromRGB(0, 200, 255)
	core.Transparency = 0.3
	core.CanCollide = false
	core.Parent = basePlot

	-- Core light
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(0, 200, 255)
	light.Range = 30
	light.Brightness = 2
	light.Parent = core

	-- Core particles
	local particles = Instance.new("ParticleEmitter")
	particles.Color = ColorSequence.new(Color3.fromRGB(0, 200, 255))
	particles.Size = NumberSequence.new(0.5, 1.5)
	particles.Lifetime = NumberRange.new(1, 2)
	particles.Rate = 20
	particles.Speed = NumberRange.new(2, 5)
	particles.SpreadAngle = Vector2.new(180, 180)
	particles.Parent = core
end

-- Create spawn lane / conveyor
function WorldManager.CreateSpawnLane()
	spawnLane = Instance.new("Model")
	spawnLane.Name = "SpawnLane"
	spawnLane.Parent = Workspace

	-- Conveyor base
	local conveyorBase = Instance.new("Part")
	conveyorBase.Name = "ConveyorBase"
	conveyorBase.Size = Vector3.new(GameConfig.SpawnLane.Width, 1, GameConfig.SpawnLane.Length)
	conveyorBase.Position = GameConfig.SpawnLane.StartPosition + Vector3.new(0, 0.5, GameConfig.SpawnLane.Length/2)
	conveyorBase.Anchored = true
	conveyorBase.Material = Enum.Material.Metal
	conveyorBase.Color = Color3.fromRGB(80, 80, 90)
	conveyorBase.Parent = spawnLane

	-- Conveyor belt sections (animated)
	local sectionCount = math.floor(GameConfig.SpawnLane.Length / 4)
	for i = 0, sectionCount - 1 do
		local section = Instance.new("Part")
		section.Name = "ConveyorSection_" .. i
		section.Size = Vector3.new(GameConfig.SpawnLane.Width - 1, 0.5, 4)
		section.Position = Vector3.new(
			GameConfig.SpawnLane.StartPosition.X,
			GameConfig.SpawnLane.StartPosition.Y + 1,
			GameConfig.SpawnLane.StartPosition.Z + 2 + i * 4
		)
		section.Anchored = true
		section.Material = Enum.Material.Plastic
		section.Color = Color3.fromRGB(50, 50, 60)
		section.Parent = spawnLane
		table.insert(conveyorParts, section)
	end

	-- Side walls
	for _, side in ipairs({-1, 1}) do
		local wall = Instance.new("Part")
		wall.Name = "SideWall_" .. (side == -1 and "Left" or "Right")
		wall.Size = Vector3.new(1, 4, GameConfig.SpawnLane.Length)
		wall.Position = Vector3.new(
			GameConfig.SpawnLane.StartPosition.X + side * (GameConfig.SpawnLane.Width/2 + 0.5),
			GameConfig.SpawnLane.StartPosition.Y + 2,
			GameConfig.SpawnLane.StartPosition.Z + GameConfig.SpawnLane.Length/2
		)
		wall.Anchored = true
		wall.Material = Enum.Material.Glass
		wall.Color = Color3.fromRGB(100, 150, 255)
		wall.Transparency = 0.5
		wall.Parent = spawnLane
	end

	-- Spawn pad at start
	local spawnPad = Instance.new("Part")
	spawnPad.Name = "SpawnPad"
	spawnPad.Size = Vector3.new(GameConfig.SpawnLane.Width - 2, 0.5, 6)
	spawnPad.Position = Vector3.new(
		GameConfig.SpawnLane.StartPosition.X,
		GameConfig.SpawnLane.StartPosition.Y + 1.25,
		GameConfig.SpawnLane.StartPosition.Z + 3
	)
	spawnPad.Anchored = true
	spawnPad.Material = Enum.Material.Neon
	spawnPad.Color = Color3.fromRGB(0, 255, 150)
	spawnPad.Parent = spawnLane

	-- Spawn pad particles
	local spawnParticles = Instance.new("ParticleEmitter")
	spawnParticles.Color = ColorSequence.new(Color3.fromRGB(0, 255, 150))
	spawnParticles.Size = NumberSequence.new(1, 2)
	spawnParticles.Lifetime = NumberRange.new(0.5, 1.5)
	spawnParticles.Rate = 30
	spawnParticles.Speed = NumberRange.new(1, 3)
	spawnParticles.SpreadAngle = Vector2.new(90, 90)
	spawnParticles.Parent = spawnPad
end

-- Create shop building
function WorldManager.CreateShop()
	shopBuilding = Instance.new("Model")
	shopBuilding.Name = "Shop"
	shopBuilding.Parent = Workspace

	-- Shop floor
	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Size = GameConfig.Shop.Size
	floor.Position = GameConfig.Shop.Position + Vector3.new(0, GameConfig.Shop.Size.Y/2, 0)
	floor.Anchored = true
	floor.Material = Enum.Material.Wood
	floor.Color = Color3.fromRGB(120, 90, 60)
	floor.Parent = shopBuilding

	-- Shop walls
	local wallThickness = 0.5
	local wallHeight = GameConfig.Shop.Size.Y - 1

	for _, wallData in ipairs({
		{ name = "WallBack", size = Vector3.new(GameConfig.Shop.Size.X, wallHeight, wallThickness), pos = Vector3.new(0, wallHeight/2 + 0.5, GameConfig.Shop.Size.Z/2) },
		{ name = "WallLeft", size = Vector3.new(wallThickness, wallHeight, GameConfig.Shop.Size.Z), pos = Vector3.new(-GameConfig.Shop.Size.X/2, wallHeight/2 + 0.5, 0) },
		{ name = "WallRight", size = Vector3.new(wallThickness, wallHeight, GameConfig.Shop.Size.Z), pos = Vector3.new(GameConfig.Shop.Size.X/2, wallHeight/2 + 0.5, 0) },
	}) do
		local wall = Instance.new("Part")
		wall.Name = wallData.name
		wall.Size = wallData.size
		wall.Position = GameConfig.Shop.Position + wallData.pos
		wall.Anchored = true
		wall.Material = Enum.Material.Wood
		wall.Color = Color3.fromRGB(100, 70, 40)
		wall.Parent = shopBuilding
	end

	-- Roof
	local roof = Instance.new("Part")
	roof.Name = "Roof"
	roof.Size = Vector3.new(GameConfig.Shop.Size.X + 2, 1, GameConfig.Shop.Size.Z + 2)
	roof.Position = GameConfig.Shop.Position + Vector3.new(0, GameConfig.Shop.Size.Y - 0.5, 0)
	roof.Anchored = true
	roof.Material = Enum.Material.Slate
	roof.Color = Color3.fromRGB(80, 40, 20)
	roof.Parent = shopBuilding

	-- Shop sign
	local sign = Instance.new("Part")
	sign.Name = "Sign"
	sign.Size = Vector3.new(12, 4, 1)
	sign.Position = GameConfig.Shop.Position + Vector3.new(0, GameConfig.Shop.Size.Y + 2, -GameConfig.Shop.Size.Z/2 - 1)
	sign.Anchored = true
	sign.Material = Enum.Material.Neon
	sign.Color = Color3.fromRGB(255, 200, 0)
	sign.Parent = shopBuilding

	local signGui = Instance.new("SurfaceGui")
	signGui.Face = Enum.NormalId.Front
	signGui.Parent = sign

	local signLabel = Instance.new("TextLabel")
	signLabel.Size = UDim2.fromScale(1, 1)
	signLabel.BackgroundTransparency = 1
	signLabel.Text = "🧠 BRAINROT SHOP 🧠"
	signLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	signLabel.TextSize = 36
	signLabel.Font = Enum.Font.FredokaOne
	signLabel.TextStrokeTransparency = 0
	signLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	signLabel.Parent = signGui

	-- Reroll button area
	local rerollPad = Instance.new("Part")
	rerollPad.Name = "RerollPad"
	rerollPad.Size = Vector3.new(6, 0.5, 6)
	rerollPad.Position = GameConfig.Shop.Position + Vector3.new(-GameConfig.Shop.Size.X/2 - 4, 0.75, 0)
	rerollPad.Anchored = true
	rerollPad.Material = Enum.Material.Neon
	rerollPad.Color = Color3.fromRGB(255, 100, 100)
	rerollPad.Parent = shopBuilding

	local rerollGui = Instance.new("SurfaceGui")
	rerollGui.Face = Enum.NormalId.Top
	rerollGui.Parent = rerollPad

	local rerollLabel = Instance.new("TextLabel")
	rerollLabel.Size = UDim2.fromScale(1, 1)
	rerollLabel.BackgroundTransparency = 1
	rerollLabel.Text = "🔄 REROLL\n500$"
	rerollLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	rerollLabel.TextSize = 24
	rerollLabel.Font = Enum.Font.FredokaOne
	rerollLabel.TextStrokeTransparency = 0
	rerollLabel.Parent = rerollGui
end

-- Create hazard safe zones
function WorldManager.CreateHazardZones()
	hazardZones = {}

	-- High ground (for tsunami)
	local highGround = Instance.new("Part")
	highGround.Name = "HighGround"
	highGround.Size = Vector3.new(30, 20, 30)
	highGround.Position = Vector3.new(80, 15, 80)
	highGround.Anchored = true
	highGround.Material = Enum.Material.Rock
	highGround.Color = Color3.fromRGB(100, 100, 100)
	highGround.Transparency = 0.3
	highGround.CanCollide = true
	highGround.Parent = Workspace
	hazardZones.HighGround = highGround

	-- Underground shelter (for meteors)
	local shelter = Instance.new("Part")
	shelter.Name = "BaseShelter"
	shelter.Size = Vector3.new(20, 10, 20)
	shelter.Position = Vector3.new(0, -5, 0)
	shelter.Anchored = true
	shelter.Material = Enum.Material.Concrete
	shelter.Color = Color3.fromRGB(50, 50, 60)
	shelter.Transparency = 0.2
	shelter.CanCollide = true
	shelter.Parent = Workspace
	hazardZones.BaseShelter = shelter

	-- Light zone (for void rift)
	local lightZone = Instance.new("Part")
	lightZone.Name = "LightZone"
	lightZone.Size = Vector3.new(25, 30, 25)
	lightZone.Position = Vector3.new(-80, 15, -80)
	lightZone.Anchored = true
	lightZone.Material = Enum.Material.ForceField
	lightZone.Color = Color3.fromRGB(255, 255, 200)
	lightZone.Transparency = 0.5
	lightZone.CanCollide = false
	lightZone.Parent = Workspace
	hazardZones.LightZone = lightZone

	-- Stable platform (for glitch storm)
	local stablePlatform = Instance.new("Part")
	stablePlatform.Name = "StablePlatform"
	stablePlatform.Size = Vector3.new(20, 2, 20)
	stablePlatform.Position = Vector3.new(0, 25, 0)
	stablePlatform.Anchored = true
	stablePlatform.Material = Enum.Material.DiamondPlate
	stablePlatform.Color = Color3.fromRGB(200, 200, 200)
	stablePlatform.Parent = Workspace
	hazardZones.StablePlatform = stablePlatform

	-- Base roof (for tsunami)
	local baseRoof = Instance.new("Part")
	baseRoof.Name = "BaseRoof"
	baseRoof.Size = Vector3.new(GameConfig.BasePlot.Size.X, 2, GameConfig.BasePlot.Size.Z)
	baseRoof.Position = Vector3.new(0, GameConfig.BasePlot.Size.Y + 10, 0)
	baseRoof.Anchored = true
	baseRoof.Material = Enum.Material.Metal
	baseRoof.Color = Color3.fromRGB(80, 80, 100)
	baseRoof.Transparency = 0.3
	baseRoof.CanCollide = true
	baseRoof.Parent = Workspace
	hazardZones.BaseRoof = baseRoof

	-- Base core anchor (for glitch)
	hazardZones.BaseAnchor = basePlot:FindFirstChild("BaseCore")

	-- Base core (for void)
	hazardZones.BaseCore = basePlot:FindFirstChild("BaseCore")
end

-- Setup conveyor animation
function WorldManager.SetupConveyor()
	RunService.Heartbeat:Connect(function(dt)
		for _, section in ipairs(conveyorParts) do
			if section and section.Parent then
				section.Position = section.Position - Vector3.new(0, 0, GameConfig.SpawnLane.ConveyorSpeed * dt)

				-- Loop back to start
				if section.Position.Z < GameConfig.SpawnLane.StartPosition.Z - 2 then
					section.Position = Vector3.new(
						section.Position.X,
						section.Position.Y,
						GameConfig.SpawnLane.StartPosition.Z + GameConfig.SpawnLane.Length + 2
					)
				end
			end
		end

		-- Move brainrots on conveyor
		WorldManager.UpdateConveyorBrainrots(dt)
	end)
end

-- Spawn a brainrot on the conveyor
function WorldManager.SpawnBrainrotOnLane(brainrotId: string, mutation: string?)
	local brainrotInfo = BrainrotData.GetBrainrot(brainrotId)
	if not brainrotInfo then return end

	-- Create model
	local model = Instance.new("Model")
	model.Name = brainrotId .. "_" .. (mutation or "None")
	model.Parent = spawnLane

	-- Main part
	local mainPart = Instance.new("Part")
	mainPart.Name = "Main"
	mainPart.Size = brainrotInfo.size
	mainPart.Position = Vector3.new(
		GameConfig.SpawnLane.StartPosition.X,
		GameConfig.SpawnLane.StartPosition.Y + brainrotInfo.size.Y/2 + 1,
		GameConfig.SpawnLane.StartPosition.Z + 3
	)
	mainPart.Anchored = true
	mainPart.CanCollide = false
	mainPart.Massless = true
	mainPart.Parent = model

	-- Apply appearance based on modelType
	WorldManager.ApplyBrainrotAppearance(mainPart, brainrotInfo, mutation)

	-- Add rarity glow
	local rarityData = BrainrotData.GetRarity(brainrotInfo.rarity)
	if GameConfig.Visuals.RarityGlowIntensity[brainrotInfo.rarity] > 0 then
		local glow = Instance.new("PointLight")
		glow.Color = rarityData.color
		glow.Range = 10 * GameConfig.Visuals.RarityGlowIntensity[brainrotInfo.rarity]
		glow.Brightness = 1 * GameConfig.Visuals.RarityGlowIntensity[brainrotInfo.rarity]
		glow.Parent = mainPart
	end

	-- Add mutation particles
	if mutation and mutation ~= "None" then
		local mutationData = BrainrotData.GetMutation(mutation)
		if mutationData and mutationData.particleEffect then
			WorldManager.AddMutationParticles(mainPart, mutationData.particleEffect, mutationData.color)
		end
	end

	-- Add name tag
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(200, 50)
	billboard.StudsOffset = Vector3.new(0, brainrotInfo.size.Y/2 + 2, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = mainPart

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.fromScale(1, 1)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = brainrotInfo.name .. (mutation and mutation ~= "None" and (" [" .. mutation .. "]") or "")
	nameLabel.TextColor3 = rarityData.nameColor
	nameLabel.TextSize = 18
	nameLabel.Font = Enum.Font.FredokaOne
	nameLabel.TextStrokeTransparency = 0
	nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	nameLabel.Parent = billboard

	-- Money per sec label
	local mpsLabel = Instance.new("TextLabel")
	mpsLabel.Size = UDim2.fromScale(1, 0.5)
	mpsLabel.Position = UDim2.fromScale(0, 0.5)
	mpsLabel.BackgroundTransparency = 1
	local mps = BrainrotData.CalculateMoneyPerSec(brainrotId, mutation)
	mpsLabel.Text = "+" .. Utility.FormatNumber(mps) .. "/s"
	mpsLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
	mpsLabel.TextSize = 14
	mpsLabel.Font = Enum.Font.FredokaOne
	mpsLabel.TextStrokeTransparency = 0
	mpsLabel.Parent = billboard

	-- Store data
	local brainrotData = {
		model = model,
		mainPart = mainPart,
		id = brainrotId,
		mutation = mutation or "None",
		spawnTime = os.time(),
	}

	table.insert(spawnLaneBrainrots, brainrotData)

	-- Limit brainrots on lane
	if #spawnLaneBrainrots > GameConfig.SpawnLane.MaxOnLane then
		local oldest = table.remove(spawnLaneBrainrots, 1)
		if oldest.model then oldest.model:Destroy() end
	end
end

-- Apply visual appearance to brainrot
function WorldManager.ApplyBrainrotAppearance(part: Part, brainrotInfo: table, mutation: string?)
	local mutationData = BrainrotData.GetMutation(mutation or "None")
	local rarityData = BrainrotData.GetRarity(brainrotInfo.rarity)

	-- Base color from mutation or rarity
	if mutation and mutation ~= "None" then
		part.Color = mutationData.color
		part.Material = Enum.Material.Neon
	else
		part.Color = rarityData.color
		part.Material = Enum.Material.Plastic
	end

	-- Shape based on modelType
	if brainrotInfo.modelType == "Toilet" then
		part.Shape = Enum.PartType.Cylinder
	elseif brainrotInfo.modelType == "Skull" or brainrotInfo.modelType == "SkullKing" then
		part.Shape = Enum.PartType.Ball
	elseif brainrotInfo.modelType == "Dragon" or brainrotInfo.modelType == "Titan" then
		part.Shape = Enum.PartType.Block
		-- Add wings
		local wing1 = Instance.new("Part")
		wing1.Size = Vector3.new(4, 0.5, 6)
		wing1.Position = part.Position + Vector3.new(-4, 0, 0)
		wing1.Anchored = true
		wing1.CanCollide = false
		wing1.Massless = true
		wing1.Color = part.Color
		wing1.Material = part.Material
		wing1.Parent = part.Parent

		local wing2 = Instance.new("Part")
		wing2.Size = Vector3.new(4, 0.5, 6)
		wing2.Position = part.Position + Vector3.new(4, 0, 0)
		wing2.Anchored = true
		wing2.CanCollide = false
		wing2.Massless = true
		wing2.Color = part.Color
		wing2.Material = part.Material
		wing2.Parent = part.Parent
	elseif brainrotInfo.modelType == "Singularity" then
		part.Shape = Enum.PartType.Ball
		part.Material = Enum.Material.ForceField
		part.Transparency = 0.3
	elseif brainrotInfo.modelType == "TheOne" then
		part.Shape = Enum.PartType.Ball
		part.Material = Enum.Material.ForceField
		part.Color = Color3.fromRGB(255, 0, 255)
		-- Rotating ring
		local ring = Instance.new("Part")
		ring.Shape = Enum.PartType.Cylinder
		ring.Size = Vector3.new(0.5, 16, 16)
		ring.Position = part.Position
		ring.Anchored = true
		ring.CanCollide = false
		ring.Massless = true
		ring.Material = Enum.Material.Neon
		ring.Color = Color3.fromRGB(0, 255, 255)
		ring.Orientation = Vector3.new(0, 0, 90)
		ring.Parent = part.Parent

		task.spawn(function()
			while ring.Parent do
				task.wait()
				ring.Orientation = ring.Orientation + Vector3.new(0, 2, 1)
			end
		end)
	end
end

-- Add mutation particle effect
function WorldManager.AddMutationParticles(part: Part, effectType: string, color: Color3)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Color = ColorSequence.new(color)
	emitter.Size = NumberSequence.new(0.5, 1.5)
	emitter.Lifetime = NumberRange.new(0.5, 1.5)
	emitter.Rate = 20
	emitter.Speed = NumberRange.new(2, 5)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Parent = part

	if effectType == "Fire" then
		emitter.Texture = "rbxassetid://241592303" -- Fire texture
		emitter.Color = ColorSequence.new(Color3.fromRGB(255, 150, 0), Color3.fromRGB(255, 255, 0))
	elseif effectType == "Sparkles" then
		emitter.Texture = "rbxassetid://241592303"
		emitter.LightEmission = 1
	elseif effectType == "ElectricSpark" then
		emitter.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255), Color3.fromRGB(255, 255, 255))
		emitter.LightEmission = 1
	elseif effectType == "Smoke" then
		emitter.Color = ColorSequence.new(Color3.fromRGB(50, 0, 80), Color3.fromRGB(20, 0, 40))
		emitter.Texture = "rbxassetid://241592303"
	elseif effectType == "Beam" then
		emitter.Color = ColorSequence.new(Color3.fromHSV(0, 1, 1), Color3.fromHSV(1, 1, 1))
		emitter.LightEmission = 1
	elseif effectType == "BlackHole" then
		emitter.Color = ColorSequence.new(Color3.fromRGB(20, 0, 40), Color3.fromRGB(0, 0, 0))
		emitter.Texture = "rbxassetid://241592303"
		emitter.Drag = 5
	end
end

-- Update brainrots on conveyor
function WorldManager.UpdateConveyorBrainrots(dt: number)
	for _, brainrot in ipairs(spawnLaneBrainrots) do
		if brainrot.mainPart and brainrot.mainPart.Parent then
			brainrot.mainPart.Position = brainrot.mainPart.Position - Vector3.new(0, 0, GameConfig.SpawnLane.ConveyorSpeed * dt)

			-- Apply animation
			if brainrot.id:find("Spin") then
				brainrot.mainPart.Orientation += Vector3.new(0, 90 * dt, 0)
			elseif brainrot.id:find("Float") then
				brainrot.mainPart.Position += Vector3.new(0, math.sin(os.clock() * 2) * 0.5 * dt, 0)
			elseif brainrot.id:find("Bounce") then
				brainrot.mainPart.Position += Vector3.new(0, math.abs(math.sin(os.clock() * 3)) * 1 * dt, 0)
			elseif brainrot.id:find("Pulse") then
				local scale = 1 + math.sin(os.clock() * 4) * 0.1
				brainrot.mainPart.Size = brainrot.mainPart.Size * scale
			elseif brainrot.id:find("Orbit") then
				-- Handled by main conveyor movement
			end

			-- Remove if reached end
			if brainrot.mainPart.Position.Z < GameConfig.SpawnLane.StartPosition.Z - 10 then
				brainrot.model:Destroy()
				table.remove(spawnLaneBrainrots, table.find(spawnLaneBrainrots, brainrot))
			end
		end
	end
end

-- Start hazard wave system
function WorldManager.StartHazardWaves()
	if not GameConfig.HazardWaves.Enabled then return end

	task.spawn(function()
		task.wait(GameConfig.HazardWaves.FirstWaveDelay)

		while true do
			WorldManager.TriggerRandomWave()
			task.wait(GameConfig.HazardWaves.WaveInterval)
		end
	end)
end

-- Trigger a random hazard wave
function WorldManager.TriggerRandomWave()
	local waveTypes = GameConfig.HazardWaves.Types
	local waveType = waveTypes[math.random(1, #waveTypes)]

	currentWave = {
		type = waveType,
		startTime = os.time(),
		endTime = os.time() + GameConfig.HazardWaves.WaveDuration,
		warningEndTime = os.time() + waveType.warningTime,
		inWarning = true,
	}

	-- Warning phase
	Network.FireAllClients("WaveWarning", waveType, waveType.warningTime)

	task.wait(waveType.warningTime)

	if not currentWave then return end -- Cancelled

	currentWave.inWarning = false

	-- Wave active phase
	Network.FireAllClients("WaveStarted", waveType)

	-- Damage players not in safe zones
	local damageConnection
	damageConnection = RunService.Heartbeat:Connect(function()
		if not currentWave or os.time() > currentWave.endTime then
			damageConnection:Disconnect()
			WorldManager.EndWave()
			return
		end

		for _, player in ipairs(Players:GetPlayers()) do
			if player.Character and player.Character:FindFirstChild("Humanoid") then
				local humanoid = player.Character.Humanoid
				local rootPart = player.Character:FindFirstChild("HumanoidRootPart")

				if rootPart and humanoid.Health > 0 then
					local inSafeZone = WorldManager.CheckSafeZone(rootPart.Position, waveType.safeZones)

					if not inSafeZone then
						humanoid:TakeDamage(waveType.damagePerSecond * (1/60)) -- Per frame
					end
				end
			end
		end
	end)
end

-- Check if position is in safe zone
function WorldManager.CheckSafeZone(position: Vector3, safeZoneNames: {string}): boolean
	for _, zoneName in ipairs(safeZoneNames) do
		local zone = hazardZones[zoneName]
		if zone and zone.Parent then
			local zoneCFrame = zone.CFrame
			local zoneSize = zone.Size
			local relativePos = zoneCFrame:PointToObjectSpace(position)

			if math.abs(relativePos.X) <= zoneSize.X/2 and
			   math.abs(relativePos.Y) <= zoneSize.Y/2 and
			   math.abs(relativePos.Z) <= zoneSize.Z/2 then
				return true
			end
		end
	end
	return false
end

-- End current wave
function WorldManager.EndWave()
	if currentWave then
		Network.FireAllClients("WaveEnded", currentWave.type)

		-- Award survival bonus
		for _, player in ipairs(Players:GetPlayers()) do
			local data = _G.PlayerDataCache and _G.PlayerDataCache[player]
			if data then
				data.stats.wavesSurvived += 1
				-- Small money bonus
				_G.DataManager.AddMoney(player, 100 * (data.stats.wavesSurvived + 1))
			end
		end

		currentWave = nil
	end
end

-- Get random brainrot for shop (weighted by rarity)
function WorldManager.GetRandomBrainrotForShop(playerData: table): string
	local BrainrotData = require(script.Parent.Parent.shared.BrainrotData)
	local allBrainrots = BrainrotData.GetAllSorted()

	-- Weight by rarity (higher rarity = lower chance)
	local weights = {}
	for _, brainrot in ipairs(allBrainrots) do
		local rarityOrder = BrainrotData.GetRarity(brainrot.rarity).order
		-- Base weight decreases with rarity
		local weight = 100 / (rarityOrder * 1.5)

		-- Increase weight for brainrots near player's progression
		local nextUnlock = PlayerData.GetNextUnlock(playerData, BrainrotData)
		if nextUnlock == brainrot.id then
			weight = weight * 5
		end

		weights[brainrot.id] = weight
	end

	return Utility.GetWeightedRandom(weights)
end

-- Get random mutation
function WorldManager.GetRandomMutation(playerData: table): string
	local mutationChance = playerData.mutationChance or {}
	local roll = math.random()
	local cumulative = 0

	-- Order from rarest to most common for proper weighting
	local mutations = { "Void", "Glitched", "Corrupted", "Rainbow", "Golden", "Shiny", "None" }

	for _, mutation in ipairs(mutations) do
		local chance = mutationChance[mutation] or 0
		cumulative += chance
		if roll <= cumulative then
			return mutation
		end
	end

	return "None"
end

-- Generate shop offers
function WorldManager.GenerateShopOffers(player: Player): {string}
	local data = _G.PlayerDataCache and _G.PlayerDataCache[player]
	if not data then return {} end

	local offers = {}
	for i = 1, 5 do
		local brainrotId = WorldManager.GetRandomBrainrotForShop(data)
		local mutation = WorldManager.GetRandomMutation(data)
		table.insert(offers, { id = brainrotId, mutation = mutation })
	end

	data.shopOffers = offers
	return offers
end

return WorldManager