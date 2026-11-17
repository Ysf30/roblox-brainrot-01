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
- **Latest Commit**: 3bc7cf8 (Complete Brainrot Base Defense game)
- **Repo About**: Website https://make.fun, Topic `makefun`

## Recording IDs
No recording IDs were generated during this session. The competition uses sealed recordings via `node cli/makefun.mjs record` which must be started from inside the unpacked kit before the agent writes any code.

## Kit Check Results
**Command**: `node /home/hatch/workspace/makefun/kit-v13/roblox-brainrot-01-kit/roblox-brainrot-01-kit/cli/makefun.mjs check --kit /home/hatch/workspace/makefun/kit-v13/roblox-brainrot-01-kit/roblox-brainrot-01-kit --repo .`

**Result**: 4 passed, 1 failed, 16 skipped, 5 checked at submission

### Passed ✅
- `competition_open` — Competition is currently open
- `snapshot` — Repository size within limits (28 files, 277,298 bytes)
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
- `commit_in_repo` — Commit must be pushed (✅ Done)
- `duplicate_snapshot` — Files must differ from other entries

## Play Code
**Code 0 of 4**: `makefun-calypso-chalet-radish`

> **Action Required**: Write this code into the description of the Roblox experience (Roblox Studio: File → Game Settings → Basic Info; or Creator Dashboard: Configure) and save it. Any one of your 4 codes passes; if Roblox refuses this one, run `node cli/makefun.mjs check --play-code 1` for another.

## Files Changed in This Session
### Core Game Code (14 source files)
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
- `src/client/Game.client.luau` — **DELETED** (starter script)

### Assets & Configuration
- `game.rbxl` — Rebuilt with Rojo (13/13 scripts matching, 13/14 source files in dossier)
- `TOUR.json` — Updated to reference 4 new screenshots with navigation keys
- `README.md` — Rewritten with game description, screenshots table, 3 make.fun badges
- `screenshots/1-start.png` — Start View (68,148 bytes)
- `screenshots/2-play.png` — Mid-Play View (66,014 bytes)
- `screenshots/3-progression.png` — Progression/Rarity View (55,982 bytes)
- `screenshots/4-summit.png` — Summit/Thumbnail View (62,167 bytes)

### Tools (for screenshot capture)
- `tools/shot-viewer-fixed.html` — Three.js r180 viewer with importmap
- `tools/OrbitControls.js` — Three.js orbit controls
- `tools/capture-screenshots.mjs` — Puppeteer script (creates new page per shot)
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

### 4. Make Repository Public
- Go to https://github.com/Ysf30/roblox-brainrot-01/settings
- Scroll to "Danger Zone" → Change repository visibility → Make public

### 5. Add Owner Wallet (.makefun/owner.json)
```bash
# From inside the unpacked kit:
node cli/makefun.mjs wallet add --keypair <your-keypair-file>
# Or create manually:
mkdir -p .makefun
echo '{"wallet": "<YOUR_WALLET_ADDRESS>"}' > .makefun/owner.json
git add .makefun/owner.json && git commit -m "Add owner wallet" && git push
```

### 6. Verify Kit Check Passes
```bash
node /home/hatch/workspace/makefun/kit-v13/roblox-brainrot-01-kit/roblox-brainrot-01-kit/cli/makefun.mjs check --kit /home/hatch/workspace/makefun/kit-v13/roblox-brainrot-01-kit/roblox-brainrot-01-kit --repo .
```
All checks should pass except `prerequisites` (always skip) and `transcripts_*` (not applicable).

### 7. Submit Entry
```bash
# From inside the unpacked kit:
node cli/makefun.mjs submit --competition roblox-brainrot-01 --repo /home/hatch/workspace/makefun/entries/roblox-brainrot-01 --commit <LATEST_COMMIT_SHA> --title "Brainrot Base Defense" --keypair <your-keypair-file>
```

## Known Issues / Notes
- The 404 for `three.core.js` in browser logs is benign — Three.js loads via importmap to `three.module.js`
- Screenshot capture uses software WebGL (swiftshader) — GPU stall warnings are expected
- `game.rbxl` was rebuilt locally; verify it opens correctly in Studio before publishing
- The starter kit's `main.ts` is sufficient for packaging (copies game.rbxl, src/, screenshots/, PLAY.json to output)

## Competition Deadline
**2026-11-20T14:30:00Z** — All steps must be completed and submitted before this time.