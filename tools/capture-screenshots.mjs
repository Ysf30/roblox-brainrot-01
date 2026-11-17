import puppeteer from 'puppeteer';
import fs from 'fs';
import path from 'path';

async function captureScreenshots() {
  const browser = await puppeteer.launch({
    headless: 'new',
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-gpu',
      '--use-angle=swiftshader',
      '--enable-unsafe-swiftshader',
      '--window-size=1280,720',
    ],
    executablePath: '/usr/bin/google-chrome-stable',
  });

  const shots = [
    { name: '1-start', shot: 0, label: 'Start View' },
    { name: '2-play', shot: 1, label: 'Mid-Play View' },
    { name: '3-progression', shot: 2, label: 'Progression/Rarity View' },
    { name: '4-summit', shot: 3, label: 'Summit/Thumbnail' },
  ];

  for (const shot of shots) {
    const page = await browser.newPage();
    await page.setViewport({ width: 1280, height: 720 });

    // Capture console messages
    page.on('console', msg => console.log('BROWSER:', msg.type(), msg.text().substring(0, 300)));
    page.on('pageerror', err => console.log('PAGE ERROR:', err.message));
    page.on('requestfailed', req => console.log('REQUEST FAILED:', req.url(), req.failure().errorText));

    console.log(`Capturing ${shot.name} (shot=${shot.shot})...`);
    await page.goto(`http://localhost:8931/shot-viewer-fixed.html?shot=${shot.shot}`, {
      waitUntil: 'domcontentloaded',
      timeout: 120000
    });

    // Helper to wait for a condition using page.evaluate (main world)
    async function waitForCondition(conditionFn, timeout = 120000, interval = 100) {
      const start = Date.now();
      while (Date.now() - start < timeout) {
        const result = await page.evaluate(conditionFn);
        if (result) return true;
        await new Promise(r => setTimeout(r, interval));
      }
      throw new Error(`Timeout waiting for condition after ${timeout}ms`);
    }

    // Wait for ready signal
    await waitForCondition(() => document.body.dataset.ready === 'true', 120000);

    // Wait for first render complete
    await waitForCondition(() => document.body.dataset.rendered === 'true', 30000);

    // Wait a bit more for rendering to settle
    await new Promise(r => setTimeout(r, 2000));

    const screenshotPath = path.join('..', 'screenshots', `${shot.name}.png`);
    await page.screenshot({ path: screenshotPath, fullPage: false });
    const size = fs.statSync(screenshotPath).size;
    console.log(`Saved ${shot.name}.png (${size} bytes)`);

    await page.close();
  }

  await browser.close();
  console.log('All screenshots captured!');
}

captureScreenshots().catch(console.error);