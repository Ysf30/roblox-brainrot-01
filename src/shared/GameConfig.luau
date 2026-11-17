-- GameConfig: Central configuration for the brainrot game
-- All tunable constants in one place

local GameConfig = {}

-- Game identity
GameConfig.GameName = "Brainrot Base Defense"
GameConfig.Version = "1.0.0"

-- Base plot settings
GameConfig.BasePlot = {
	Size = Vector3.new(60, 1, 60),
	Position = Vector3.new(0, 0.5, 0),
	GridSize = 4, -- 4x4 grid for placing brainrots
	CellSize = 12,
	MaxBrainrots = 16,
}

-- Spawn lane / conveyor settings
GameConfig.SpawnLane = {
	Length = 80,
	Width = 12,
	Height = 5,
	StartPosition = Vector3.new(-50, 3, 0),
	ConveyorSpeed = 8,
	SpawnInterval = 15, -- seconds between spawns
	MaxOnLane = 6,
}

-- Shop settings
GameConfig.Shop = {
	Position = Vector3.new(0, 3, -40),
	Size = Vector3.new(20, 6, 15),
	RerollCost = 500,
	RerollCooldown = 30, -- seconds
	FreeRerollsPerRebirth = 3,
}

-- Money system
GameConfig.Money = {
	StartingMoney = 1000,
	TickInterval = 1, -- seconds
	OfflineProgressCap = 3600, -- max seconds of offline progress (1 hour)
	StealCooldown = 30, -- seconds between steal attempts
	StealSuccessBaseChance = 0.3,
	DefenseReductionPerLevel = 0.15,
}

-- Hazard wave settings
GameConfig.HazardWaves = {
	Enabled = true,
	FirstWaveDelay = 120, -- seconds after game start
	WaveInterval = 180, -- seconds between waves
	WaveDuration = 30, -- seconds each wave lasts
	Types = {
		{
			id = "tsunami",
			name = "TSUNAMI WAVE",
			description = "A massive wave sweeps the map! Reach high ground!",
			warningTime = 10,
			damagePerSecond = 50,
			safeZones = { "HighGround", "BaseRoof" },
			color = Color3.fromRGB(0, 100, 255),
		},
		{
			id = "meteor_shower",
			name = "METEOR SHOWER",
			description = "Meteors rain from the sky! Dodge or hide!",
			warningTime = 8,
			damagePerSecond = 30,
			safeZones = { "Underground", "BaseShelter" },
			color = Color3.fromRGB(255, 100, 0),
		},
		{
			id = "void_rift",
			name = "VOID RIFT",
			description = "Reality tears apart! Stay in the light!",
			warningTime = 12,
			damagePerSecond = 40,
			safeZones = { "LightZone", "BaseCore" },
			color = Color3.fromRGB(100, 0, 200),
		},
		{
			id = "glitch_storm",
			name = "GLITCH STORM",
			description = "Space corrupts! Find stable ground!",
			warningTime = 6,
			damagePerSecond = 35,
			safeZones = { "StablePlatform", "BaseAnchor" },
			color = Color3.fromRGB(0, 255, 255),
		},
	},
}

-- Upgrade system
GameConfig.Upgrades = {
	BaseDefense = {
		maxLevel = 10,
		baseCost = 1000,
		costMultiplier = 2.0,
		stealResistancePerLevel = 0.1,
	},
	MoneyMultiplier = {
		maxLevel = 10,
		baseCost = 2000,
		costMultiplier = 2.5,
		multiplierPerLevel = 0.15,
	},
	SpawnRate = {
		maxLevel = 8,
		baseCost = 3000,
		costMultiplier = 3.0,
		intervalReductionPerLevel = 1.5, -- seconds
	},
	BaseSize = {
		maxLevel = 5,
		baseCost = 5000,
		costMultiplier = 4.0,
		cellIncreasePerLevel = 4, -- +4 cells per level
	},
	OfflineTime = {
		maxLevel = 6,
		baseCost = 1500,
		costMultiplier = 2.2,
		timeMultiplierPerLevel = 1.5,
	},
	StealPower = {
		maxLevel = 8,
		baseCost = 2500,
		costMultiplier = 2.8,
		chanceIncreasePerLevel = 0.05,
	},
}

-- Rebirth system
GameConfig.Rebirth = {
	Requirements = {
		{ rebirth = 1, money = 100000, brainrots = 10 },
		{ rebirth = 2, money = 1000000, brainrots = 12 },
		{ rebirth = 3, money = 10000000, brainrots = 14 },
		{ rebirth = 4, money = 100000000, brainrots = 15 },
		{ rebirth = 5, money = 1000000000, brainrots = 16 },
	},
	Rewards = {
		moneyMultiplier = 0.5, -- +50% per rebirth
		startingMoneyMultiplier = 2.0, -- 2x starting money per rebirth
		unlockMutationChance = 0.02, -- +2% mutation chance per rebirth
		freeRerolls = 1, -- +1 free reroll per rebirth
	},
	MaxRebirths = 10,
}

-- Visual/Effects
GameConfig.Visuals = {
	MoneyParticleLifetime = 0.5,
	RarityGlowIntensity = {
		Common = 0,
		Uncommon = 0.3,
		Rare = 0.5,
		Epic = 0.7,
		Legendary = 1.0,
		Mythic = 1.5,
		BrainrotGod = 2.5,
	},
	MutationParticles = {
		Shiny = "Sparkles",
		Golden = "Fire",
		Rainbow = "Beam",
		Corrupted = "Smoke",
		Glitched = "ElectricSpark",
		Void = "BlackHole",
	},
}

-- UI Settings
GameConfig.UI = {
	HUDUpdateInterval = 0.1,
	NotificationDuration = 3,
	MaxNotifications = 5,
	ShopRefreshAnimationTime = 0.5,
}

-- Save system
GameConfig.Save = {
	AutoSaveInterval = 30, -- seconds
	DataStoreName = "BrainrotBaseDefense_v1",
	BackupEnabled = true,
}

-- Admin/Dev
GameConfig.Admin = {
	TestMode = false,
	GiveMoneyCommand = "givemoney",
	GiveBrainrotCommand = "givebrainrot",
	SetRebirthCommand = "setrebirth",
}

return GameConfig