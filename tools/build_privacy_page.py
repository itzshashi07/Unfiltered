#!/usr/bin/env python3
"""Builds the public privacy-policy page from the app's own strings.

  python3 tools/build_privacy_page.py [out_dir]   (default: docs/privacy)

The page shows exactly the privacy policy and medical/legal disclaimer the app shows in
Settings, in English, Hindi and Hinglish, so the store link and the app never disagree.
"""
import html
import os
import re
import sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
SRC = os.path.join(ROOT, "lib", "core", "strings.dart")
LEGAL = os.path.join(ROOT, "lib", "features", "settings", "legal.dart")
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "docs", "privacy")

src = open(SRC, encoding="utf-8").read()


def strings(key):
    m = re.search(r"^    '" + re.escape(key) + r"': \[(.*?)\],\n", src, re.S | re.M)
    if not m:
        raise SystemExit(f"missing string {key}")
    vals = re.findall(r"'((?:[^'\\]|\\.)*)'", m.group(1))
    vals = [v.replace("\\'", "'").replace("\\$", "$").replace("\\\\", "\\") for v in vals]
    assert len(vals) == 3, key
    return vals


counts = dict(re.findall(r"'(\w+)': (\d+)", re.search(r"sections = \{(.*?)\}", open(LEGAL).read()).group(1)))
LANGS = [("en", "English", "en"), ("hi", "हिन्दी", "hi"), ("hg", "Hinglish", "en")]


def doc(name, li):
    n = int(counts[name])
    out = [f"<h2>{html.escape(strings(f'legal.{name}.title')[li])}</h2>"]
    for i in range(1, n + 1):
        out.append(f"<h3>{html.escape(strings(f'legal.{name}.{i}.h')[li])}</h3>")
        body = html.escape(strings(f"legal.{name}.{i}.b")[li])
        body = re.sub(r"([\w.+-]+@[\w-]+\.[\w.]+)", r'<a href="mailto:\1">\1</a>', body)
        out.append(f"<p>{body}</p>")
    return "\n".join(out)


sections = []
for li, (code, label, lang) in enumerate(LANGS):
    sections.append(
        f'<section id="{code}" lang="{lang}">\n<p class="meta">{html.escape(strings("legal.draft")[li])}</p>\n'
        + doc("privacy", li) + "\n" + doc("disclaimer", li) + "\n</section>"
    )

page = f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>UNFILTERED – Privacy policy</title>
<meta name="description" content="Privacy policy and medical/legal disclaimer for the UNFILTERED Android app by Shashi Digital Labs.">
<style>
:root {{ --ink:#1d1b2e; --soft:#5b5872; --bg:#fbf8ff; --card:#ffffff; --accent:#5b3fd6; --line:#e6e1f5; }}
@media (prefers-color-scheme: dark) {{ :root {{ --ink:#f1eefc; --soft:#b9b4cf; --bg:#14121f; --card:#1e1b2e; --accent:#a996ff; --line:#2e2a44; }} }}
* {{ box-sizing: border-box; }}
body {{ margin:0; background:var(--bg); color:var(--ink); font:16px/1.6 system-ui,-apple-system,"Segoe UI",Roboto,"Noto Sans","Noto Sans Devanagari",sans-serif; }}
main {{ max-width:760px; margin:0 auto; padding:24px 16px 64px; }}
header h1 {{ font-size:28px; margin:8px 0 4px; letter-spacing:.5px; }}
header p {{ color:var(--soft); margin:0; }}
nav {{ display:flex; gap:8px; flex-wrap:wrap; margin:20px 0; }}
nav a {{ border:1px solid var(--line); background:var(--card); color:var(--accent); padding:6px 14px; border-radius:999px; text-decoration:none; font-weight:600; }}
section {{ background:var(--card); border:1px solid var(--line); border-radius:18px; padding:8px 20px 16px; margin-bottom:20px; }}
h2 {{ font-size:22px; margin:20px 0 4px; }} h3 {{ font-size:17px; margin:18px 0 2px; }}
p {{ margin:4px 0 10px; }} .meta {{ color:var(--soft); font-size:14px; margin-top:14px; }}
a {{ color:var(--accent); }} footer {{ color:var(--soft); font-size:14px; }}
</style>
</head>
<body>
<main>
<header>
<h1>UNFILTERED</h1>
<p>Privacy policy and medical/legal disclaimer · Android app by Shashi Digital Labs, India</p>
</header>
<nav aria-label="Language">{''.join(f'<a href="#{c}">{html.escape(l)}</a>' for c, l, _ in LANGS)}</nav>
{chr(10).join(sections)}
<footer><p>This page shows the same text as the app (Settings → Privacy policy, and Settings → Medical and legal disclaimer).</p></footer>
</main>
</body>
</html>
"""
os.makedirs(OUT, exist_ok=True)
open(os.path.join(OUT, "index.html"), "w", encoding="utf-8").write(page)
print("wrote", os.path.join(OUT, "index.html"), len(page), "bytes")
