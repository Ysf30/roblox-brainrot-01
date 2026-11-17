-- Utility: Common helper functions used across client and server

local Utility = {}

-- Format number with suffixes (K, M, B, T)
function Utility.FormatNumber(num: number): string
	if num < 1000 then
		return tostring(math.floor(num))
	elseif num < 1000000 then
		return string.format("%.1fK", num / 1000)
	elseif num < 1000000000 then
		return string.format("%.1fM", num / 1000000)
	elseif num < 1000000000000 then
		return string.format("%.1fB", num / 1000000000)
	else
		return string.format("%.1fT", num / 1000000000000)
	end
end

-- Format number with commas
function Utility.FormatNumberCommas(num: number): string
	local formatted = tostring(math.floor(num))
	local k = 3
	while k < #formatted do
		formatted = formatted:sub(1, #formatted - k) .. "," .. formatted:sub(#formatted - k + 1)
		k += 4
	end
	return formatted
end

-- Format time as MM:SS or HH:MM:SS
function Utility.FormatTime(seconds: number): string
	seconds = math.floor(seconds)
	if seconds < 60 then
		return string.format("%02d", seconds)
	elseif seconds < 3600 then
		local m = math.floor(seconds / 60)
		local s = seconds % 60
		return string.format("%d:%02d", m, s)
	else
		local h = math.floor(seconds / 3600)
		local m = math.floor((seconds % 3600) / 60)
		local s = seconds % 60
		return string.format("%d:%02d:%02d", h, m, s)
	end
end

-- Lerp between two values
function Utility.Lerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end

-- Clamp value between min and max
function Utility.Clamp(value: number, min: number, max: number): number
	return math.max(min, math.min(max, value))
end

-- Round to decimal places
function Utility.Round(num: number, places: number?): number
	places = places or 0
	local mult = 10 ^ places
	return math.floor(num * mult + 0.5) / mult
end

-- Get random item from weighted table
function Utility.GetWeightedRandom(weightedTable: { [any]: number }): any
	local totalWeight = 0
	for _, weight in pairs(weightedTable) do
		totalWeight += weight
	end

	local roll = math.random() * totalWeight
	local current = 0

	for item, weight in pairs(weightedTable) do
		current += weight
		if roll <= current then
			return item
		end
	end

	-- Fallback
	for item, _ in pairs(weightedTable) do
		return item
	end

	return nil
end

-- Shuffle array in place (Fisher-Yates)
function Utility.Shuffle(array: {any})
	for i = #array, 2, -1 do
		local j = math.random(i)
		array[i], array[j] = array[j], array[i]
	end
	return array
end

-- Deep copy table
function Utility.DeepCopy(original: table): table
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			copy[k] = Utility.DeepCopy(v)
		else
			copy[k] = v
		end
	end
	return copy
end

-- Merge tables (deep)
function Utility.DeepMerge(target: table, source: table): table
	for k, v in pairs(source) do
		if type(v) == "table" and type(target[k]) == "table" then
			Utility.DeepMerge(target[k], v)
		else
			target[k] = v
		end
	end
	return target
end

-- Check if table contains value
function Utility.TableContains(tbl: table, value: any): boolean
	for _, v in pairs(tbl) do
		if v == value then return true end
	end
	return false
end

-- Get table length (works with non-array tables)
function Utility.TableLength(tbl: table): number
	local count = 0
	for _ in pairs(tbl) do count += 1 end
	return count
end

-- Get keys of table
function Utility.GetKeys(tbl: table): {any}
	local keys = {}
	for k in pairs(tbl) do table.insert(keys, k) end
	return keys
end

-- Get values of table
function Utility.GetValues(tbl: table): {any}
	local values = {}
	for _, v in pairs(tbl) do table.insert(values, v) end
	return values
end

-- Format money per second display
function Utility.FormatMoneyPerSec(mps: number): string
	return Utility.FormatNumber(mps) .. "/s"
end

-- Generate unique ID
function Utility.GenerateId(prefix: string?): string
	prefix = prefix or "id"
	return prefix .. "_" .. os.time() .. "_" .. math.random(1000, 9999)
end

-- Color3 to hex string
function Utility.Color3ToHex(color: Color3): string
	return string.format("#%02X%02X%02X",
		math.floor(color.R * 255),
		math.floor(color.G * 255),
		math.floor(color.B * 255)
	)
end

-- Hex string to Color3
function Utility.HexToColor3(hex: string): Color3
	hex = hex:gsub("#", "")
	local r = tonumber(hex:sub(1, 2), 16) / 255
	local g = tonumber(hex:sub(3, 4), 16) / 255
	local b = tonumber(hex:sub(5, 6), 16) / 255
	return Color3.new(r, g, b)
end

-- Interpolate Color3
function Utility.LerpColor(a: Color3, b: Color3, t: number): Color3
	return Color3.new(
		Utility.Lerp(a.R, b.R, t),
		Utility.Lerp(a.G, b.G, t),
		Utility.Lerp(a.B, b.B, t)
	)
end

-- Create a random Color3
function Utility.RandomColor(): Color3
	return Color3.fromHSV(math.random(), 0.7 + math.random() * 0.3, 0.8 + math.random() * 0.2)
end

-- Check if position is within bounds
function Utility.IsInBounds(pos: Vector3, min: Vector3, max: Vector3): boolean
	return pos.X >= min.X and pos.X <= max.X and
	       pos.Y >= min.Y and pos.Y <= max.Y and
	       pos.Z >= min.Z and pos.Z <= max.Z
end

-- Get distance between two Vector3s (2D, ignoring Y)
function Utility.Distance2D(a: Vector3, b: Vector3): number
	local dx = a.X - b.X
	local dz = a.Z - b.Z
	return math.sqrt(dx * dx + dz * dz)
end

-- Format large numbers for UI (compact)
function Utility.FormatCompact(num: number): string
	if num >= 1000000000000 then
		return string.format("%.2fT", num / 1000000000000)
	elseif num >= 1000000000 then
		return string.format("%.2fB", num / 1000000000)
	elseif num >= 1000000 then
		return string.format("%.2fM", num / 1000000)
	elseif num >= 1000 then
		return string.format("%.1fK", num / 1000)
	else
		return tostring(math.floor(num))
	end
end

-- Table to string for debugging
function Utility.TableToString(tbl: table, indent: number?): string
	indent = indent or 0
	local spacing = string.rep("  ", indent)
	local result = "{\n"
	for k, v in pairs(tbl) do
		local key = type(k) == "string" and k or "[" .. tostring(k) .. "]"
		if type(v) == "table" then
			result ..= spacing .. "  " .. key .. " = " .. Utility.TableToString(v, indent + 1) .. ",\n"
		elseif type(v) == "string" then
			result ..= spacing .. "  " .. key .. " = \"" .. v .. "\",\n"
		else
			result ..= spacing .. "  " .. key .. " = " .. tostring(v) .. ",\n"
		end
	end
	result ..= spacing .. "}"
	return result
end

-- Safe require with fallback
function Utility.SafeRequire(moduleScript: ModuleScript, fallback: any?): any
	local success, result = pcall(function() return require(moduleScript) end)
	if success then return result end
	warn("Failed to require " .. moduleScript:GetFullName() .. ": " .. tostring(result))
	return fallback
end

-- Debounce function
function Utility.Debounce(func: (...any) -> (), delay: number): (...any) -> ()
	local lastCall = 0
	return function(...)
		local now = os.clock()
		if now - lastCall >= delay then
			lastCall = now
			return func(...)
		end
	end
end

-- Throttle function
function Utility.Throttle(func: (...any) -> (), interval: number): (...any) -> ()
	local lastCall = 0
	return function(...)
		local now = os.clock()
		if now - lastCall >= interval then
			lastCall = now
			return func(...)
		end
	end
end

return Utility