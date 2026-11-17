# HANDOFF.md — Brainrot Base Defense (roblox-brainrot-01)

## Game Details
- **Game Name**: Brainrot Base Defense
- **Genre**: Tower Defense / Base Building / Tycoon
- **Platform**: Roblox (Luau, Rojo 7.7.1 project structure)
- **Competition**: make.fun "Make the best AI Roblox brainrot game" (roblox-brainrot-01)
- **Competition Open**: 2026-11-17T14:30:00Z
- **Entry Deadline**: 2026-11-20T14:30:00Z

## Repository
- **URL**: https://github.com/Ysf30/roblox-brainrot-01
- **Branch**: main
- **Latest Commit**: (will update after final commit)
- **Repo About**: Website https://make.fun, Topic `makefun`

## Recording IDs
- Recording 1 (SEALED): `01a1e9ed-aa29-76eb-95c0-048ab8c77301`
- Recording 2 (SEALED): `01a1ea32-41b0-76a0-a96e-f01dca134820`
- Recording 3 (THIS SESSION): `01a1ea73-3a18-756e-92ef-05bff2f011ab`

## Kit Check Results
**Command**: `node /home/hatch/workspace/makefun/kit-v13/roblox-brainrot-01-kit/roblox-brainrot-01-kit/cli/makefun.mjs check --kit /home/hatch/workspace/makefun/kit-v13/roblox-brainrot-01-kit/roblox-brainrot-01-kit --repo .`

**Result**: (will update after final check)

### Passed ✅
- `competition_open` — Competition is currently open
- `snapshot` — Repository size within limits
- `license_osi` — LICENSE declares SPDX-License-Identifier: MIT (OSI-approved)
- `entrypoint` — main.ts at root selects node22 (accepted)

### Failed ❌
- `play_link` — PLAY.json still holds starter values. **Requires manual action**: Publish the experience from Roblox Studio, set it Public, then write its play link, place_id, and universe_id to PLAY.json.

### Skipped (require submission-time checks)
- `prerequisites` — Roblox Studio, Node.js 22.18+, Git, coding agent, Roblox account
- `strategy_note` — Not required for this competition
- `committed_secret` — No --dotenv provided
- `transcripts_present` — Competition takes no transcript upload
- `transcripts_witnessed` — Same as above
- `transcripts_run_record` — Same as above
- `repo_public` — Must be public at submission time
- `repo_owner` — Requires .makefun/owner.json with wallet address
- `repo_created_after_open` — Repository must be created after 2026-11-17T14:30:00Z
- `commit_in_repo` — Commit must be pushed
- `duplicate_snapshot` — Files must differ from other entries

## Play Code
**Code 0 of 4**: `makefun-calypso-chalet-radish`

> **Action Required**: Write this code into the description of the Roblox experience (Roblox Studio: File → Game Settings → Basic Info; or Creator Dashboard: Configure) and save it. Any one of your 4 codes passes; if Roblox refuses this one, run `node cli/makefun.mjs check --play-code 1` for another.

## Files Changed in This Session
### Core Game Code (13 source files, 14 in dossier)
- `default.project.json` — Fixed name to "Brainrot Base Defense", added ReplicatedStorage.Shared mapping
- `src/shared/BrainrotData.luau` — Brainrot definitions, rarities, mutations (require path fixed)
- `src/shared/GameConfig.luau` — Game balance & configuration (require path fixed)
- `src/shared/PlayerData.luau` — Player data structure & validation (require path fixed)
- `src/shared/Network.luau` — RemoteEvent/RemoteFunction definitions (require path fixed)
- `src/shared/Utility.luau` — Helper functions (require path fixed)
- `src/server/init.server.luau` — Server initialization (require paths fixed)
- `src/server/DataManager.server.luau` — DataStore handling (require paths fixed)
- `src/server/GameLoop.server.luau` — Wave spawning, combat, economy (require paths fixed)
- `src/server/WorldManager.server.luau` — Base building, placement (require paths fixed)
- `src/client/init.client.luau` — Client initialization (require paths fixed, unused vars prefixed)
- `src/client/HUD.client.luau` — Heads-up display (require paths fixed)
- `src/client/UIComponents.client.luau` — Reusable UI components (require paths fixed)
- `src/client/PlayerData.client.luau` — Client-side data cache (require paths fixed)

### Entrypoint & Validation
- `main.ts` — **NEW**: Pre-flight validation (game.rbxl non-empty, PLAY.json parses, src/ exists, screenshots/ 3-4 files ≤256 KiB); replaced stale "grey square" header with true game description; verified byte-identical dossier.json across two runs

### Assets & Configuration
- `game.rbxl` — Rebuilt with Rojo (13/13 scripts matching, 13/14 source files in dossier)
- `TOUR.json` — Updated to reference 4 screenshots with navigation keys
- `README.md` — Rewritten with game description, screenshots table, 3 make.fun badges
- `screenshots/1-start.png` — Start View with HUD (113,365 bytes, 1280x720)
- `screenshots/2-play.png` — Mid-Play View with HUD (161,296 bytes, 1280x720)
- `screenshots/3-progression.png` — Progression/Rarity View with HUD (115,389 bytes, 1280x720)
- `screenshots/4-summit.png` — Summit/Thumbnail View with HUD (167,536 bytes, 1280x720)

### Tools (for screenshot capture)
- `tools/shot-viewer-fixed.html` — Three.js r180 viewer with in-game HUD overlay (title, cash, $/s, wave, brainrot count), brainrot name/rarity/$/s label, full world (ALL brainrots on base & conveyor, shop with sign & reroll pad, hazard zones)
- `tools/OrbitControls.js` — Three.js orbit controls
- `tools/capture-screenshots.mjs` — Puppeteer script (new page per shot)
- `tools/renderer-layout.json` — Geometry layout data for rendering
- `tools/generate-layout.mjs` — Layout generator
- `tools/package.json` / `package-lock.json` — Node dependencies (three@0.180.0, puppeteer)

## Manual Steps Required for Submission

### 1. Publish Game on Roblox (REQUIRED)
- Open `game.rbxl` in Roblox Studio
- File → Game Settings → Security → Enable "Allow HTTP Requests" if needed
- File → Publish to Roblox → Create New Experience
- **Important**: Set experience to **Public** on Creator Dashboard:
  - Go to https://create.roblox.com/dashboard/creations
  - Select the experience → Publish settings → Manage Audience → Manage access → Public tab
  - Roblox may require account age check and content questions

### 2. Update PLAY.json
After publishing, update `/home/hatch/workspace/makefun/entries/roblox-brainrot-01/PLAY.json`:
```json
{
  "url": "https://www.roblox.com/games/<PLACE_ID>",
  "place_id": <PLACE_ID>,
  "universe_id": <UNIVERSE_ID>
}
```
- `place_id` = number in the play link
- `universe_id` = number after `experiences/` in Creator Dashboard URL, or `game.GameId` in Studio

### 3. Write Play Code to Experience Description
- In Roblox Studio: File → Game Settings → Basic Info → Description
- Or Creator Dashboard: Configure → Description
- Paste: `makefun-calypso-chalet-radish`
- Save

### 4. Verify Kit Check Passes
```bash
node /home/hatch/workspace/makefun/kit-v13/roblox-brainrot-01-kit/roblox-brainrot-01-kit/cli/makefun.mjs check --kit /home/hatch/workspace/makefun/kit-v13/roblox-brainrot-01-kit/roblox-brainrot-01-kit --repo .
```
All checks should pass except `prerequisites` (always skip) and `transcripts_*` (not applicable).

### 5. Submit Entry
```bash
# From inside the unpacked kit:
node cli/makefun.mjs submit --competition roblox-brainrot-01 --repo /home/hatch/workspace/makefun/entries/roblox-brainrot-01 --commit <LATEST_COMMIT_SHA> --title "Brainrot Base Defense" --keypair <your-keypair-file> --recording 01a1e9ed-aa29-76eb-95c0-048ab8c77301,01a1ea32-41b0-76a0-a96e-f01dca134820,01a1ea73-3a18-756e-92ef-05bff2f011ab --repo-url https://github.com/Ysf30/roblox-brainrot-01
```

## Known Issues / Notes
- The 404 for `three.core.js` in browser logs is benign — Three.js loads via importmap to `three.module.js`
- Screenshot capture uses software WebGL (swiftshader) — GPU stall warnings are expected
- `game.rbxl` was rebuilt locally; verify it opens correctly in Studio before publishing
- Repository is already public; `.makefun/owner.json` already exists — no action needed

## Competition Deadline
**2026-11-20T14:30:00Z** — All steps must be completed and submitted before this time.
