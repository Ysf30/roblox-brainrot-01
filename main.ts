// A working roblox-brainrot-01 entry (Node 22, standard library only): the game is this directory's Rojo
// project, built into game.rbxl with `rojo build default.project.json --output game.rbxl`, and the program
// hands it in. It copies game.rbxl, src/, screenshots/ and PLAY.json from beside this file to /output and
// writes /output/dossier.json, the summary the judge reads, with the vendored make.fun library.
//
// Game: Brainrot Base Defense — a 3D tower defense / base building / tycoon where players collect absurd
// meme-born brainrot characters (Skibidi Toilet, Ohio Rizzler, Sigma Grindset, up to THE ONE BRAINROT),
// place them on a gridded base to earn money per second, buy higher-rarity units from a shop, and survive
// periodic steal waves that threaten the base. 28 unique brainrots across 7 rarities (Common → Brainrot God),
// 7 mutations (Shiny, Golden, Rainbow, Corrupted, Glitched, Void), a conveyor spawn lane, hazard zones,
// and a rebirth progression ladder. Built with a clean client-server split over Rojo 7.7.1.
//
// Pre-flight validation runs before any copying and throws a clear error naming the problem:
//   - game.rbxl exists and is non-empty
//   - PLAY.json exists and parses as JSON
//   - src/ exists as a directory
//   - screenshots/ holds 3–4 files each ≤ 262144 bytes (256 KiB)
// On valid input the behavior is byte-identical to the original starter.
//
// Outside the grader's container, MAKEFUN_OUTPUT_DIR stands in for /output:
//   mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts

import { copyFileSync, cpSync, existsSync, mkdirSync, writeFileSync, readFileSync, statSync, readdirSync } from 'node:fs';
import { basename, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildDossier } from './vendor/makefun-roblox.ts';

const here = fileURLToPath(new URL('.', import.meta.url));
const out = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

/** cpSync's filter: leave out every file and directory whose name starts with a dot (.gitkeep, .DS_Store, .git). */
const notDotted = (path: string): boolean => !basename(path).startsWith('.');

/** Pre-flight validation — throws a descriptive error if any required input is missing or invalid. */
function validateInputs(): void {
  // game.rbxl exists and is non-empty
  const rbxlPath = join(here, 'game.rbxl');
  if (!existsSync(rbxlPath)) {
    throw new Error('Pre-flight failed: game.rbxl does not exist');
  }
  const rbxlStat = statSync(rbxlPath);
  if (rbxlStat.size === 0) {
    throw new Error('Pre-flight failed: game.rbxl is empty (0 bytes)');
  }

  // PLAY.json exists and parses as JSON
  const playPath = join(here, 'PLAY.json');
  if (!existsSync(playPath)) {
    throw new Error('Pre-flight failed: PLAY.json does not exist');
  }
  try {
    JSON.parse(readFileSync(playPath, 'utf8'));
  } catch (e) {
    throw new Error(`Pre-flight failed: PLAY.json is not valid JSON — ${(e as Error).message}`);
  }

  // src/ exists as a directory
  const srcPath = join(here, 'src');
  if (!existsSync(srcPath)) {
    throw new Error('Pre-flight failed: src/ directory does not exist');
  }
  const srcStat = statSync(srcPath);
  if (!srcStat.isDirectory()) {
    throw new Error('Pre-flight failed: src/ exists but is not a directory');
  }

  // screenshots/ holds 3–4 files each ≤ 262144 bytes
  const screenshotsPath = join(here, 'screenshots');
  if (!existsSync(screenshotsPath)) {
    throw new Error('Pre-flight failed: screenshots/ directory does not exist');
  }
  const shotEntries = readdirSync(screenshotsPath, { withFileTypes: true })
    .filter(d => d.isFile() && !d.name.startsWith('.'));
  if (shotEntries.length < 3 || shotEntries.length > 4) {
    throw new Error(`Pre-flight failed: screenshots/ must contain 3–4 files (found ${shotEntries.length})`);
  }
  for (const entry of shotEntries) {
    const stat = statSync(join(screenshotsPath, entry.name));
    if (stat.size > 262144) {
      throw new Error(`Pre-flight failed: screenshots/${entry.name} is ${stat.size} bytes (> 262144 max)`);
    }
  }
}

// Run validation first — throws on any problem before any copying
validateInputs();

copyFileSync(join(here, 'game.rbxl'), join(out, 'game.rbxl'));
copyFileSync(join(here, 'PLAY.json'), join(out, 'PLAY.json'));
cpSync(join(here, 'src'), join(out, 'src'), { recursive: true, filter: notDotted });
mkdirSync(join(out, 'screenshots'), { recursive: true });
if (existsSync(join(here, 'screenshots'))) cpSync(join(here, 'screenshots'), join(out, 'screenshots'), { recursive: true, filter: notDotted });

// The scorer's own caps (reference/gate.json): only text_max_bytes shapes the bytes; the others refuse an entry the
// scorer would refuse (more than 4 screenshots or one over 256 KiB; a place of more than 500000 instances, whose
// scripts' sources come to over 8 MiB or whose scripts' paths come to over 1048576 characters, in all).
writeFileSync(
  join(out, 'dossier.json'),
  buildDossier(out, { text_max_bytes: 65536, screenshots: { max: 4, max_bytes: 262144 }, max_instances: 500000, scripts_max_source_bytes: 8388608, scripts_max_path_chars: 1048576 }),
);
