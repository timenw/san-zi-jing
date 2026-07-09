#!/usr/bin/env python3
"""Render the 童趣 app icon into the iOS AppIcon.appiconset, overwriting the
default Flutter placeholders at the exact pixel sizes Xcode expects.

Keeps existing filenames (so Contents.json stays valid) and renders each at the
correct size. Also generates the 1024 marketing icon.
"""
import os, subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
ICONSET = "/root/san-zi-jing/ios/Runner/Assets.xcassets/AppIcon.appiconset"

FONT = "/usr/share/fonts/truetype/wqy/wqy-zenhei.ttc"
CREAM_TOP = "#FDF3DF"; CREAM_BOT = "#F8E2BC"; BAMBOO = "#6E8B6B"
CINNABAR = "#B5402F"; SUN = "#F6B94A"; INK = "#5A3E1B"
PAPER = "#FFFDF8"; STAR = "#8FB38B"

BG = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 192 192">
  <defs><linearGradient id="bg" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="{CREAM_TOP}"/>
    <stop offset="1" stop-color="{CREAM_BOT}"/></linearGradient></defs>
  <rect x="0" y="0" width="192" height="192" rx="40" fill="url(#bg)"/>
  <rect x="13" y="13" width="166" height="166" rx="34"
        fill="none" stroke="{BAMBOO}" stroke-width="6" opacity="0.55"/>
</svg>"""

FG = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 192 192">
  <g fill="{STAR}" opacity="0.9">
    <path d="M52 50 l4 9 10 1 -7 7 2 10 -9 -5 -9 5 2 -10 -7 -7 10 -1 z"/></g>
  <g fill="{STAR}" opacity="0.8">
    <path d="M50 138 l3 7 8 1 -6 6 2 8 -7 -4 -7 4 2 -8 -6 -6 8 -1 z"/></g>
  <g><circle cx="142" cy="54" r="19" fill="{SUN}"/>
    <circle cx="136" cy="50" r="2.6" fill="{INK}"/>
    <circle cx="148" cy="50" r="2.6" fill="{INK}"/>
    <path d="M135 58 q7 7 14 0" fill="none" stroke="{INK}" stroke-width="2.4"
          stroke-linecap="round"/>
    <circle cx="130" cy="60" r="3" fill="#F2925E" opacity="0.7"/>
    <circle cx="154" cy="60" r="3" fill="#F2925E" opacity="0.7"/></g>
  <g><path d="M96 78 C78 70 56 70 40 80 L40 150 C56 140 78 140 96 148 Z"
          fill="{PAPER}" stroke="{BAMBOO}" stroke-width="3"/>
    <path d="M96 78 C114 70 136 70 152 80 L152 150 C136 140 114 140 96 148 Z"
          fill="{PAPER}" stroke="{BAMBOO}" stroke-width="3"/>
    <path d="M96 78 L96 148" stroke="{BAMBOO}" stroke-width="3"/>
    <path d="M52 96 h30 M52 106 h30 M52 116 h26" stroke="{BAMBOO}"
          stroke-width="2.4" stroke-linecap="round" opacity="0.6"/>
    <path d="M110 96 h30 M110 106 h30 M110 116 h26" stroke="{BAMBOO}"
          stroke-width="2.4" stroke-linecap="round" opacity="0.6"/></g>
  <text x="96" y="128" font-family="WenQuanYi Zen Hei" font-weight="bold"
        font-size="58" fill="{CINNABAR}" text-anchor="middle"
        dominant-baseline="middle">三</text>
</svg>"""

COMBINED = (BG[:BG.index("</svg>")] + FG[FG.index("<g fill"):FG.rindex("</svg>")] + "</svg>")

# filename -> px size
SIZES = {
    "Icon-App-20x20@2x.png": 40, "Icon-App-20x20@3x.png": 60,
    "Icon-App-29x29@1x.png": 29, "Icon-App-29x29@2x.png": 58,
    "Icon-App-29x29@3x.png": 87, "Icon-App-40x40@1x.png": 40,
    "Icon-App-40x40@2x.png": 80, "Icon-App-40x40@3x.png": 120,
    "Icon-App-60x60@2x.png": 120, "Icon-App-60x60@3x.png": 180,
    "Icon-App-76x76@1x.png": 76, "Icon-App-76x76@2x.png": 152,
    "Icon-App-83.5x83.5@2x.png": 167,
    "Icon-App-1024x1024@1x.png": 1024,
}

for name, px in SIZES.items():
    out = os.path.join(ICONSET, name)
    tmp = out + ".tmp.svg"
    with open(tmp, "w", encoding="utf-8") as f:
        f.write(COMBINED)
    subprocess.run(["uvx", "--quiet", "cairosvg", tmp, "-o", out,
                    "-W", str(px), "-H", str(px)], check=True)
    os.remove(tmp)
    print(f"rendered {name} -> {px}px")

print("DONE")
