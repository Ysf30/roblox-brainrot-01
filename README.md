# Brainrot Base Defense

**Brainrot Base Defense** is a tower defense / base building Roblox game where you collect and place "brainrot" meme characters to defend your base core against waves of enemies. Earn money, upgrade your base, rebirth for permanent bonuses, and build the ultimate brainrot army!

## Gameplay

- **Collect Brainrots**: Buy brainrot characters from the shop — each has a unique money-per-second rate and rarity (Common → Mythic → Void)
- **Place Strategically**: Place brainrots on your 4×4 base grid to generate passive income
- **Defend the Core**: Waves of enemies spawn from the conveyor lane and march toward your base core — your placed brainrots attack automatically
- **Upgrade & Rebirth**: Spend money on upgrades (Base Defense, Money Multiplier, Spawn Rate, Base Size, Offline Time, Steal Power). Rebirth to reset with permanent bonuses and unlock rarer mutations!
- **Mutations**: Brainrots can have mutations (Shiny, Golden, Rainbow, Corrupted, Glitched, Void) that massively boost their earnings
- **Steal Mechanics**: Risk/reward — attempt to steal other players' brainrots for big payouts

## Screenshots

| Start View | Mid-Play View | Progression View | Summit View |
|------------|---------------|------------------|-------------|
| ![1-start](screenshots/1-start.png) | ![2-play](screenshots/2-play.png) | ![3-progression](screenshots/3-progression.png) | ![4-summit](screenshots/4-summit.png) |

## Badges

![make.fun](https://img.shields.io/badge/make.fun-roblox--brainrot--01-purple?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSI+PHBhdGggZD0iTTEyIDJMMiA3djEwbDEwIDV2N2w2LTMuNUw5IDlsNi0zLjVWMkwxMiAyWiIgc3Ryb2tlPSIjYTg1NWY3IiBzdHJva2Utd2lkdGg9IjIiLz48L3N2Zz4=)
![Roblox](https://img.shields.io/badge/Roblox-Game-red?style=for-the-badge&logo=roblox)
![Luau](https://img.shields.io/badge/Luau-Scripting-blue?style=for-the-badge)

## Technical Details

- **Framework**: Rojo 7.7.1 project structure
- **Language**: Luau (Roblox TypeScript)
- **Architecture**: Client-server with ReplicatedStorage shared modules
- **Networking**: RemoteEvents/RemoteFunctions for client-server communication
- **Data Persistence**: DataStore with offline progress calculation

## Project Structure

```
src/
├── shared/           # Shared modules (both client & server)
│   ├── BrainrotData.luau    # Brainrot definitions, rarities, mutations
│   ├── GameConfig.luau      # Game balance & configuration
│   ├── PlayerData.luau      # Player data structure & validation
│   ├── Network.luau         # RemoteEvent/RemoteFunction definitions
│   └── Utility.luau         # Helper functions
├── server/           # ServerScriptService scripts
│   ├── init.server.luau     # Server initialization
│   ├── DataManager.server.luau   # DataStore handling
│   ├── GameLoop.server.luau      # Wave spawning, combat, economy
│   └── WorldManager.server.luau  # Base building, placement
└── client/           # StarterPlayerScripts
    ├── init.client.luau     # Client initialization
    ├── HUD.client.luau      # Heads-up display
    ├── UIComponents.client.luau  # Reusable UI components
    └── PlayerData.client.luau    # Client-side data cache
```

## Development

```bash
# Build the game.rbxl from source
rojo build -o game.rbxl

# Run the screenshot capture (requires Chrome)
cd tools && node capture-screenshots.mjs

# Package for submission
mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts
```

## Submission

This entry is submitted for the **make.fun "Make the best AI Roblox brainrot game" bounty (roblox-brainrot-01)**.