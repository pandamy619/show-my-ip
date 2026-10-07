from PIL import Image, ImageDraw, ImageFilter, ImageFont
import sys

# Usage: python3 scripts/make_app_icon.py design/logo.jpg <bold-font.otf> <output-dir>
# Requires Pillow. Writes icon_<size>.png for every macOS app icon size.
SRC, FONT, OUT = sys.argv[1], sys.argv[2], sys.argv[3]
K = 4
S = 1024 * K

def base():
    canvas = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    box = (100 * K, 100 * K, 924 * K, 924 * K)
    radius = 185 * K
    shadow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle((box[0], box[1] + 12 * K, box[2], box[3] + 12 * K), radius, fill=(0, 0, 0, 90))
    canvas.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(18 * K)))
    src = Image.open(SRC).convert("RGBA")
    crop = src.crop((110, 100, 1144, 1134)).resize((824 * K, 824 * K), Image.LANCZOS)
    layer = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    layer.paste(crop, (box[0], box[1]))
    mask = Image.new("L", (S, S), 0)
    ImageDraw.Draw(mask).rounded_rectangle(box, radius, fill=255)
    canvas.paste(layer, (0, 0), mask)
    return canvas

BADGE = (560 * K, 650 * K, 830 * K, 810 * K)
R = 44 * K

def text(d, color):
    font = ImageFont.truetype(FONT, 112 * K)
    tb = d.textbbox((0, 0), "IP", font=font)
    x0, y0, x1, y1 = BADGE
    d.text(((x0 + x1) / 2 - (tb[2] - tb[0]) / 2 - tb[0], (y0 + y1) / 2 - (tb[3] - tb[1]) / 2 - tb[1]), "IP", font=font, fill=color)

def white(c):
    d = ImageDraw.Draw(c)
    d.rounded_rectangle(BADGE, R, fill=(245, 240, 250, 255), outline=(14, 7, 32, 255), width=10 * K)
    text(d, (14, 7, 32, 255))

icon = base()
white(icon)
icon = icon.resize((1024, 1024), Image.LANCZOS)
for px in (16, 32, 64, 128, 256, 512, 1024):
    icon.resize((px, px), Image.LANCZOS).save(f"{OUT}/icon_{px}.png")
