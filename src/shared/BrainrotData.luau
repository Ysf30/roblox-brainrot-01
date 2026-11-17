-- BrainrotData: Defines all brainrot characters, rarities, mutations, and their properties
-- Single source of truth for the brainrot cast

local BrainrotData = {}

-- Rarity ladder with colors, multipliers, and display names
BrainrotData.Rarities = {
	Common = {
		order = 1,
		color = Color3.fromRGB(180, 180, 180),
		nameColor = Color3.fromRGB(200, 200, 200),
		moneyMultiplier = 1.0,
		stealChance = 0.15,
		icon = "🟢",
		displayName = "Common",
	},
	Uncommon = {
		order = 2,
		color = Color3.fromRGB(80, 200, 80),
		nameColor = Color3.fromRGB(100, 255, 100),
		moneyMultiplier = 1.5,
		stealChance = 0.12,
		icon = "🔵",
		displayName = "Uncommon",
	},
	Rare = {
		order = 3,
		color = Color3.fromRGB(80, 120, 255),
		nameColor = Color3.fromRGB(120, 160, 255),
		moneyMultiplier = 2.5,
		stealChance = 0.10,
		icon = "🟣",
		displayName = "Rare",
	},
	Epic = {
		order = 4,
		color = Color3.fromRGB(180, 80, 255),
		nameColor = Color3.fromRGB(220, 140, 255),
		moneyMultiplier = 4.0,
		stealChance = 0.08,
		icon = "🟠",
		displayName = "Epic",
	},
	Legendary = {
		order = 5,
		color = Color3.fromRGB(255, 180, 0),
		nameColor = Color3.fromRGB(255, 220, 100),
		moneyMultiplier = 7.0,
		stealChance = 0.05,
		icon = "🟡",
		displayName = "Legendary",
	},
	Mythic = {
		order = 6,
		color = Color3.fromRGB(255, 60, 120),
		nameColor = Color3.fromRGB(255, 140, 180),
		moneyMultiplier = 12.0,
		stealChance = 0.03,
		icon = "🔴",
		displayName = "Mythic",
	},
	BrainrotGod = {
		order = 7,
		color = Color3.fromRGB(255, 0, 255),
		nameColor = Color3.fromRGB(255, 180, 255),
		moneyMultiplier = 25.0,
		stealChance = 0.01,
		icon = "🌈",
		displayName = "Brainrot God",
	},
}

-- Mutation types with multipliers and visual effects
BrainrotData.Mutations = {
	None = {
		multiplier = 1.0,
		color = Color3.fromRGB(255, 255, 255),
		name = "",
		particleEffect = nil,
	},
	Shiny = {
		multiplier = 1.5,
		color = Color3.fromRGB(255, 255, 150),
		name = "Shiny",
		particleEffect = "Sparkles",
	},
	Golden = {
		multiplier = 2.5,
		color = Color3.fromRGB(255, 215, 0),
		name = "Golden",
		particleEffect = "Fire",
	},
	Rainbow = {
		multiplier = 4.0,
		color = Color3.fromHSV(math.random(), 1, 1),
		name = "Rainbow",
		particleEffect = "Beam",
	},
	Corrupted = {
		multiplier = 3.0,
		color = Color3.fromRGB(100, 0, 150),
		name = "Corrupted",
		particleEffect = "Smoke",
	},
	Glitched = {
		multiplier = 5.0,
		color = Color3.fromRGB(0, 255, 255),
		name = "Glitched",
		particleEffect = "ElectricSpark",
	},
	Void = {
		multiplier = 10.0,
		color = Color3.fromRGB(20, 0, 40),
		name = "Void",
		particleEffect = "BlackHole",
	},
}

-- Brainrot character definitions
-- Each has: baseMoneyPerSec, rarity, description, modelType, size, animations
BrainrotData.Cast = {
	-- Common (order 1-5)
	{
		id = "skibidi_toilet",
		name = "Skibidi Toilet",
		baseMoneyPerSec = 5,
		rarity = "Common",
		description = "Flushes money down the drain... into your pocket!",
		modelType = "Toilet",
		size = Vector3.new(3, 4, 3),
		animation = "Spin",
	},
	{
		id = "ohio_rizzler",
		name = "Ohio Rizzler",
		baseMoneyPerSec = 6,
		rarity = "Common",
		description = "Only in Ohio... the money flows different.",
		modelType = "Rizzler",
		size = Vector3.new(2.5, 5, 2.5),
		animation = "Float",
	},
	{
		id = "sigma_grindset",
		name = "Sigma Grindset",
		baseMoneyPerSec = 7,
		rarity = "Common",
		description = "Grind never stops. Money never sleeps.",
		modelType = "Sigma",
		size = Vector3.new(2, 5, 2),
		animation = "Pulse",
	},
	{
		id = "gyatt_master",
		name = "GYATT Master",
		baseMoneyPerSec = 8,
		rarity = "Common",
		description = "GYATT level 100: max money attraction.",
		modelType = "Gyatt",
		size = Vector3.new(3, 3, 3),
		animation = "Bounce",
	},
	{
		id = "fanum_tax",
		name = "Fanum Tax Collector",
		baseMoneyPerSec = 9,
		rarity = "Common",
		description = "Collects the tax. You keep the rest.",
		modelType = "TaxCollector",
		size = Vector3.new(2.5, 4.5, 2.5),
		animation = "March",
	},

	-- Uncommon (order 6-10)
	{
		id = "skull_emoji",
		name = "💀 Skull Emoji",
		baseMoneyPerSec = 15,
		rarity = "Uncommon",
		description = "I'm dead. Money is life.",
		modelType = "Skull",
		size = Vector3.new(3, 3, 3),
		animation = "Orbit",
	},
	{
		id = "rizz_god",
		name = "Rizz God",
		baseMoneyPerSec = 18,
		rarity = "Uncommon",
		description = "Unspoken rizz attracts unlimited currency.",
		modelType = "RizzGod",
		size = Vector3.new(2.5, 5, 2.5),
		animation = "Float",
	},
	{
		id = "mewing_master",
		name = "Mewing Master",
		baseMoneyPerSec = 20,
		rarity = "Uncommon",
		description = "Jawline so sharp it cuts through poverty.",
		modelType = "Mewing",
		size = Vector3.new(2, 4, 2),
		animation = "Pulse",
	},
	{
		id = "looksmaxxer",
		name = "Looksmaxxer",
		baseMoneyPerSec = 22,
		rarity = "Uncommon",
		description = "Maximizing gains, minimizing losses.",
		modelType = "Looksmaxxer",
		size = Vector3.new(2.5, 5, 2.5),
		animation = "Spin",
	},
	{
		id = "mogger",
		name = "The Mogger",
		baseMoneyPerSec = 25,
		rarity = "Uncommon",
		description = "Mogs the competition. Money bows down.",
		modelType = "Mogger",
		size = Vector3.new(3, 5.5, 3),
		animation = "Dominate",
	},

	-- Rare (order 11-15)
	{
		id = "brainrot_cat",
		name = "Brainrot Cat",
		baseMoneyPerSec = 40,
		rarity = "Rare",
		description = "Meow meow = money now.",
		modelType = "Cat",
		size = Vector3.new(2, 2.5, 3),
		animation = "Pounce",
	},
	{
		id = "dingus_dog",
		name = "Dingus Dog",
		baseMoneyPerSec = 45,
		rarity = "Rare",
		description = "Bork bork = profit fork.",
		modelType = "Dog",
		size = Vector3.new(2.5, 2, 3.5),
		animation = "Wag",
	},
	{
		id = "sigma_face",
		name = "Sigma Face 😎",
		baseMoneyPerSec = 50,
		rarity = "Rare",
		description = "What the sigma? What the money!",
		modelType = "SigmaFace",
		size = Vector3.new(3, 3, 1),
		animation = "Shine",
	},
	{
		id = "skull_king",
		name = "Skull King 👑",
		baseMoneyPerSec = 55,
		rarity = "Rare",
		description = "Rules the graveyard of broke players.",
		modelType = "SkullKing",
		size = Vector3.new(3.5, 4, 3.5),
		animation = "Hover",
	},
	{
		id = "rizz_phoenix",
		name = "Rizz Phoenix",
		baseMoneyPerSec = 60,
		rarity = "Rare",
		description = "Rises from the ashes of L's into W's.",
		modelType = "Phoenix",
		size = Vector3.new(4, 4, 4),
		animation = "FlameOrbit",
	},

	-- Epic (order 16-20)
	{
		id = "brainrot_dragon",
		name = "Brainrot Dragon",
		baseMoneyPerSec = 100,
		rarity = "Epic",
		description = "Breathes fire. Hoards gold. Gives you both.",
		modelType = "Dragon",
		size = Vector3.new(6, 4, 8),
		animation = "Fly",
	},
	{
		id = "ultimate_sigma",
		name = "Ultimate Sigma",
		baseMoneyPerSec = 120,
		rarity = "Epic",
		description = "The final boss of grindset. Money submits.",
		modelType = "UltimateSigma",
		size = Vector3.new(3, 6, 3),
		animation = "AuraBurst",
	},
	{
		id = "gyatt_goddess",
		name = "GYATT Goddess",
		baseMoneyPerSec = 140,
		rarity = "Epic",
		description = "Divine attraction. Wealth orbits her.",
		modelType = "Goddess",
		size = Vector3.new(3, 5.5, 3),
		animation = "DivineFloat",
	},
	{
		id = "ohio_overlord",
		name = "Ohio Overlord",
		baseMoneyPerSec = 160,
		rarity = "Epic",
		description = "Controls the Ohio dimension. Reality bends.",
		modelType = "Overlord",
		size = Vector3.new(4, 7, 4),
		animation = "RealityWarp",
	},
	{
		id = "fanum_emperor",
		name = "Fanum Emperor",
		baseMoneyPerSec = 180,
		rarity = "Epic",
		description = "Taxes the universe. You get the refund.",
		modelType = "Emperor",
		size = Vector3.new(3.5, 6, 3.5),
		animation = "RoyalDecree",
	},

	-- Legendary (order 21-24)
	{
		id = "brainrot_titan",
		name = "Brainrot Titan",
		baseMoneyPerSec = 300,
		rarity = "Legendary",
		description = "Steps on mountains. Money falls like rain.",
		modelType = "Titan",
		size = Vector3.new(10, 15, 10),
		animation = "EarthShake",
	},
	{
		id = "sigma_prime",
		name = "Sigma Prime",
		baseMoneyPerSec = 350,
		rarity = "Legendary",
		description = "The origin of all sigma. Prime money.",
		modelType = "SigmaPrime",
		size = Vector3.new(5, 8, 5),
		animation = "PrimeAura",
	},
	{
		id = "void_walker",
		name = "Void Walker",
		baseMoneyPerSec = 400,
		rarity = "Legendary",
		description = "Walks between dimensions. Steals from nothing.",
		modelType = "VoidWalker",
		size = Vector3.new(4, 7, 4),
		animation = "PhaseShift",
	},
	{
		id = "rizz_omni",
		name = "Rizz Omni",
		baseMoneyPerSec = 450,
		rarity = "Legendary",
		description = "Omnipresent rizz. All money flows here.",
		modelType = "RizzOmni",
		size = Vector3.new(6, 6, 6),
		animation = "OmniPulse",
	},

	-- Mythic (order 25-27)
	{
		id = "brainrot_archon",
		name = "Brainrot Archon",
		baseMoneyPerSec = 750,
		rarity = "Mythic",
		description = "Rules the brainrot pantheon. Kneel for wealth.",
		modelType = "Archon",
		size = Vector3.new(8, 12, 8),
		animation = "DivineRule",
	},
	{
		id = "sigma_eternal",
		name = "Sigma Eternal",
		baseMoneyPerSec = 900,
		rarity = "Mythic",
		description = "Transcends time. Infinite grind. Infinite money.",
		modelType = "EternalSigma",
		size = Vector3.new(6, 10, 6),
		animation = "EternalSpin",
	},
	{
		id = "gyatt_singularity",
		name = "GYATT Singularity",
		baseMoneyPerSec = 1100,
		rarity = "Mythic",
		description = "Gravity so strong money cannot escape.",
		modelType = "Singularity",
		size = Vector3.new(5, 5, 5),
		animation = "GravityWell",
	},

	-- Brainrot God (order 28)
	{
		id = "the_one_brainrot",
		name = "THE ONE BRAINROT",
		baseMoneyPerSec = 2500,
		rarity = "BrainrotGod",
		description = "The source of all brainrot. All memes lead here.",
		modelType = "TheOne",
		size = Vector3.new(12, 15, 12),
		animation = "RealityRewrite",
	},
}

-- Helper: Get rarity data by name
function BrainrotData.GetRarity(rarityName: string)
	return BrainrotData.Rarities[rarityName]
end

-- Helper: Get mutation data by name
function BrainrotData.GetMutation(mutationName: string)
	return BrainrotData.Mutations[mutationName]
end

-- Helper: Get brainrot by ID
function BrainrotData.GetBrainrot(id: string)
	for _, brainrot in ipairs(BrainrotData.Cast) do
		if brainrot.id == id then
			return brainrot
		end
	end
	return nil
end

-- Helper: Get brainrot by rarity
function BrainrotData.GetByRarity(rarity: string)
	local result = {}
	for _, brainrot in ipairs(BrainrotData.Cast) do
		if brainrot.rarity == rarity then
			table.insert(result, brainrot)
		end
	end
	return result
end

-- Calculate money per second with rarity and mutation
function BrainrotData.CalculateMoneyPerSec(brainrotId: string, mutation: string?): number
	local brainrot = BrainrotData.GetBrainrot(brainrotId)
	if not brainrot then return 0 end

	local rarityData = BrainrotData.GetRarity(brainrot.rarity)
	local mutationData = BrainrotData.GetMutation(mutation or "None")

	return brainrot.baseMoneyPerSec * rarityData.moneyMultiplier * mutationData.multiplier
end

-- Get steal chance for a brainrot
function BrainrotData.GetStealChance(brainrotId: string): number
	local brainrot = BrainrotData.GetBrainrot(brainrotId)
	if not brainrot then return 0 end

	local rarityData = BrainrotData.GetRarity(brainrot.rarity)
	return rarityData.stealChance
end

-- Get all brainrots sorted by rarity order then base money
function BrainrotData.GetAllSorted()
	local sorted = {}
	for _, brainrot in ipairs(BrainrotData.Cast) do
		table.insert(sorted, brainrot)
	end
	table.sort(sorted, function(a, b)
		local ra = BrainrotData.GetRarity(a.rarity).order
		local rb = BrainrotData.GetRarity(b.rarity).order
		if ra ~= rb then return ra < rb end
		return a.baseMoneyPerSec < b.baseMoneyPerSec
	end)
	return sorted
end

-- Get next tier brainrot for shop progression
function BrainrotData.GetNextTier(currentId: string?): string?
	if not currentId then
		-- Return first common
		for _, b in ipairs(BrainrotData.GetAllSorted()) do
			if b.rarity == "Common" then return b.id end
		end
	end

	local current = BrainrotData.GetBrainrot(currentId)
	if not current then return nil end

	local currentRarityOrder = BrainrotData.GetRarity(current.rarity).order
	local currentIndex = 0

	for i, b in ipairs(BrainrotData.GetAllSorted()) do
		if b.id == currentId then
			currentIndex = i
			break
		end
	end

	-- Return next in sorted list
	if currentIndex > 0 and currentIndex < #BrainrotData.Cast then
		return BrainrotData.GetAllSorted()[currentIndex + 1].id
	end

	return nil
end

return BrainrotData