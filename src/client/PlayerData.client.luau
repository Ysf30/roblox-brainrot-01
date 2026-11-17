-- PlayerData (Client): Client-side player data cache and helpers

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(script.Parent.Parent.shared.GameConfig)
local BrainrotData = require(script.Parent.Parent.shared.BrainrotData)
local Utility = require(script.Parent.Parent.shared.Utility)

local PlayerDataClient = {}

-- Client data cache
local clientData = {}

-- Update client data from server
function PlayerDataClient.UpdateData(data: table)
	clientData = data or {}
end

-- Get current data
function PlayerDataClient.GetData(): table
	return clientData
end

-- Get money
function PlayerDataClient.GetMoney(): number
	return clientData.money or 0
end

-- Get money per second
function PlayerDataClient.GetMoneyPerSec(): number
	return PlayerDataClient.CalculateMoneyPerSec()
end

-- Calculate money per second from client data
function PlayerDataClient.CalculateMoneyPerSec(): number
	local total = 0

	for _, brainrot in ipairs(clientData.brainrots or {}) do
		local moneyPerSec = BrainrotData.CalculateMoneyPerSec(brainrot.id, brainrot.mutation)
		local multiplierLevel = (clientData.upgrades and clientData.upgrades.MoneyMultiplier) or 0
		local multiplier = 1 + (multiplierLevel * GameConfig.Upgrades.MoneyMultiplier.multiplierPerLevel)
		local rebirthBonus = 1 + ((clientData.rebirths or 0) * GameConfig.Rebirth.Rewards.moneyMultiplier)
		total += moneyPerSec * multiplier * rebirthBonus
	end

	return math.floor(total)
end

-- Get brainrots on base
function PlayerDataClient.GetBaseBrainrots(): {table}
	return clientData.brainrots or {}
end

-- Get inventory
function PlayerDataClient.GetInventory(): {table}
	return clientData.inventory or {}
end

-- Get upgrades
function PlayerDataClient.GetUpgrades(): table
	return clientData.upgrades or {}
end

-- Get rebirths
function PlayerDataClient.GetRebirths(): number
	return clientData.rebirths or 0
end

-- Get shop offers
function PlayerDataClient.GetShopOffers(): {table}
	return clientData.shopOffers or {}
end

-- Get next unlock
function PlayerDataClient.GetNextUnlock(): string?
	local BrainrotDataModule = require(script.Parent.Parent.shared.BrainrotData)

	-- Find highest rarity owned
	local highestRarityOrder = 0
	for _, brainrot in ipairs(clientData.brainrots or {}) do
		local bData = BrainrotDataModule.GetBrainrot(brainrot.id)
		if bData then
			local rarityData = BrainrotDataModule.GetRarity(bData.rarity)
			if rarityData.order > highestRarityOrder then
				highestRarityOrder = rarityData.order
			end
		end
	end

	for _, brainrot in ipairs(clientData.inventory or {}) do
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

-- Get base grid size
function PlayerDataClient.GetBaseGridSize(): number
	return clientData.baseGridSize or GameConfig.BasePlot.GridSize
end

-- Get base defense level
function PlayerDataClient.GetBaseDefenseLevel(): number
	return clientData.baseDefenseLevel or 0
end

-- Format money for display
function PlayerDataClient.FormatMoney(amount: number): string
	return Utility.FormatNumber(amount)
end

-- Format money per second for display
function PlayerDataClient.FormatMoneyPerSec(mps: number): string
	return Utility.FormatNumber(mps) .. "/s"
end

return PlayerDataClient