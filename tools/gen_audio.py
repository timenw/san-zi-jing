#!/usr/bin/env python3
"""Generate one pre-recorded mp3 per 三字经 verse using edge-tts.

Parses verse id + text from lib/models/san_zi_jing.dart, strips punctuation,
and renders each verse to assets/audio/<id>.mp3 with a gentle Chinese voice.
"""
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DART = os.path.join(ROOT, "lib", "models", "san_zi_jing.dart")
OUT = os.path.join(ROOT, "assets", "audio")
VOICE = "zh-CN-XiaoxiaoNeural"
RATE = "-13%"
PITCH = "+0Hz"


def parse_verses():
    txt = open(DART, encoding="utf-8").read()
    # id: 'v0_0'  ... text: '人之初，性本善。...'
    pat = re.compile(r"id:\s*'(v[^']+)'[\s\S]*?text:\s*'([^']+)'")
    out = []
    for mid, mtext in pat.findall(txt):
        clean = re.sub(r"[，。、；：]", "", mtext)
        out.append((mid, clean))
    return out


def main():
    os.makedirs(OUT, exist_ok=True)
    verses = parse_verses()
    print(f"parsed {len(verses)} verses")
    only = sys.argv[1] if len(sys.argv) > 1 else None
    for vid, text in verses:
        if only and vid != only:
            continue
        dst = os.path.join(OUT, f"{vid}.mp3")
        if os.path.exists(dst) and os.path.getsize(dst) > 0:
            print(f"skip {vid} (exists)")
            continue
        cmd = [
            "uvx", "edge-tts",
            "--voice", VOICE,
            "--rate=" + RATE,
            "--pitch=" + PITCH,
            "--text", text,
            "--write-media", dst,
        ]
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            print(f"ok   {vid}  ({len(text)} chars)")
        except subprocess.CalledProcessError as e:
            print(f"FAIL {vid}: {e.stderr.decode('utf-8','ignore')[:300]}", file=sys.stderr)
            raise


if __name__ == "__main__":
    main()
