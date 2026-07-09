#!/usr/bin/env python3
"""生成童趣 + 三字经主题图标（圆润书卷 + 三颗彩点隐喻「三」+ 小星星）。

依赖: uvx cairosvg（无需 PIL/Flutter SDK）。
配色：米黄纸底 + 圆润书卷(朱砂/竹青/赭石) + 童趣高饱和点缀。
"""
import os
import subprocess

FONT = "/usr/share/fonts/truetype/wqy/wqy-zenhei.ttc"
OUT = "/root/san-zi-jing/android/app/src/main/res"

# 童趣明快配色
PAPER = "#FFF8EC"      # 暖米黄纸底
CINNABAR = "#E5573F"   # 明亮朱砂（书卷主色）
BAMBOO = "#5BAE8E"     # 竹青（卷边）
OCHRE = "#F2B441"      # 赭石金（点缀/星）
INK = "#3A2E25"        # 墨色（卷上文字）
SKY = "#7FB5E6"        # 童趣蓝（小点）
PINK = "#F08FB0"       # 童趣粉（小点）

DENS = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}


def svg_for(size: int) -> str:
    s = size
    cx = s / 2
    # 圆角纸底
    r = s * 0.22
    # 书卷：横向圆角矩形作卷身，上下两条卷边（椭圆）
    book_w = s * 0.62
    book_h = s * 0.46
    bx = cx - book_w / 2
    by = cx - book_h / 2 + s * 0.03
    br = book_h * 0.32
    # 三颗彩点（隐喻「三」字经）：红/蓝/粉，排在书卷上方弧线
    dot_r = s * 0.052
    dot_y = by - s * 0.10
    dots = [
        (cx - s * 0.16, CINNABAR),
        (cx, OCHRE),
        (cx + s * 0.16, PINK),
    ]
    # 书卷上的「三」字（用真实字体）或「经」？用「经」字更直接点题三字经
    fs = int(book_h * 0.66)
    ty = by + book_h / 2 + fs * 0.34
    # 小星星（童趣）
    star = _star(cx + s * 0.30, by - s * 0.02, s * 0.05)
    star2 = _star(cx - s * 0.32, by + s * 0.14, s * 0.035)
    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{s}" height="{s}" viewBox="0 0 {s} {s}">',
        f'<rect x="0" y="0" width="{s}" height="{s}" rx="{r:.1f}" ry="{r:.1f}" fill="{PAPER}"/>',
    ]
    for (dx, dc) in dots:
        parts.append(f'<circle cx="{dx:.1f}" cy="{dot_y:.1f}" r="{dot_r:.1f}" fill="{dc}"/>')
    parts.append(f'<g>{star}{star2}</g>')
    # 书卷卷边（上下椭圆）
    parts.append(f'<ellipse cx="{cx:.1f}" cy="{by:.1f}" rx="{book_w/2:.1f}" ry="{br:.1f}" fill="{BAMBOO}"/>')
    parts.append(f'<rect x="{bx:.1f}" y="{by:.1f}" width="{book_w:.1f}" height="{book_h:.1f}" fill="{CINNABAR}"/>')
    parts.append(f'<ellipse cx="{cx:.1f}" cy="{by+book_h:.1f}" rx="{book_w/2:.1f}" ry="{br:.1f}" fill="{BAMBOO}"/>')
    # 「经」字
    parts.append(f'<text x="{cx:.1f}" y="{ty:.1f}" font-family="WenQuanYi Zen Hei" font-size="{fs}" fill="{INK}" text-anchor="middle" font-weight="bold">经</text>')
    parts.append('</svg>')
    return "".join(parts)


def _star(cx, cy, r):
    import math
    pts = []
    for i in range(10):
        ang = math.pi / 2 + i * math.pi / 5
        rad = r if i % 2 == 0 else r * 0.45
        pts.append(f"{cx + rad*math.cos(ang):.1f},{cy - rad*math.sin(ang):.1f}")
    return f'<polygon points="{" ".join(pts)}" fill="{OCHRE}"/>'


def render(svg: str, out_png: str):
    p = subprocess.run(
        ["uvx", "--quiet", "cairosvg", "/dev/stdin", "-o", out_png],
        input=svg.encode("utf-8"),
        check=True,
    )
    if not os.path.exists(out_png) or os.path.getsize(out_png) == 0:
        raise RuntimeError(f"空输出: {out_png}")


def main():
    for dens, size in DENS.items():
        d = os.path.join(OUT, f"mipmap-{dens}")
        os.makedirs(d, exist_ok=True)
        # background：纯纸色（自适应图标用）
        bg_svg = (f'<svg xmlns="http://www.w3.org/2000/svg" width="{size}" height="{size}">'
                  f'<rect width="{size}" height="{size}" rx="{size*0.22:.1f}" fill="{PAPER}"/></svg>')
        render(bg_svg, os.path.join(d, "ic_launcher_background.png"))
        # foreground：透明底 + 书卷+三彩点+星+经字（自适应图标前景层）
        fg = _foreground(size)
        render(fg, os.path.join(d, "ic_launcher_foreground.png"))
        # 合成图（<26 设备）
        render(svg_for(size), os.path.join(d, "ic_launcher.png"))
        render(svg_for(size), os.path.join(d, "ic_launcher_round.png"))
        print(f"  {dens}: {size}px ok")


def _foreground(size: int) -> str:
    s = size
    cx = s / 2
    book_w = s * 0.62
    book_h = s * 0.46
    bx = cx - book_w / 2
    by = cx - book_h / 2 + s * 0.03
    br = book_h * 0.32
    dot_r = s * 0.052
    dot_y = by - s * 0.10
    dots = [(cx - s * 0.16, CINNABAR), (cx, OCHRE), (cx + s * 0.16, PINK)]
    fs = int(book_h * 0.66)
    ty = by + book_h / 2 + fs * 0.34
    star = _star(cx + s * 0.30, by - s * 0.02, s * 0.05)
    star2 = _star(cx - s * 0.32, by + s * 0.14, s * 0.035)
    parts = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{s}" height="{s}" viewBox="0 0 {s} {s}">']
    for (dx, dc) in dots:
        parts.append(f'<circle cx="{dx:.1f}" cy="{dot_y:.1f}" r="{dot_r:.1f}" fill="{dc}"/>')
    parts.append(f'<g>{star}{star2}</g>')
    parts.append(f'<ellipse cx="{cx:.1f}" cy="{by:.1f}" rx="{book_w/2:.1f}" ry="{br:.1f}" fill="{BAMBOO}"/>')
    parts.append(f'<rect x="{bx:.1f}" y="{by:.1f}" width="{book_w:.1f}" height="{book_h:.1f}" fill="{CINNABAR}"/>')
    parts.append(f'<ellipse cx="{cx:.1f}" cy="{by+book_h:.1f}" rx="{book_w/2:.1f}" ry="{br:.1f}" fill="{BAMBOO}"/>')
    parts.append(f'<text x="{cx:.1f}" y="{ty:.1f}" font-family="WenQuanYi Zen Hei" font-size="{fs}" fill="{INK}" text-anchor="middle" font-weight="bold">经</text>')
    parts.append('</svg>')
    return "".join(parts)


if __name__ == "__main__":
    main()
    print("童趣图标生成完成")
