import 'package:flutter/material.dart';

/// 国风配色（米黄 / 朱砂 / 墨 / 竹青）。
class GuoFeng {
  static const bg = Color(0xFFFAF6EF); // 米黄纸色
  static const paper = Color(0xFFFDFBF6); // 卡片纸白
  static const ink = Color(0xFF3A2E25); // 墨色
  static const cinnabar = Color(0xFFB5402F); // 朱砂红
  static const ochre = Color(0xFFC8923B); // 赭石黄
  static const bamboo = Color(0xFF6E8B6B); // 竹青
  static const line = Color(0xFFE4DAC6); // 分隔线

  /// 统一构建国风 Material 主题。
  static ThemeData theme() => ThemeData(
        useMaterial3: true,
        fontFamily: 'serif',
        colorScheme: ColorScheme.fromSeed(
          seedColor: cinnabar,
          primary: cinnabar,
          background: bg,
          surface: paper,
        ),
        scaffoldBackgroundColor: bg,
        appBarTheme: const AppBarTheme(
          backgroundColor: cinnabar,
          foregroundColor: paper,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardTheme(
          color: paper,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: line),
          ),
        ),
      );
}
