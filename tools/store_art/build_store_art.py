#!/usr/bin/env python3
"""Builds the Google Play feature graphic and phone screenshot creatives.

  python3 tools/store_art/build_store_art.py <screens_dir> <out_dir>

<screens_dir> must hold genuine 1080x1920 captures of the release build:
  body.png, myths.png, consent.png, labs.png, ask.png, explore.png
Each creative frames one real screenshot with a headline; nothing in the app UI is
redrawn or invented. Pages are rendered with headless Chrome (proper Devanagari shaping).
"""
import html
import os
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
FONTS = os.path.join(ROOT, "assets", "fonts")
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

SHOTS = [
    # file, eyebrow, headline (| marks the highlighted part), sub, glow A, glow B
    ("body", "UNDERSTAND YOUR BODY", "Your body, |finally explained.|",
     "Plain-language lessons on health, periods, sexual health and when to see a doctor.",
     "#FF677B", "#765BFF"),
    ("myths", "MYTHS VS FACTS", "Myth or fact? |Science decides.|",
     "116 myth cards on the things people only whisper about, each with its sources.",
     "#FF9F43", "#FF677B"),
    ("consent", "CONSENT & RELATIONSHIPS", "Consent, |for real life.|",
     "Practise hard moments in decision paths and see what respect looks like.",
     "#1FA67A", "#765BFF"),
    ("labs", "INTERACTIVE LABS", "Learn by |doing.|",
     "Labs, quizzes and scenarios you tap through, not textbooks you skim.",
     "#765BFF", "#80B9FF"),
    ("ask", "PRIVATE & OFFLINE", "Ask anything. |It stays on your phone.|",
     "No account. No ads. No tracking. Works offline in English, हिन्दी and Hinglish.",
     "#A9EBD4", "#765BFF"),
]

FONT_CSS = f"""
@font-face {{ font-family: Jakarta; font-weight: 500; src: url('file://{FONTS}/PlusJakartaSans-500.ttf'); }}
@font-face {{ font-family: Jakarta; font-weight: 600; src: url('file://{FONTS}/PlusJakartaSans-600.ttf'); }}
@font-face {{ font-family: Jakarta; font-weight: 800; src: url('file://{FONTS}/PlusJakartaSans-800.ttf'); }}
* {{ margin: 0; padding: 0; box-sizing: border-box; }}
body {{ font-family: Jakarta, sans-serif; color: #fff; overflow: hidden; background: #111127; }}
.wm {{ font-weight: 800; letter-spacing: 3px; }} .wm b {{ color: #FF677B; }}
.pill {{ display: inline-block; border: 2px solid rgba(255,255,255,.28); border-radius: 999px; font-weight: 600; color: rgba(255,255,255,.9); }}
"""


def headline(text):
    a, b, c = (text.split("|") + ["", ""])[:3]
    return f'{html.escape(a)}<span class="hl">{html.escape(b)}</span>{html.escape(c)}'


def shot_page(src, eyebrow, head, sub, ga, gb):
    return f"""<!doctype html><html><head><meta charset="utf-8"><style>{FONT_CSS}
html, body {{ width: 1080px; height: 1920px; }}
body {{ background:
  radial-gradient(900px 700px at 0% 0%, {ga}66, transparent 70%),
  radial-gradient(900px 900px at 100% 100%, {gb}77, transparent 70%),
  linear-gradient(160deg, #15122e 0%, #111127 55%, #1a1440 100%); }}
.top {{ position: absolute; left: 84px; right: 84px; top: 84px; }}
.row {{ display: flex; align-items: center; justify-content: space-between; }}
.wm {{ font-size: 34px; }}
.pill {{ font-size: 24px; padding: 8px 20px; }}
.eyebrow {{ margin-top: 58px; font-size: 26px; font-weight: 800; letter-spacing: 4px; color: {ga}; }}
h1 {{ margin-top: 16px; font-size: 86px; line-height: 1.04; font-weight: 800; letter-spacing: -1.5px; }}
.hl {{ color: {ga}; }}
.sub {{ margin-top: 22px; font-size: 36px; line-height: 1.38; font-weight: 500; color: rgba(255,255,255,.8); font-family: Jakarta, sans-serif; }}
.phone {{ position: absolute; left: 50%; top: 735px; width: 690px; transform: translateX(-50%);
  border-radius: 64px; padding: 14px; background: #0b0a18;
  box-shadow: 0 0 0 2px rgba(255,255,255,.14), 0 50px 110px rgba(0,0,0,.55), 0 0 120px {ga}44; }}
.phone img {{ display: block; width: 100%; border-radius: 52px; }}
</style></head><body>
<div class="top">
  <div class="row"><div class="wm"><b>UN</b>FILTERED</div><div class="pill">For adults · 18+</div></div>
  <div class="eyebrow">{html.escape(eyebrow)}</div>
  <h1>{headline(head)}</h1>
  <div class="sub">{html.escape(sub)}</div>
</div>
<div class="phone"><img src="file://{src}"></div>
</body></html>"""


def feature_page(left, right):
    return f"""<!doctype html><html><head><meta charset="utf-8"><style>{FONT_CSS}
html, body {{ width: 1024px; height: 500px; }}
body {{ background:
  radial-gradient(520px 420px at 8% 10%, #765BFF88, transparent 70%),
  radial-gradient(560px 460px at 95% 105%, #FF677B77, transparent 70%),
  linear-gradient(150deg, #15122e 0%, #111127 60%, #1a1440 100%); }}
.txt {{ position: absolute; left: 64px; top: 92px; width: 520px; }}
.wm {{ font-size: 64px; letter-spacing: 4px; }}
.tag {{ margin-top: 14px; font-size: 30px; font-weight: 800; line-height: 1.2; }}
.tag span {{ color: #A9EBD4; }}
.sub {{ margin-top: 18px; font-size: 21px; line-height: 1.45; font-weight: 500; color: rgba(255,255,255,.8); }}
.pill {{ margin-top: 22px; font-size: 18px; padding: 6px 16px; }}
.ph {{ position: absolute; width: 214px; border-radius: 30px; padding: 7px; background: #0b0a18;
  box-shadow: 0 0 0 1.5px rgba(255,255,255,.16), 0 30px 60px rgba(0,0,0,.55); }}
.ph img {{ display: block; width: 100%; border-radius: 24px; }}
.a {{ left: 610px; top: 46px; transform: rotate(-6deg); }}
.b {{ left: 790px; top: 92px; transform: rotate(5deg); }}
</style></head><body>
<div class="txt">
  <div class="wm"><b>UN</b>FILTERED</div>
  <div class="tag">Real talk. Real science.<br><span>Zero shame.</span></div>
  <div class="sub">Sexual health and relationships education for adults, in English, हिन्दी and Hinglish.</div>
  <div class="pill">Private · Offline · For adults 18+</div>
</div>
<div class="ph a"><img src="file://{left}"></div>
<div class="ph b"><img src="file://{right}"></div>
</body></html>"""


def render(page_html, out_png, w, h, work):
    p = os.path.join(work, os.path.basename(out_png) + ".html")
    open(p, "w", encoding="utf-8").write(page_html)
    profile = os.path.join(work, "profile")
    subprocess.run([CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars", "--force-device-scale-factor=1",
                    f"--user-data-dir={profile}", "--allow-file-access-from-files", "--virtual-time-budget=4000",
                    f"--window-size={w},{h}", f"--screenshot={out_png}", f"file://{p}"],
                   check=True, capture_output=True)


def main():
    shots, out = os.path.abspath(sys.argv[1]), os.path.abspath(sys.argv[2])
    os.makedirs(out, exist_ok=True)
    work = tempfile.mkdtemp(prefix="storeart-")
    try:
        for i, (name, eb, head, sub, ga, gb) in enumerate(SHOTS, 1):
            render(shot_page(os.path.join(shots, name + ".png"), eb, head, sub, ga, gb),
                   os.path.join(out, f"screenshot-{i}-{name}.png"), 1080, 1920, work)
        render(feature_page(os.path.join(shots, "explore.png"), os.path.join(shots, "myths.png")),
               os.path.join(out, "feature-graphic.png"), 1024, 500, work)
    finally:
        shutil.rmtree(work, ignore_errors=True)
    print("wrote", sorted(os.listdir(out)))


if __name__ == "__main__":
    main()
