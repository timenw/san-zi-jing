import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/san_zi_jing.dart';

/// 国风配色（米黄 / 朱砂 / 墨 / 竹青）。
class GuoFeng {
  static const bg = Color(0xFFFAF6EF); // 米黄纸色
  static const paper = Color(0xFFFDFBF6); // 卡片纸白
  static const ink = Color(0xFF3A2E25); // 墨色
  static const cinnabar = Color(0xFFB5402F); // 朱砂红
  static const ochre = Color(0xFFC8923B); // 赭石黄
  static const bamboo = Color(0xFF6E8B6B); // 竹青
  static const line = Color(0xFFE4DAC6); // 分隔线
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '亲子共读三字经',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'serif',
        colorScheme: ColorScheme.fromSeed(
          seedColor: GuoFeng.cinnabar,
          primary: GuoFeng.cinnabar,
          background: GuoFeng.bg,
          surface: GuoFeng.paper,
        ),
        scaffoldBackgroundColor: GuoFeng.bg,
        appBarTheme: const AppBarTheme(
          backgroundColor: GuoFeng.cinnabar,
          foregroundColor: GuoFeng.paper,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardTheme(
          color: GuoFeng.paper,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: GuoFeng.line),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('三字经 · 亲子共读',
            style: TextStyle(fontSize: 20, letterSpacing: 2)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: GuoFeng.ochre),
        ),
      ),
      body: Column(
        children: [
          const ProgressHeader(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              itemCount: SanZiJingData.sections.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) =>
                  SectionCard(section: SanZiJingData.sections[i]),
            ),
          ),
        ],
      ),
    );
  }
}

/// 顶部学习进度：已读 / 已录 两行进度条。
class ProgressHeader extends StatelessWidget {
  const ProgressHeader({super.key});
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final total = state.totalVerses;
    final read = total == 0 ? 0.0 : state.readCount / total;
    final rec = total == 0 ? 0.0 : state.recordedCount / total;
    final allDone = total > 0 && state.recordedCount == total;
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_stories, color: GuoFeng.ochre, size: 20),
                const SizedBox(width: 6),
                const Text('学习进度',
                    style: TextStyle(fontSize: 15, color: GuoFeng.ink)),
                const Spacer(),
                if (allDone)
                  const Chip(
                    backgroundColor: GuoFeng.bamboo,
                    label: Text('🎉 全部读完啦',
                        style: TextStyle(color: GuoFeng.paper)),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            _ProgressRow(
              label: '已读',
              count: state.readCount,
              total: total,
              value: read,
              color: GuoFeng.bamboo,
            ),
            const SizedBox(height: 8),
            _ProgressRow(
              label: '已录',
              count: state.recordedCount,
              total: total,
              value: rec,
              color: GuoFeng.cinnabar,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final double value;
  final Color color;
  const _ProgressRow({
    required this.label,
    required this.count,
    required this.total,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label  $count / $total',
            style: const TextStyle(fontSize: 13, color: GuoFeng.ink)),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          color: color,
          backgroundColor: GuoFeng.line,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

/// 章节卡片：标题 + 简介 + 该章进度 + 句子列表。
class SectionCard extends StatelessWidget {
  final Section section;
  const SectionCard({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final done = section.verses
        .where((v) => state.isRecorded(v.id))
        .length;
    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: GuoFeng.cinnabar,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(section.title,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: GuoFeng.ink,
                      letterSpacing: 1)),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(left: 14, top: 4),
            child: Text(section.intro,
                style: const TextStyle(fontSize: 12, color: GuoFeng.ochre)),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: GuoFeng.bamboo.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('$done/${section.verses.length}',
                style: const TextStyle(fontSize: 12, color: GuoFeng.bamboo)),
          ),
          children: section.verses
              .map((v) => VerseTile(verse: v))
              .toList(),
        ),
      ),
    );
  }
}

/// 单句卡片：大字文本 + 可展开拼音释义 + 跟读操作。
class VerseTile extends StatefulWidget {
  final Verse verse;
  const VerseTile({super.key, required this.verse});
  @override
  State<VerseTile> createState() => _VerseTileState();
}

class _VerseTileState extends State<VerseTile> {
  bool _expanded = false;
  bool _recording = false;
  String _recWho = 'child';
  bool _comparing = false;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final id = widget.verse.id;
    final read = state.isRead(id);
    final recorded = state.isRecorded(id);
    final childPath = state.childPathOf(id);
    final parentPath = state.parentPathOf(id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.verse.text,
                    style: TextStyle(
                      fontSize: 19,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                      color: read ? GuoFeng.ochre : GuoFeng.ink,
                      decoration: read ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: read ? '取消已读' : '标为已读',
                  icon: Icon(
                    read ? Icons.check_circle : Icons.check_circle_outline,
                    color: read ? GuoFeng.bamboo : GuoFeng.ink.withOpacity(0.4),
                  ),
                  onPressed: () => state.toggleRead(id),
                ),
                IconButton(
                  tooltip: _expanded ? '收起' : '拼音·释义',
                  icon: Icon(
                    _expanded ? Icons.expand_less : Icons.menu_book_outlined,
                    color: GuoFeng.cinnabar,
                  ),
                  onPressed: () => setState(() => _expanded = !_expanded),
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 8),
              _PinyinRow(subVerses: widget.verse.subVerses),
              const Divider(color: GuoFeng.line),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('【释义】 ',
                      style: TextStyle(
                          fontSize: 13,
                          color: GuoFeng.cinnabar,
                          fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(widget.verse.meaning,
                        style: const TextStyle(
                            fontSize: 13,
                            height: 1.6,
                            color: GuoFeng.ink)),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton.icon(
                  icon: const Icon(Icons.volume_up, size: 18),
                  label: const Text('AI朗读'),
                  onPressed: () async {
                    final res = await state.speakAi(widget.verse.speakText);
                    if (!context.mounted) return;
                    switch (res) {
                      case SpeakResult.ok:
                        break;
                      case SpeakResult.noEngine:
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('该设备暂不支持语音朗读（无 TTS 引擎）')),
                        );
                      case SpeakResult.noChinese:
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('未安装中文语音包，朗读无声音'),
                            action: SnackBarAction(
                              label: '去安装',
                              onPressed: () => state.openTtsSettings(),
                            ),
                            duration: const Duration(seconds: 6),
                          ),
                        );
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: GuoFeng.cinnabar,
                    foregroundColor: GuoFeng.paper,
                  ),
                ),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'child', label: Text('孩子')),
                    ButtonSegment(value: 'parent', label: Text('家长')),
                  ],
                  selected: {_recWho},
                  onSelectionChanged: (s) => setState(() => _recWho = s.first),
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                FilledButton.tonalIcon(
                  icon: Icon(_recording ? Icons.stop : Icons.mic, size: 18),
                  label: Text(_recording ? '停止' : '录音'),
                  onPressed: () async {
                    if (_recording) {
                      try {
                        await state.stopRecording(_recWho, id);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('停止录音失败：$e')),
                          );
                        }
                      }
                      if (mounted) setState(() => _recording = false);
                    } else {
                      try {
                        await state.startRecording(_recWho, id);
                        if (mounted) setState(() => _recording = true);
                      } on PlatformException catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('无法录音：${e.message}')),
                          );
                        }
                      }
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        _recording ? GuoFeng.cinnabar : null,
                    foregroundColor:
                        _recording ? GuoFeng.paper : GuoFeng.ink,
                  ),
                ),
                if (childPath != null || parentPath != null)
                  OutlinedButton.icon(
                    icon: _comparing
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.compare_arrows, size: 18),
                    label: const Text('三轨对比'),
                    onPressed: _comparing
                        ? null
                        : () async {
                            setState(() => _comparing = true);
                            await state.playCompare(id,
                                hasParent: parentPath != null);
                            if (mounted) setState(() => _comparing = false);
                          },
                  ),
                if (childPath != null)
                  TextButton.icon(
                    icon: const Icon(Icons.child_care, size: 16),
                    label: const Text('孩子'),
                    onPressed: () => state.playFile('child', id),
                  ),
                if (parentPath != null)
                  TextButton.icon(
                    icon: const Icon(Icons.elderly, size: 16),
                    label: const Text('家长'),
                    onPressed: () => state.playFile('parent', id),
                  ),
                if (recorded)
                  const Chip(
                    avatar: Icon(Icons.mic, size: 14, color: GuoFeng.paper),
                    backgroundColor: GuoFeng.bamboo,
                    label: Text('已录',
                        style: TextStyle(color: GuoFeng.paper)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 拼音行：每个 3 字小句，上方拼音、下方大字。
class _PinyinRow extends StatelessWidget {
  final List<SubVerse> subVerses;
  const _PinyinRow({required this.subVerses});
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 10,
      children: subVerses.map((s) {
        return Column(
          children: [
            Text(s.pinyin,
                style: const TextStyle(
                    fontSize: 12, color: GuoFeng.ochre, letterSpacing: 1)),
            const SizedBox(height: 2),
            Text(s.text,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: GuoFeng.cinnabar)),
          ],
        );
      }).toList(),
    );
  }
}
