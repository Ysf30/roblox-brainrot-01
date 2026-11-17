-- Main Server Entry Point
-- Initializes all server systems for Brainrot Base Defense

local GameLoop = require(script.GameLoop)

-- Initialize the game
GameLoop.Initialize()

print("========================================")
print("  BRAINROT BASE DEFENSE - SERVER READY")
print("========================================")
print("Game: " .. require(game:GetService("ReplicatedStorage").Shared.GameConfig).GameName)
print("Version: " .. require(game:GetService("ReplicatedStorage").Shared.GameConfig).Version)
print("Server started at: " .. os.date("%Y-%m-%d %H:%M:%S"))