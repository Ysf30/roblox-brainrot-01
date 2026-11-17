-- PlayerData: Player data structure and management
-- Handles serialization, defaults, and validation

local GameConfig = require(game:GetService("ReplicatedStorage").Shared.GameConfig)

local PlayerData = {}

-- Default player data structure
function PlayerData.GetDefault(): table
	return {
		-- Core progression
		money = GameConfig.Money.StartingMoney,
		totalMoneyEarned = 0,
		rebirths = 0,

		-- Base
		baseLevel = 1,
		baseGridSize = GameConfig.BasePlot.GridSize, -- 4x4 = 16
		baseDefenseLevel = 0,

		-- Brainrot collection (on base)
		-- Array of { id, mutation, position, placedTime }
		brainrots = {},

		-- Owned brainrots (in inventory, not placed)
		inventory = {},

		-- Upgrades
		upgrades = {
			BaseDefense = 0,
			MoneyMultiplier = 0,
			SpawnRate = 0,
			BaseSize = 0,
			OfflineTime = 0,
			StealPower = 0,
		},

		-- Shop state
		shopOffers = {}, -- Current brainrots in shop
		shopRerollsUsed = 0,
		lastRerollTime = 0,
		freeRerolls = GameConfig.Shop.FreeRerollsPerRebirth,

		-- Statistics
		stats = {
			brainrotsCollected = 0,
			brainrotsStolen = 0,
			brainrotsLost = 0,
			wavesSurvived = 0,
			totalStealAttempts = 0,
			successfulSteals = 0,
			highestMoneyPerSec = 0,
			playTime = 0,
		},

		-- Mutation chances (increases with rebirths)
		mutationChance = {
			Shiny = 0.05,
			Golden = 0.02,
			Rainbow = 0.005,
			Corrupted = 0.003,
			Glitched = 0.001,
			Void = 0.0001,
		},

		-- Timestamps
		lastSaveTime = os.time(),
		lastOnlineTime = os.time(),
		joinTime = os.time(),

		-- Settings
		settings = {
			autoCollect = true,
			showDamageNumbers = true,
			particleQuality = "High",
			notificationsEnabled = true,
		},
	}
end

-- Validate and sanitize player data
function PlayerData.Validate(data: table): table
	local default = PlayerData.GetDefault()

	-- Ensure all required fields exist
	for key, value in pairs(default) do
		if data[key] == nil then
			data[key] = value
		elseif type(value) == "table" and type(data[key]) == "table" then
			-- Recursively validate nested tables
			data[key] = PlayerData.ValidateNested(data[key], value)
		end
	end

	-- Sanitize numeric values
	data.money = math.max(0, math.floor(data.money or 0))
	data.totalMoneyEarned = math.max(0, math.floor(data.totalMoneyEarned or 0))
	data.rebirths = math.max(0, math.min(GameConfig.Rebirth.MaxRebirths, math.floor(data.rebirths or 0)))
	data.baseLevel = math.max(1, math.floor(data.baseLevel or 1))
	data.baseGridSize = math.max(4, math.floor(data.baseGridSize or 4))
	data.baseDefenseLevel = math.max(0, math.floor(data.baseDefenseLevel or 0))

	-- Validate upgrades
	for upgradeName, upgradeConfig in pairs(GameConfig.Upgrades) do
		if data.upgrades[upgradeName] == nil then
			data.upgrades[upgradeName] = 0
		else
			data.upgrades[upgradeName] = math.max(0, math.min(upgradeConfig.maxLevel, math.floor(data.upgrades[upgradeName])))
		end
	end

	-- Validate brainrots array
	if type(data.brainrots) ~= "table" then
		data.brainrots = {}
	end

	-- Validate inventory
	if type(data.inventory) ~= "table" then
		data.inventory = {}
	end

	-- Validate shop offers
	if type(data.shopOffers) ~= "table" then
		data.shopOffers = {}
	end

	data.shopRerollsUsed = math.max(0, math.floor(data.shopRerollsUsed or 0))
	data.lastRerollTime = math.max(0, math.floor(data.lastRerollTime or 0))
	data.freeRerolls = math.max(0, math.floor(data.freeRerolls or 0))

	-- Validate stats
	if type(data.stats) ~= "table" then
		data.stats = PlayerData.GetDefault().stats
	end
	for statName, _ in pairs(PlayerData.GetDefault().stats) do
		if data.stats[statName] == nil then
			data.stats[statName] = 0
		else
			data.stats[statName] = math.max(0, math.floor(data.stats[statName]))
		end
	end

	-- Validate mutation chances
	if type(data.mutationChance) ~= "table" then
		data.mutationChance = PlayerData.GetDefault().mutationChance
	end

	-- Validate timestamps
	data.lastSaveTime = math.max(0, math.floor(data.lastSaveTime or os.time()))
	data.lastOnlineTime = math.max(0, math.floor(data.lastOnlineTime or os.time()))
	data.joinTime = math.max(0, math.floor(data.joinTime or os.time()))

	-- Validate settings
	if type(data.settings) ~= "table" then
		data.settings = PlayerData.GetDefault().settings
	end

	return data
end

-- Recursive validation for nested tables
function PlayerData.ValidateNested(current: table, default: table): table
	local result = {}
	for key, value in pairs(default) do
		if current[key] == nil then
			result[key] = value
		elseif type(value) == "table" and type(current[key]) == "table" then
			result[key] = PlayerData.ValidateNested(current[key], value)
		else
			result[key] = current[key]
		end
	end
	return result
end

-- Calculate current money per second from placed brainrots
function PlayerData.CalculateMoneyPerSec(data: table, BrainrotData: any): number
	local total = 0
	local BrainrotDataModule = BrainrotData or require(game:GetService("ReplicatedStorage").Shared.BrainrotData)

	for _, brainrot in ipairs(data.brainrots) do
		local moneyPerSec = BrainrotDataModule.CalculateMoneyPerSec(brainrot.id, brainrot.mutation)
		-- Apply global money multiplier upgrade
		local multiplierLevel = data.upgrades.MoneyMultiplier or 0
		local multiplier = 1 + (multiplierLevel * GameConfig.Upgrades.MoneyMultiplier.multiplierPerLevel)
		-- Apply rebirth bonus
		local rebirthBonus = 1 + (data.rebirths * GameConfig.Rebirth.Rewards.moneyMultiplier)
		total += moneyPerSec * multiplier * rebirthBonus
	end

	return math.floor(total)
end

-- Calculate total money per second including offline bonus
function PlayerData.CalculateTotalMoneyPerSec(data: table, BrainrotData: any): number
	return PlayerData.CalculateMoneyPerSec(data, BrainrotData)
end

-- Get next brainrot to unlock for shop
function PlayerData.GetNextUnlock(data: table, BrainrotData: any): string?
	local BrainrotDataModule = BrainrotData or require(game:GetService("ReplicatedStorage").Shared.BrainrotData)

	-- Find highest rarity brainrot owned
	local highestRarityOrder = 0
	for _, brainrot in ipairs(data.brainrots) do
		local bData = BrainrotDataModule.GetBrainrot(brainrot.id)
		if bData then
			local rarityData = BrainrotDataModule.GetRarity(bData.rarity)
			if rarityData.order > highestRarityOrder then
				highestRarityOrder = rarityData.order
			end
		end
	end

	-- Also check inventory
	for _, brainrot in ipairs(data.inventory) do
		local bData = BrainrotDataModule.GetBrainrot(brainrot.id)
		if bData then
			local rarityData = BrainrotDataModule.GetRarity(bData.rarity)
			if rarityData.order > highestRarityOrder then
				highestRarityOrder = rarityData.order
			end
		end
	end

	-- Return next rarity tier
	for _, b in ipairs(BrainrotDataModule.GetAllSorted()) do
		local rarityData = BrainrotDataModule.GetRarity(b.rarity)
		if rarityData.order > highestRarityOrder then
			return b.id
		end
	end

	return nil
end

-- Calculate offline progress
function PlayerData.CalculateOfflineProgress(data: table, BrainrotData: any): number
	local now = os.time()
	local offlineSeconds = now - (data.lastOnlineTime or now)

	-- Cap at configured maximum
	local maxOffline = GameConfig.Money.OfflineProgressCap
	local offlineLevel = data.upgrades.OfflineTime or 0
	maxOffline = math.floor(maxOffline * (GameConfig.Upgrades.OfflineTime.timeMultiplierPerLevel ^ offlineLevel))

	offlineSeconds = math.min(offlineSeconds, maxOffline)

	if offlineSeconds <= 0 then return 0 end

	local moneyPerSec = PlayerData.CalculateMoneyPerSec(data, BrainrotData)
	return math.floor(moneyPerSec * offlineSeconds)
end

-- Apply rebirth bonuses to mutation chances
function PlayerData.ApplyRebirthBonuses(data: table)
	local rebirths = data.rebirths or 0
	local bonus = rebirths * GameConfig.Rebirth.Rewards.unlockMutationChance

	data.mutationChance.Shiny = math.min(0.5, 0.05 + bonus)
	data.mutationChance.Golden = math.min(0.3, 0.02 + bonus * 0.5)
	data.mutationChance.Rainbow = math.min(0.1, 0.005 + bonus * 0.2)
	data.mutationChance.Corrupted = math.min(0.05, 0.003 + bonus * 0.1)
	data.mutationChance.Glitched = math.min(0.02, 0.001 + bonus * 0.05)
	data.mutationChance.Void = math.min(0.005, 0.0001 + bonus * 0.01)

	data.freeRerolls = GameConfig.Shop.FreeRerollsPerRebirth + (rebirths * GameConfig.Rebirth.Rewards.freeRerolls)
end

-- Serialize for DataStore (remove functions, ensure JSON compatible)
function PlayerData.Serialize(data: table): table
	local serialized = {}
	for key, value in pairs(data) do
		if type(value) ~= "function" then
			if type(value) == "table" then
				serialized[key] = PlayerData.SerializeTable(value)
			else
				serialized[key] = value
			end
		end
	end
	return serialized
end

function PlayerData.SerializeTable(tbl: table): table
	local result = {}
	for k, v in pairs(tbl) do
		if type(v) ~= "function" then
			if type(v) == "table" then
				result[k] = PlayerData.SerializeTable(v)
			else
				result[k] = v
			end
		end
	end
	return result
end

-- Deep copy for safe manipulation
function PlayerData.DeepCopy(data: table): table
	local copy = {}
	for k, v in pairs(data) do
		if type(v) == "table" then
			copy[k] = PlayerData.DeepCopy(v)
		else
			copy[k] = v
		end
	end
	return copy
end

return PlayerData