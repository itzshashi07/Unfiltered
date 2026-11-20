#!/usr/bin/env python3
"""Generates the launcher icons and the 512 px store icon.

  python3 tools/make_icon.py            # wordmark icon "UN" (used for the 18+ Play listing)
  python3 tools/make_icon.py --mascot   # the original mascot "Fil"

The store listing for adults should not use child-appealing characters, so the default
icon is the brand wordmark. The mascot still appears inside the app.
"""
import os
import sys
from PIL import Image, ImageDraw, ImageFilter, ImageFont

RES = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "android", "app", "src", "main", "res")
DARK = (17, 17, 39, 255)


def mascot(size, scale):
    """Mascot on a transparent square canvas; `scale` = body width / canvas."""
    S = size * 4  # supersample
    im = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    b = S * scale
    x0, y0 = (S - b) / 2, (S - b) / 2 + S * 0.03
    # vertical gradient body
    grad = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    gd = ImageDraw.Draw(grad)
    for i in range(int(b)):
        t = i / b
        c = (int(155 - 65 * t), int(134 - 71 * t), int(255 - 25 * t), 255)
        gd.line([(x0, y0 + i), (x0 + b, y0 + i)], fill=c)
    mask = Image.new("L", (S, S), 0)
    ImageDraw.Draw(mask).rounded_rectangle([x0, y0, x0 + b, y0 + b], radius=b * 0.34, fill=255)
    im.paste(grad, (0, 0), mask)
    # antenna
    cx = S / 2
    d.line([(cx, y0 + b * 0.02), (cx, y0 - b * 0.1)], fill=(118, 91, 255, 255), width=int(b * 0.045))
    r = b * 0.065
    d.ellipse([cx - r, y0 - b * 0.1 - r, cx + r, y0 - b * 0.1 + r], fill=(255, 103, 123, 255))
    # highlight
    hl = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    ImageDraw.Draw(hl).ellipse([x0 + b * 0.12, y0 + b * 0.08, x0 + b * 0.52, y0 + b * 0.3], fill=(255, 255, 255, 50))
    im = Image.alpha_composite(im, hl)
    d = ImageDraw.Draw(im)
    # eyes
    for fx in (0.31, 0.69):
        ex, ey = x0 + b * fx, y0 + b * 0.44
        d.ellipse([ex - b * 0.105, ey - b * 0.125, ex + b * 0.105, ey + b * 0.125], fill=(255, 255, 255, 255))
        d.ellipse([ex - b * 0.052, ey - b * 0.06, ex + b * 0.052, ey + b * 0.06], fill=DARK)
    # cheeks
    for fx in (0.17, 0.83):
        ex, ey = x0 + b * fx, y0 + b * 0.64
        d.ellipse([ex - b * 0.06, ey - b * 0.06, ex + b * 0.06, ey + b * 0.06], fill=(255, 103, 123, 150))
    # smile
    d.arc([x0 + b * 0.36, y0 + b * 0.56, x0 + b * 0.64, y0 + b * 0.76], 20, 160, fill=(255, 255, 255, 255), width=int(b * 0.05))
    return im.resize((size, size), Image.LANCZOS)


FONT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "assets", "fonts", "PlusJakartaSans-800.ttf")
CORAL = (255, 103, 123, 255)
MINT = (169, 235, 212, 255)


def wordmark(size, scale):
    """Brand monogram "UN" with a mint bar, on a transparent canvas; `scale` = text width / canvas."""
    S = size * 4
    im = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    target = S * scale
    font = ImageFont.truetype(FONT, 100)
    w = d.textbbox((0, 0), "UN", font=font)[2]
    font = ImageFont.truetype(FONT, int(100 * target / w))
    l, t, r, b = d.textbbox((0, 0), "UN", font=font)
    tw, th = r - l, b - t
    bar = th * 0.16
    gap = th * 0.18
    top = (S - (th + gap + bar)) / 2
    x = (S - tw) / 2 - l
    d.text((x, top - t), "UN", font=font, fill=CORAL)
    bx0 = (S - tw) / 2
    d.rounded_rectangle([bx0, top + th + gap, bx0 + tw, top + th + gap + bar], radius=bar / 2, fill=MINT)
    return im.resize((size, size), Image.LANCZOS)


def background(size):
    S = size * 4
    bg = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    ImageDraw.Draw(bg).rounded_rectangle([0, 0, S - 1, S - 1], radius=S * 0.23, fill=DARK)
    glow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    ImageDraw.Draw(glow).ellipse([-S * 0.25, -S * 0.3, S * 0.75, S * 0.6], fill=(118, 91, 255, 90))
    glow = glow.filter(ImageFilter.GaussianBlur(S * 0.12))
    mask = Image.new("L", (S, S), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, S - 1, S - 1], radius=S * 0.23, fill=255)
    bg = Image.alpha_composite(bg, Image.composite(glow, Image.new("RGBA", (S, S), (0, 0, 0, 0)), mask))
    return bg.resize((size, size), Image.LANCZOS)


MASCOT = "--mascot" in sys.argv
art = mascot if MASCOT else wordmark


def legacy(size):
    return Image.alpha_composite(background(size), art(size, 0.6 if MASCOT else 0.56))


for name, px in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
    d = os.path.join(RES, f"mipmap-{name}")
    os.makedirs(d, exist_ok=True)
    legacy(px).save(os.path.join(d, "ic_launcher.png"))
    # adaptive foreground: 108dp canvas, artwork inside the 66dp safe zone
    art(int(px * 108 / 48), 0.4 if MASCOT else 0.38).save(os.path.join(d, "ic_launcher_foreground.png"))

os.makedirs(os.path.join(RES, "mipmap-anydpi-v26"), exist_ok=True)
with open(os.path.join(RES, "mipmap-anydpi-v26", "ic_launcher.xml"), "w") as f:
    f.write('<?xml version="1.0" encoding="utf-8"?>\n<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
            '    <background android:drawable="@color/ic_launcher_background"/>\n'
            '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n</adaptive-icon>\n')
with open(os.path.join(RES, "values", "colors.xml"), "w") as f:
    f.write('<?xml version="1.0" encoding="utf-8"?>\n<resources>\n    <color name="ic_launcher_background">#111127</color>\n'
            '    <color name="splash_background">#111127</color>\n</resources>\n')
legacy(512).save(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "docs", "icon-512.png"))
# Play Store icon: full-bleed square (Play applies its own rounded mask), 32-bit PNG.
store = Image.new("RGBA", (2048, 2048), DARK)
glow = Image.new("RGBA", (2048, 2048), (0, 0, 0, 0))
ImageDraw.Draw(glow).ellipse([-512, -614, 1536, 1229], fill=(118, 91, 255, 90))
store = Image.alpha_composite(store, glow.filter(ImageFilter.GaussianBlur(245))).resize((512, 512), Image.LANCZOS)
store = Image.alpha_composite(store, art(512, 0.6 if MASCOT else 0.56))
out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "docs", "play", "store")
os.makedirs(out, exist_ok=True)
store.save(os.path.join(out, "icon-512-play.png"))
print("icons written")
