#!/usr/bin/env python3
"""Generate a playful (童趣) app icon for 亲子三字经.

Produces, for each density (mdpi..xxxhdpi):
  ic_launcher.png           full composed icon (square)
  ic_launcher_round.png     same (round fallback)
  ic_launcher_background.png  adaptive background layer
  ic_launcher_foreground.png  adaptive foreground layer (transparent)

Renders via cairosvg (uvx) with the WenQuanYi Zen Hei CJK font for 「三」.
"""
import os
import subprocess

RES = "/root/san-zi-jing/android/app/src/main/res"
FONT = "/usr/share/fonts/truetype/wqy/wqy-zenhei.ttc"

DENSITIES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

# 童趣配色
CREAM_TOP = "#FDF3DF"
CREAM_BOT = "#F8E2BC"
BAMBOO = "#6E8B6B"
CINNABAR = "#B5402F"
SUN = "#F6B94A"
INK = "#5A3E1B"
PAPER = "#FFFDF8"
STAR = "#8FB38B"

# ---- 背景层：暖米黄渐变 + 竹青内描边 ----
BG = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 192 192">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="{CREAM_TOP}"/>
      <stop offset="1" stop-color="{CREAM_BOT}"/>
    </linearGradient>
  </defs>
  <rect x="0" y="0" width="192" height="192" fill="url(#bg)"/>
  <rect x="13" y="13" width="166" height="166" rx="40"
        fill="none" stroke="{BAMBOO}" stroke-width="6" opacity="0.55"/>
</svg>"""

# ---- 前景层：笑脸太阳 + 童书 + 朱砂「三」+ 小星（透明底） ----
FG = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 192 192">
  <!-- 小星 1 -->
  <g fill="{STAR}" opacity="0.9">
    <path d="M52 50 l4 9 10 1 -7 7 2 10 -9 -5 -9 5 2 -10 -7 -7 10 -1 z"/>
  </g>
  <!-- 小星 2 -->
  <g fill="{STAR}" opacity="0.8">
    <path d="M50 138 l3 7 8 1 -6 6 2 8 -7 -4 -7 4 2 -8 -6 -6 8 -1 z"/>
  </g>
  <!-- 笑脸太阳 -->
  <g>
    <circle cx="142" cy="54" r="19" fill="{SUN}"/>
    <circle cx="136" cy="50" r="2.6" fill="{INK}"/>
    <circle cx="148" cy="50" r="2.6" fill="{INK}"/>
    <path d="M135 58 q7 7 14 0" fill="none" stroke="{INK}" stroke-width="2.4"
          stroke-linecap="round"/>
    <circle cx="130" cy="60" r="3" fill="#F2925E" opacity="0.7"/>
    <circle cx="154" cy="60" r="3" fill="#F2925E" opacity="0.7"/>
  </g>
  <!-- 童书：两页翻开 -->
  <g>
    <path d="M96 78 C78 70 56 70 40 80 L40 150 C56 140 78 140 96 148 Z"
          fill="{PAPER}" stroke="{BAMBOO}" stroke-width="3"/>
    <path d="M96 78 C114 70 136 70 152 80 L152 150 C136 140 114 140 96 148 Z"
          fill="{PAPER}" stroke="{BAMBOO}" stroke-width="3"/>
    <path d="M96 78 L96 148" stroke="{BAMBOO}" stroke-width="3"/>
    <!-- 书页上的小横线 -->
    <path d="M52 96 h30 M52 106 h30 M52 116 h26" stroke="{BAMBOO}"
          stroke-width="2.4" stroke-linecap="round" opacity="0.6"/>
    <path d="M110 96 h30 M110 106 h30 M110 116 h26" stroke="{BAMBOO}"
          stroke-width="2.4" stroke-linecap="round" opacity="0.6"/>
  </g>
  <!-- 朱砂红大字「三」浮在书上 -->
  <text x="96" y="128" font-family="WenQuanYi Zen Hei" font-weight="bold"
        font-size="58" fill="{CINNABAR}" text-anchor="middle"
        dominant-baseline="middle">三</text>
</svg>"""

# ---- 合成图标：背景 + 前景叠加 ----
COMBINED = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 192 192">
  {BG.replace('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 192 192">','').replace('</svg>','')}
  {FG.replace('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 192 192">','').replace('</svg>','')}
</svg>"""


def render(svg, out_path, size):
    tmp = out_path + ".tmp.svg"
    with open(tmp, "w", encoding="utf-8") as f:
        f.write(svg)
    subprocess.run(
        ["uvx", "--quiet", "cairosvg", tmp, "-o", out_path, "-W", str(size),
         "-H", str(size)],
        check=True,
    )
    os.remove(tmp)


def main():
    for d, size in DENSITIES.items():
        ddir = os.path.join(RES, d)
        assert os.path.isdir(ddir), ddir
        render(BG, os.path.join(ddir, "ic_launcher_background.png"), size)
        render(FG, os.path.join(ddir, "ic_launcher_foreground.png"), size)
        render(COMBINED, os.path.join(ddir, "ic_launcher.png"), size)
        render(COMBINED, os.path.join(ddir, "ic_launcher_round.png"), size)
        print(f"rendered {d} ({size}px)")
    print("DONE")


if __name__ == "__main__":
    main()
