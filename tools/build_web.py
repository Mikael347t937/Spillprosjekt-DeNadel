#!/usr/bin/env python3
"""Build the website and Godot game. Requires matching Godot export templates."""
import argparse
import gzip
from pathlib import Path
import shutil
import subprocess

root = Path(__file__).resolve().parents[1]
p = argparse.ArgumentParser()
p.add_argument('--godot', default='godot')
p.add_argument('--output', type=Path, default=root / 'web/dist')
a = p.parse_args()
out = a.output.resolve()
(out / 'game').mkdir(parents=True, exist_ok=True)
(out / 'assets').mkdir(exist_ok=True)
for name in ['index.html', 'style.css', 'app.js']:
    shutil.copy2(root / 'web' / name, out / name)
for source in ['assets/art/title_background.png', 'assets/fonts/Anton-Regular.ttf', 'assets/fonts/BarlowCondensed-Regular.ttf', 'icon.svg']:
    shutil.copy2(root / 'de-nadel' / source, out / 'assets' / Path(source).name)
for license_file in (root / 'de-nadel/assets/fonts').glob('*OFL*'):
    shutil.copy2(license_file, out / 'assets' / license_file.name)
subprocess.run([a.godot, '--headless', '--editor', '--path', str(root / 'de-nadel'), '--import', '--quit'], check=True)
subprocess.run([a.godot, '--headless', '--path', str(root / 'de-nadel'), '--export-release', 'Web', str(out / 'game/index.html')], check=True)
for name in ['index.html', 'index.js', 'index.wasm', 'index.pck']:
    if not (out / 'game' / name).is_file():
        raise SystemExit('Missing exported file: ' + name)
wasm = out / 'game/index.wasm'
with gzip.open(out / 'game/index.wasm.gz', 'wb', compresslevel=9) as compressed:
    compressed.write(wasm.read_bytes())
wasm.unlink()
shutil.copy2(root / 'web/load-engine.js', out / 'game/load-engine.js')
html = out / 'game/index.html'
html.write_text(html.read_text().replace('<script src="index.js"></script>', '<script src="load-engine.js"></script>\n<script src="index.js"></script>'))
print('Website ready:', out)
