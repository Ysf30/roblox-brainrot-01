/**
 * Generate layout.json for the Brainrot Base Defense 3D world
 * This mirrors the exact geometry that will be in game.rbxl
 */

import fs from 'fs';
import path from 'path';

const layout = {
  // Base plot (60x60)
  basePlot: {
    position: [0, 0.5, 0],
    size: [60, 1, 60],
    color: [0.235, 0.235, 0.275], // RGB 60,60,70
    gridSize: 4,
    cellSize: 12,
    gridLines: [],
  },

  // Base core
  baseCore: {
    position: [0, 4, 0],
    size: [6, 8, 6],
    color: [0, 0.784, 1], // Cyan
    material: 'ForceField',
    transparency: 0.3,
  },

  // Spawn lane / conveyor
  spawnLane: {
    startPosition: [-50, 3, 0],
    length: 80,
    width: 12,
    height: 5,
    conveyorBase: {
      position: [-50, 3.5, 40],
      size: [12, 1, 80],
      color: [0.314, 0.314, 0.353], // Metal gray
    },
    conveyorSections: [],
    sideWalls: [],
    spawnPad: {
      position: [-50, 4.25, 3],
      size: [10, 0.5, 6],
      color: [0, 1, 0.588], // Neon green
    },
  },

  // Shop building
  shop: {
    position: [0, 3, -40],
    size: [20, 6, 15],
    floor: {
      position: [0, 3, -40],
      size: [20, 1, 15],
      color: [0.471, 0.353, 0.235], // Wood
    },
    walls: [],
    roof: {
      position: [0, 8.5, -40],
      size: [22, 1, 17],
      color: [0.314, 0.157, 0.078], // Slate
    },
    sign: {
      position: [0, 11, -47.5],
      size: [12, 4, 1],
      color: [1, 0.784, 0], // Gold
      text: "BRAINROT SHOP",
    },
    rerollPad: {
      position: [-14, 0.75, -40],
      size: [6, 0.5, 6],
      color: [1, 0.392, 0.392], // Red
    },
  },

  // Hazard safe zones
  hazardZones: {
    highGround: {
      position: [80, 15, 80],
      size: [30, 20, 30],
      color: [0.392, 0.392, 0.392], // Rock gray
      transparency: 0.3,
      name: "HighGround",
    },
    baseShelter: {
      position: [0, -5, 0],
      size: [20, 10, 20],
      color: [0.196, 0.196, 0.235], // Concrete
      transparency: 0.2,
      name: "BaseShelter",
    },
    lightZone: {
      position: [-80, 15, -80],
      size: [25, 30, 25],
      color: [1, 1, 0.784], // Light yellow
      transparency: 0.5,
      name: "LightZone",
    },
    stablePlatform: {
      position: [0, 25, 0],
      size: [20, 2, 20],
      color: [0.784, 0.784, 0.784], // Diamond plate
      name: "StablePlatform",
    },
    baseRoof: {
      position: [0, 10.5, 0],
      size: [60, 2, 60],
      color: [0.314, 0.314, 0.392], // Metal
      transparency: 0.3,
      name: "BaseRoof",
    },
  },

  // Sample brainrots on base (for mid-play screenshot)
  sampleBrainrots: [
    // Common brainrots
    { id: 'skibidi_toilet', name: 'Skibidi Toilet', rarity: 'Common', mutation: 'None', position: [-12, 2, -12], size: [3, 4, 3], color: [0.706, 0.706, 0.706] },
    { id: 'ohio_rizzler', name: 'Ohio Rizzler', rarity: 'Common', mutation: 'None', position: [12, 2, -12], size: [2.5, 5, 2.5], color: [0.706, 0.706, 0.706] },
    { id: 'sigma_grindset', name: 'Sigma Grindset', rarity: 'Common', mutation: 'Shiny', position: [-12, 2, 12], size: [2, 5, 2], color: [1, 1, 0.588] },

    // Uncommon brainrots
    { id: 'skull_emoji', name: 'Skull Emoji', rarity: 'Uncommon', mutation: 'None', position: [12, 2, 12], size: [3, 3, 3], color: [0.314, 0.784, 0.314] },
    { id: 'rizz_god', name: 'Rizz God', rarity: 'Uncommon', mutation: 'Golden', position: [0, 3, 0], size: [2.5, 5, 2.5], color: [1, 0.843, 0] },

    // Rare brainrot
    { id: 'brainrot_cat', name: 'Brainrot Cat', rarity: 'Rare', mutation: 'None', position: [-6, 2, 6], size: [2, 2.5, 3], color: [0.314, 0.471, 1] },

    // Epic brainrot
    { id: 'brainrot_dragon', name: 'Brainrot Dragon', rarity: 'Epic', mutation: 'None', position: [0, 4, -18], size: [6, 4, 8], color: [0.706, 0.314, 1] },

    // Legendary brainrot (for progression view)
    { id: 'brainrot_titan', name: 'Brainrot Titan', rarity: 'Legendary', mutation: 'None', position: [0, 7.5, 18], size: [10, 15, 10], color: [1, 0.706, 0] },

    // Mythic brainrot
    { id: 'brainrot_archon', name: 'Brainrot Archon', rarity: 'Mythic', mutation: 'Rainbow', position: [-18, 6, 18], size: [8, 12, 8], color: [1, 0, 1] },

    // Brainrot God
    { id: 'the_one_brainrot', name: 'THE ONE BRAINROT', rarity: 'BrainrotGod', mutation: 'Void', position: [18, 7.5, -18], size: [12, 15, 12], color: [0.078, 0, 0.157] },
  ],

  // Brainrots on conveyor (for start screenshot)
  conveyorBrainrots: [
    { id: 'skibidi_toilet', name: 'Skibidi Toilet', rarity: 'Common', mutation: 'None', position: [-50, 5, 10], size: [3, 4, 3], color: [0.706, 0.706, 0.706] },
    { id: 'ohio_rizzler', name: 'Ohio Rizzler', rarity: 'Common', mutation: 'None', position: [-50, 5, 20], size: [2.5, 5, 2.5], color: [0.706, 0.706, 0.706] },
    { id: 'sigma_grindset', name: 'Sigma Grindset', rarity: 'Common', mutation: 'None', position: [-50, 5, 30], size: [2, 5, 2], color: [0.706, 0.706, 0.706] },
    { id: 'gyatt_master', name: 'GYATT Master', rarity: 'Common', mutation: 'None', position: [-50, 5, 40], size: [3, 3, 3], color: [0.706, 0.706, 0.706] },
    { id: 'skull_emoji', name: 'Skull Emoji', rarity: 'Uncommon', mutation: 'Shiny', position: [-50, 5, 50], size: [3, 3, 3], color: [1, 1, 0.588] },
    { id: 'rizz_god', name: 'Rizz God', rarity: 'Uncommon', mutation: 'None', position: [-50, 5, 60], size: [2.5, 5, 2.5], color: [0.314, 0.784, 0.314] },
  ],

  // Player avatar position
  playerStart: {
    position: [0, 5, 0],
  },

  // Camera presets for screenshots
  cameras: {
    start: {
      position: [0, 35, 60],
      target: [0, 5, 0],
      fov: 60,
    },
    play: {
      position: [30, 25, 30],
      target: [0, 5, 0],
      fov: 60,
    },
    progression: {
      position: [-40, 30, 40],
      target: [0, 10, 0],
      fov: 50,
    },
    summit: {
      position: [0, 50, 0],
      target: [0, 10, 0],
      fov: 70,
    },
  },

  // Lighting
  lighting: {
    ambient: [0.3, 0.3, 0.35],
    brightness: 2,
    sunDirection: [-0.5, -1, -0.3],
    sunColor: [1, 0.95, 0.9],
  },
};

// Generate grid lines for base plot
for (let i = 0; i <= layout.basePlot.gridSize; i++) {
  layout.basePlot.gridLines.push({
    // X lines
    position: [
      layout.basePlot.position[0] - layout.basePlot.size[0]/2 + i * layout.basePlot.cellSize,
      layout.basePlot.position[1] + 0.1,
      layout.basePlot.position[2]
    ],
    size: [0.2, 0.1, layout.basePlot.size[2]],
    color: [0.392, 0.392, 0.471],
    transparency: 0.5,
  });

  // Z lines
  layout.basePlot.gridLines.push({
    position: [
      layout.basePlot.position[0],
      layout.basePlot.position[1] + 0.1,
      layout.basePlot.position[2] - layout.basePlot.size[2]/2 + i * layout.basePlot.cellSize
    ],
    size: [layout.basePlot.size[0], 0.1, 0.2],
    color: [0.392, 0.392, 0.471],
    transparency: 0.5,
  });
}

// Generate conveyor sections
const sectionCount = Math.floor(layout.spawnLane.length / 4);
for (let i = 0; i < sectionCount; i++) {
  layout.spawnLane.conveyorSections.push({
    position: [
      layout.spawnLane.startPosition[0],
      layout.spawnLane.startPosition[1] + 1,
      layout.spawnLane.startPosition[2] + 2 + i * 4
    ],
    size: [layout.spawnLane.width - 1, 0.5, 4],
    color: [0.196, 0.196, 0.235],
  });
}

// Generate side walls
for (const side of [-1, 1]) {
  layout.spawnLane.sideWalls.push({
    position: [
      layout.spawnLane.startPosition[0] + side * (layout.spawnLane.width/2 + 0.5),
      layout.spawnLane.startPosition[1] + 2,
      layout.spawnLane.startPosition[2] + layout.spawnLane.length/2
    ],
    size: [1, 4, layout.spawnLane.length],
    color: [0.392, 0.588, 1],
    transparency: 0.5,
  });
}

// Generate shop walls
const wallThickness = 0.5;
const wallHeight = layout.shop.size[1] - 1;
layout.shop.walls.push({
  name: 'WallBack',
  position: [0, wallHeight/2 + 0.5, layout.shop.size[2]/2],
  size: [layout.shop.size[0], wallHeight, wallThickness],
  color: [0.392, 0.275, 0.157],
});
layout.shop.walls.push({
  name: 'WallLeft',
  position: [-layout.shop.size[0]/2, wallHeight/2 + 0.5, 0],
  size: [wallThickness, wallHeight, layout.shop.size[2]],
  color: [0.392, 0.275, 0.157],
});
layout.shop.walls.push({
  name: 'WallRight',
  position: [layout.shop.size[0]/2, wallHeight/2 + 0.5, 0],
  size: [wallThickness, wallHeight, layout.shop.size[2]],
  color: [0.392, 0.275, 0.157],
});

// Write layout.json
const outputPath = path.join(path.dirname(new URL(import.meta.url).pathname), '..', 'layout.json');
fs.writeFileSync(outputPath, JSON.stringify(layout, null, 2));
console.log('Generated layout.json at', outputPath);

// Also generate a simplified version for the renderer
const rendererLayout = {
  basePlot: layout.basePlot,
  baseCore: layout.baseCore,
  spawnLane: {
    conveyorBase: layout.spawnLane.conveyorBase,
    conveyorSections: layout.spawnLane.conveyorSections,
    sideWalls: layout.spawnLane.sideWalls,
    spawnPad: layout.spawnLane.spawnPad,
  },
  shop: {
    floor: layout.shop.floor,
    walls: layout.shop.walls,
    roof: layout.shop.roof,
    sign: layout.shop.sign,
    rerollPad: layout.shop.rerollPad,
  },
  hazardZones: Object.values(layout.hazardZones),
  sampleBrainrots: layout.sampleBrainrots,
  conveyorBrainrots: layout.conveyorBrainrots,
  playerStart: layout.playerStart,
  cameras: layout.cameras,
  lighting: layout.lighting,
};

const rendererPath = path.join(path.dirname(new URL(import.meta.url).pathname), 'renderer-layout.json');
fs.writeFileSync(rendererPath, JSON.stringify(rendererLayout, null, 2));
console.log('Generated renderer-layout.json at', rendererPath);