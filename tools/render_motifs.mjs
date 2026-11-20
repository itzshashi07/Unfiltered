// Renders the magazine's cover motifs (Lucide line icons from the website) as white PNGs for the app.
//   node tools/render_motifs.mjs [--website ../website]
// Uses headless Chrome through the website's puppeteer-core. Output: assets/images/motifs/<name>.png (256px).
import { createRequire } from 'node:module';
import { readFileSync, mkdirSync, writeFileSync, readdirSync, rmSync } from 'node:fs';
import { join, dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const app = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const i = process.argv.indexOf('--website');
const web = i > -1 ? resolve(process.argv[i + 1]) : join(app, 'website');
const require = createRequire(join(web, 'package.json'));
const puppeteer = require('puppeteer-core');

const icons = JSON.parse(readFileSync(join(web, 'src/data/icons.json'), 'utf8')).icons;
const motifs = JSON.parse(readFileSync(join(web, 'src/data/motifs.json'), 'utf8'));
const out = join(app, 'assets/images/motifs');
mkdirSync(out, { recursive: true });
for (const f of readdirSync(out)) if (!motifs.includes(f.replace(/\.png$/, ''))) rmSync(join(out, f));

const browser = await puppeteer.launch({
  executablePath: '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
  headless: 'new',
});
const page = await browser.newPage();
await page.setViewport({ width: 256, height: 256, deviceScaleFactor: 1 });
let n = 0;
for (const m of motifs) {
  if (!icons[m]) { console.warn(`no icon for motif ${m}`); continue; }
  await page.setContent(
    `<html><body style="margin:0;background:transparent"><svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 24 24" fill="none" stroke="#ffffff" stroke-width="1.15" stroke-linecap="round" stroke-linejoin="round">${icons[m]}</svg></body></html>`,
  );
  writeFileSync(join(out, `${m}.png`), await page.screenshot({ omitBackground: true, type: 'png' }));
  n++;
}
await browser.close();
console.log(`motifs rendered: ${n}`);
