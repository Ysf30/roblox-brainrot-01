-- Main Server Entry Point
-- Initializes all server systems for Brainrot Base Defense

local GameLoop = require(script.GameLoop)

-- Initialize the game
GameLoop.Initialize()

print("========================================")
print("  BRAINROT BASE DEFENSE - SERVER READY")
print("========================================")
print("Game: " .. require(script.Parent.Parent.shared.GameConfig).GameName)
print("Version: " .. require(script.Parent.Parent.shared.GameConfig).Version)
print("Server started at: " .. os.date("%Y-%m-%d %H:%M:%S"))