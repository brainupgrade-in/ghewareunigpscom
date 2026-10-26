#!/usr/bin/env python3
"""Regenerate assets/og-image.png, assets/apple-touch-icon.png and favicon.ico (needs Pillow)."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
GREEN, BG, TEXT, MUTED = (31, 111, 92), (247, 247, 244), (29, 35, 33), (91, 101, 97)
FONT_DIRS = ["/usr/share/fonts/truetype/dejavu", "/usr/share/fonts/dejavu"]


def font(name, size):
    for d in FONT_DIRS:
        p = Path(d) / name
        if p.exists():
            return ImageFont.truetype(str(p), size)
    return ImageFont.load_default(size)


def mark(size):
    """The rounded-square 'G' mark from assets/favicon.svg, drawn at 4x and scaled down."""
    s = size * 4
    im = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    d.rounded_rectangle([0, 0, s - 1, s - 1], radius=int(s * 14 / 64), fill=GREEN)
    u = s / 64
    w = int(6 * u)
    r = 15 * u
    c = 32 * u
    # same geometry as the SVG path: arc from (47,34) clockwise round to (44,22.5), then the bar to (33,34)
    d.arc([c - r - w / 2, c - r - w / 2, c + r + w / 2, c + r + w / 2], start=8, end=322, fill="white", width=w)
    d.line([(33 * u, 34 * u), (47 * u, 34 * u)], fill="white", width=w)
    return im.resize((size, size), Image.LANCZOS)


og = Image.new("RGB", (1200, 630), BG)
d = ImageDraw.Draw(og)
d.rectangle([0, 0, 1200, 14], fill=GREEN)
og.paste(mark(120), (90, 110), mark(120))
d.text((90, 290), "GHEWARE UNIGPS SOLUTIONS LLP", font=font("DejaVuSans-Bold.ttf", 50), fill=TEXT)
d.text((90, 375), "Limited Liability Partnership · Bengaluru, Karnataka", font=font("DejaVuSans.ttf", 34), fill=MUTED)
d.text((90, 480), "Glucoray  ·  DevOps & Agentic AI training  ·  AgentGrow", font=font("DejaVuSans.ttf", 32), fill=GREEN)
d.text((90, 540), "ghewareunigps.com", font=font("DejaVuSans.ttf", 28), fill=MUTED)
og.save(ROOT / "assets/og-image.png", optimize=True)

touch = Image.new("RGB", (180, 180), GREEN)
touch.paste(mark(180), (0, 0), mark(180))
touch.save(ROOT / "assets/apple-touch-icon.png", optimize=True)

mark(64).save(ROOT / "favicon.ico", sizes=[(16, 16), (32, 32), (48, 48)])
print("ok")
