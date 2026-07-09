#!/usr/bin/env python3
"""生成高质感国风印章图标（真实 CJK 字体渲染「经」字）。

依赖: uvx cairosvg（无需 PIL/Flutter SDK）。
输出: 各 density 的 ic_launcher(_round?).png 与
      ic_launcher(_background|_foreground).png（自适应图标三层）。
"""
import os
import subprocess
import sys

FONT = "/usr/share/fonts/truetype/wqy/wqy-zenhei.ttc"
OUT = "/root/san-zi-jing/android/app/src/main/res"
GLYPH = "经"

# 配色（与 app 国风一致）
PAPER = "#FAF6EF"      # 米黄纸色（背景）
CINNABAR = "#B5402F"   # 朱砂红（印章）
GOLD = "#C8923B"       # 赭石金（描边）
WHITE = "#FDFBF6"      # 印面白字

# 密度 -> px（mdpi 基准 48）
DENS = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}


def svg_for(size: int) -> str:
    # 画布 size x size，实际印章留 8% 边距，圆角矩形。
    m = size * 0.06
    seal = size - 2 * m
    r = seal * 0.18
    cx = size / 2
    # 字体大小：印章内约占 62%
    fs = int(seal * 0.62)
    # 文字基线（竖直居中）
    y = size / 2 + fs * 0.36
    # 金边：印章内缩一点
    gb = size * 0.035
    gseal = size - 2 * (m + gb)
    gr = gseal * 0.18
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="{size}" height="{size}" viewBox="0 0 {size} {size}">
  <rect x="0" y="0" width="{size}" height="{size}" rx="{r:.1f}" ry="{r:.1f}" fill="{PAPER}"/>
  <rect x="{m:.1f}" y="{m:.1f}" width="{seal:.1f}" height="{seal:.1f}" rx="{r:.1f}" ry="{r:.1f}" fill="{CINNABAR}"/>
  <rect x="{m+gb:.1f}" y="{m+gb:.1f}" width="{gseal:.1f}" height="{gseal:.1f}" rx="{gr:.1f}" ry="{gr:.1f}" fill="none" stroke="{GOLD}" stroke-width="{size*0.012:.1f}"/>
  <text x="{cx:.1f}" y="{y:.1f}" font-family="WenQuanYi Zen Hei" font-size="{fs}" fill="{WHITE}" text-anchor="middle" font-weight="bold">{GLYPH}</text>
</svg>'''


def render(svg: str, out_png: str):
    p = subprocess.run(
        ["uvx", "--quiet", "cairosvg", "/dev/stdin", "-o", out_png],
        input=svg.encode("utf-8"),
        check=True,
    )
    if not os.path.exists(out_png) or os.path.getsize(out_png) == 0:
        raise RuntimeError(f"空输出: {out_png}")


def main():
    os.makedirs(OUT, exist_ok=True)
    for dens, size in DENS.items():
        d = os.path.join(OUT, f"mipmap-{dens}")
        os.makedirs(d, exist_ok=True)
        # 自适应图标三层
        # 1) background: 纯纸色满铺
        bg_svg = (f'<svg xmlns="http://www.w3.org/2000/svg" width="{size}" height="{size}">'
                  f'<rect width="{size}" height="{size}" fill="{PAPER}"/></svg>')
        render(bg_svg, os.path.join(d, "ic_launcher_background.png"))
        # 2) foreground: 透明底 + 朱砂印章（无纸色块，靠自适应 background 层）
        fg_m = size * 0.06
        fg_seal = size - 2 * fg_m
        fg_r = fg_seal * 0.18
        fg_cx = size / 2
        fg_fs = int(fg_seal * 0.62)
        fg_y = size / 2 + fg_fs * 0.36
        fg_svg = (f'<svg xmlns="http://www.w3.org/2000/svg" width="{size}" height="{size}" viewBox="0 0 {size} {size}">'
                  f'<rect x="{fg_m:.1f}" y="{fg_m:.1f}" width="{fg_seal:.1f}" height="{fg_seal:.1f}" rx="{fg_r:.1f}" ry="{fg_r:.1f}" fill="{CINNABAR}"/>'
                  f'<text x="{fg_cx:.1f}" y="{fg_y:.1f}" font-family="WenQuanYi Zen Hei" font-size="{fg_fs}" fill="{WHITE}" text-anchor="middle" font-weight="bold">{GLYPH}</text>'
                  f'</svg>')
        render(fg_svg, os.path.join(d, "ic_launcher_foreground.png"))
        # 3) 合成图（ic_launcher.png / ic_launcher_round.png，给 <26 设备）
        render(svg_for(size), os.path.join(d, "ic_launcher.png"))
        render(svg_for(size), os.path.join(d, "ic_launcher_round.png"))
        print(f"  {dens}: {size}px  ok")


if __name__ == "__main__":
    main()
    print("图标生成完成")
