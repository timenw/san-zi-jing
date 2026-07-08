#!/usr/bin/env python3
"""生成三字经国风启动图标（自适应前景/背景），输出 Android 各密度 mipmap PNG。
纯矢量绘制（无中文字体依赖），用 cairosvg 渲染 SVG->PNG。
背景：米黄纸色圆角方；前景：朱砂红「经」字（用笔画矩形模拟篆意，不依赖字体）。
"""
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RES = os.path.join(ROOT, "android", "app", "src", "main", "res")

# 各密度尺寸（px）
DENSITIES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

PAPER = "#FAF6EF"   # 米黄纸色
CINNABAR = "#B5402F"  # 朱砂红
OCHRE = "#C8923B"    # 赭石


def svg_bg(size: int) -> str:
    s = size
    # 圆角背景方（自适应图标背景层，108dp 视口，留安全边距）
    r = s * 0.20
    return f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="{s}" height="{s}" viewBox="0 0 {s} {s}">
  <rect x="0" y="0" width="{s}" height="{s}" rx="{r}" ry="{r}" fill="{PAPER}"/>
</svg>'''


def svg_fg(size: int) -> str:
    s = size
    cx, cy = s / 2, s / 2
    # 「经」字用三横一竖的篆意笔画模拟（朱砂红），居中。
    # 竖线（中央）
    vw = s * 0.085
    vx = cx - vw / 2
    vtop = s * 0.20
    vbot = s * 0.80
    # 三横（顶部两横 + 底部一横形成「巠」上部意象）
    hw = s * 0.46
    hx = cx - hw / 2
    h1y = s * 0.30
    h2y = s * 0.42
    h3y = s * 0.66
    hh = s * 0.075
    # 底部「工」意象：竖断开 + 横
    # 左下短竖
    sw = s * 0.07
    sx = cx - hw / 2 + s * 0.02
    st = s * 0.70
    sb = s * 0.80
    # 右下短竖
    sx2 = cx + hw / 2 - sw - s * 0.02

    rects = []
    rects.append(f'<rect x="{vx}" y="{vtop}" width="{vw}" height="{vbot-vtop}" rx="{vw/2}" fill="{CINNABAR}"/>')
    for hy in (h1y, h2y, h3y):
        rects.append(f'<rect x="{hx}" y="{hy}" width="{hw}" height="{hh}" rx="{hh/2}" fill="{CINNABAR}"/>')
    rects.append(f'<rect x="{sx}" y="{st}" width="{sw}" height="{sb-st}" rx="{sw/2}" fill="{CINNABAR}"/>')
    rects.append(f'<rect x="{sx2}" y="{st}" width="{sw}" height="{sb-st}" rx="{sw/2}" fill="{CINNABAR}"/>')
    # 顶部点缀圆（朱印）
    dot_r = s * 0.04
    rects.append(f'<circle cx="{s*0.80}" cy="{s*0.18}" r="{dot_r}" fill="{OCHRE}"/>')

    return f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="{s}" height="{s}" viewBox="0 0 {s} {s}">
{''.join(rects)}
</svg>'''


def render(svg: str, out_png: str):
    try:
        import cairosvg  # noqa
    except ImportError:
        pass
    with open("/tmp/_icon_src.svg", "w", encoding="utf-8") as f:
        f.write(svg)
    subprocess.run(
        ["uvx", "--quiet", "cairosvg", "/tmp/_icon_src.svg", "-o", out_png],
        check=True,
        capture_output=True,
    )


def main():
    for density, size in DENSITIES.items():
        d = os.path.join(RES, density)
        os.makedirs(d, exist_ok=True)
        # 背景层
        render(svg_bg(size), os.path.join(d, "ic_launcher_background.png"))
        # 前景层
        render(svg_fg(size), os.path.join(d, "ic_launcher_foreground.png"))
        # 完整图标（背景+前景合成）
        render(bg_fg_combined(size), os.path.join(d, "ic_launcher.png"))
        render(bg_fg_combined(size, round=False),
               os.path.join(d, "ic_launcher_round.png"))
    print("icons generated for:", ", ".join(DENSITIES))


def bg_fg_combined(size: int, round: bool = True) -> str:
    r = size * 0.20 if round else 0
    cx = size / 2
    vw = size * 0.085
    vx = cx - vw / 2
    vtop, vbot = size * 0.20, size * 0.80
    hw = size * 0.46
    hx = cx - hw / 2
    hh = size * 0.075
    sw = size * 0.07
    sx = cx - hw / 2 + size * 0.02
    sx2 = cx + hw / 2 - sw - size * 0.02

    rects = [f'<rect x="0" y="0" width="{size}" height="{size}" rx="{r}" ry="{r}" fill="{PAPER}"/>']
    rects.append(f'<rect x="{vx}" y="{vtop}" width="{vw}" height="{vbot-vtop}" rx="{vw/2}" fill="{CINNABAR}"/>')
    for hy in (size*0.30, size*0.42, size*0.66):
        rects.append(f'<rect x="{hx}" y="{hy}" width="{hw}" height="{hh}" rx="{hh/2}" fill="{CINNABAR}"/>')
    rects.append(f'<rect x="{sx}" y="{size*0.70}" width="{sw}" height="{size*0.10}" rx="{sw/2}" fill="{CINNABAR}"/>')
    rects.append(f'<rect x="{sx2}" y="{size*0.70}" width="{sw}" height="{size*0.10}" rx="{sw/2}" fill="{CINNABAR}"/>')
    rects.append(f'<circle cx="{size*0.80}" cy="{size*0.18}" r="{size*0.04}" fill="{OCHRE}"/>')

    return f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="{size}" height="{size}" viewBox="0 0 {size} {size}">
{''.join(rects)}
</svg>'''


if __name__ == "__main__":
    main()
