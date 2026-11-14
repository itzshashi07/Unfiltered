#!/usr/bin/env python3
"""Generates the launcher icons (original artwork: the mascot "Fil")."""
import os
from PIL import Image, ImageDraw

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


def legacy(size):
    S = size * 4
    bg = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    ImageDraw.Draw(bg).rounded_rectangle([0, 0, S - 1, S - 1], radius=S * 0.23, fill=DARK)
    bg = bg.resize((size, size), Image.LANCZOS)
    return Image.alpha_composite(bg, mascot(size, 0.6))


for name, px in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
    d = os.path.join(RES, f"mipmap-{name}")
    os.makedirs(d, exist_ok=True)
    legacy(px).save(os.path.join(d, "ic_launcher.png"))
    # adaptive foreground: 108dp canvas, artwork inside the 66dp safe zone
    mascot(int(px * 108 / 48), 0.4).save(os.path.join(d, "ic_launcher_foreground.png"))

os.makedirs(os.path.join(RES, "mipmap-anydpi-v26"), exist_ok=True)
with open(os.path.join(RES, "mipmap-anydpi-v26", "ic_launcher.xml"), "w") as f:
    f.write('<?xml version="1.0" encoding="utf-8"?>\n<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
            '    <background android:drawable="@color/ic_launcher_background"/>\n'
            '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n</adaptive-icon>\n')
with open(os.path.join(RES, "values", "colors.xml"), "w") as f:
    f.write('<?xml version="1.0" encoding="utf-8"?>\n<resources>\n    <color name="ic_launcher_background">#111127</color>\n'
            '    <color name="splash_background">#111127</color>\n</resources>\n')
legacy(512).save(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "docs", "icon-512.png"))
print("icons written")
