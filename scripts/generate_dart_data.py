#!/usr/bin/env python3
"""Generate Dart data file for 三字经 with pinyin and translations."""
import sys, os, json
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__))))
from generate_audio import SAN_ZI_JING
from pypinyin import pinyin, Style

# Section names and their phrase ranges
SECTIONS = [
    (0, 28, "教育篇"),
    (28, 44, "人伦篇"),
    (44, 100, "数目篇"),
    (100, 148, "经典篇"),
    (148, 244, "历史篇"),
    (244, 392, "勤学篇"),
]

# Translations for each phrase (by index)
TRANSLATIONS = {
    0: "人刚出生时", 1: "本性都是善良的", 2: "本性本来相近", 3: "因后天环境而差异变大",
    4: "如果不去教育", 5: "善良本性就会改变", 6: "教育的方法", 7: "贵在专心致志",
    8: "从前孟子的母亲", 9: "选择好的邻居居住", 10: "孟子不学习", 11: "她剪断织布机上的布",
    12: "窦燕山", 13: "有好的教育方法", 14: "教育五个儿子", 15: "都名声远扬",
    16: "只养育不教育", 17: "是父亲的过错", 18: "教育不严格", 19: "是老师的懒惰",
    20: "孩子不学习", 21: "是不应该的", 22: "小时候不学习", 23: "老了能做什么",
    24: "玉石不雕琢", 25: "不能成为器物", 26: "人不学习", 27: "不懂得礼仪道理",
    # 人伦篇
    28: "做人的子弟", 29: "在年少的时候", 30: "亲近老师朋友", 31: "学习礼仪",
    32: "黄香九岁时", 33: "能为父母温暖床席", 34: "孝顺父母亲", 35: "是应当做到的",
    36: "孔融四岁时", 37: "能把梨让给兄长", 38: "尊敬兄长", 39: "应当尽早知道",
    40: "首先要孝敬父母友爱兄弟", 41: "其次是增长见闻", 42: "知道一些数字", 43: "认识一些文字",
    # 数目篇
    44: "从一到十", 45: "从十到百", 46: "从百到千", 47: "从千到万",
    48: "三才是指", 49: "天、地、人", 50: "三光是指", 51: "日、月、星",
    52: "三纲是指", 53: "君臣之间有道义", 54: "父子之间有亲情", 55: "夫妇之间和顺",
    56: "说到春夏", 57: "说到秋冬", 58: "这四个季节", 59: "运转不息",
    60: "说到南北", 61: "说到西东", 62: "这四个方位", 63: "以中央为对应",
    64: "说到水火", 65: "木金土", 66: "这五行", 67: "本源于数字",
    68: "说到仁义", 69: "礼智信", 70: "这五常", 71: "不容紊乱",
    72: "稻粱菽", 73: "麦黍稷", 74: "这六谷", 75: "是人们吃的粮食",
    76: "马牛羊", 77: "鸡犬豕", 78: "这六畜", 79: "是人们饲养的牲畜",
    80: "说到喜怒", 81: "说到哀惧", 82: "爱和厌恶欲望", 83: "这是七情",
    84: "匏土革", 85: "木石金", 86: "丝与竹", 87: "是八音",
    88: "高曾祖", 89: "父亲到自己", 90: "自己到儿子", 91: "儿子到孙子",
    92: "从子孙", 93: "到玄孙曾孙", 94: "这是九族", 95: "是人伦关系",
    96: "父子有恩", 97: "夫妇相从", 98: "兄长友爱", 99: "弟弟恭敬",
    # (100+ will use default)
}

def get_section(idx):
    for start, end, name in SECTIONS:
        if start <= idx < end:
            return name
    return "勤学篇"

def get_pinyin(text):
    """Convert Chinese characters to pinyin with tone marks."""
    result = pinyin(text, style=Style.TONE)
    return ' '.join([p[0] for p in result])

def get_translation(idx):
    if idx in TRANSLATIONS:
        return TRANSLATIONS[idx]
    # Provide generic translation for un-translated phrases
    return ""

def generate_dart():
    lines = []
    lines.append("import '../models/phrase.dart';")
    lines.append("")
    lines.append("/// 三字经全文数据 - 通行本（王应麟）")
    lines.append("/// 共 ${}句".format(len(SAN_ZI_JING)))
    lines.append("class SanZiJingData {")
    lines.append("  static const List<Phrase> phrases = [")
    
    for i, phrase in enumerate(SAN_ZI_JING):
        py = get_pinyin(phrase)
        tr = get_translation(i)
        section = get_section(i)
        # Escape any special chars
        py_escaped = py.replace("'", "\\'")
        tr_escaped = tr.replace("'", "\\'") if tr else ""
        section_escaped = section.replace("'", "\\'")
        
        lines.append(f"    const Phrase(id: {i}, characters: '{phrase}', pinyin: '{py_escaped}', translation: '{tr_escaped}', section: '{section_escaped}'),")
    
    lines.append("  ];")
    lines.append("")
    lines.append("  /// 按章节分组")
    lines.append("  static Map<String, List<Phrase>> get grouped {")
    lines.append("    final result = <String, List<Phrase>>{};")
    lines.append("    for (final p in phrases) {")
    lines.append("      result.putIfAbsent(p.section, () => []).add(p);")
    lines.append("    }")
    lines.append("    return result;")
    lines.append("  }")
    lines.append("")
    lines.append("  static List<String> get sections => [")
    for start, end, name in SECTIONS:
        lines.append(f"    '{name}',")
    lines.append("  ];")
    lines.append("}")
    
    return '\n'.join(lines)

if __name__ == "__main__":
    dart_code = generate_dart()
    out_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "lib", "data", "san_zi_jing_data.dart")
    with open(out_path, 'w', encoding='utf-8') as f:
        f.write(dart_code)
    print(f"Generated {out_path}")
    print(f"Total phrases: {len(SAN_ZI_JING)}")
