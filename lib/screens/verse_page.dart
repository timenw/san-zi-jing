import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/san_zi_jing.dart';
import '../theme.dart';
import '../services/app_state.dart';

/// 单句学习页：一句单独一页。
/// 大字文本 + 拼音 + 释义 + 预录语音包朗读 + 跟读录音；
/// 底部「上一句 / 下一句」按钮翻页学习。
class VersePage extends StatefulWidget {
  final Section section;
  final int index; // 该句在本章中的下标
  const VersePage({super.key, required this.section, required this.index});

  @override
  State<VersePage> createState() => _VersePageState();
}

class _VersePageState extends State<VersePage> {
  bool _expanded = true; // 释义是否展开
  bool _recording = false;
  String _recWho = 'child';
  bool _comparing = false;

  Verse get verse => widget.section.verses[widget.index];
  bool get _isFirst => widget.index == 0;
  bool get _isLast => widget.index == widget.section.verses.length - 1;

  void _goTo(int newIndex) {
    if (newIndex < 0 || newIndex >= widget.section.verses.length) return;
    // 翻页前停止当前朗读，避免上一句声音串到下一页。
    Provider.of<AppState>(context, listen: false).stopAudio();
    // 用替换方式翻页，避免栈无限增长。
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => VersePage(section: widget.section, index: newIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final id = verse.id;
    final read = state.isRead(id);
    final recorded = state.isRecorded(id);
    final childPath = state.childPathOf(id);
    final parentPath = state.parentPathOf(id);
    final playing = state.isPlayingVerse(id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.section.title,
            style: const TextStyle(fontSize: 18, letterSpacing: 1)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: GuoFeng.ochre.withOpacity(0.5)),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 句序标记
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: GuoFeng.cinnabar.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '第 ${widget.index + 1} / ${widget.section.verses.length} 句',
                          style: const TextStyle(
                              fontSize: 12, color: GuoFeng.cinnabar),
                        ),
                      ),
                      const Spacer(),
                      if (recorded)
                        const Chip(
                          avatar: Icon(Icons.mic, size: 14, color: GuoFeng.paper),
                          backgroundColor: GuoFeng.bamboo,
                          label: Text('已录',
                              style: TextStyle(color: GuoFeng.paper)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 大字文本
                  Text(
                    verse.text,
                    style: TextStyle(
                      fontSize: 30,
                      height: 1.6,
                      fontWeight: FontWeight.bold,
                      color: read ? GuoFeng.ochre : GuoFeng.ink,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // 拼音行
                  _PinyinRow(subVerses: verse.subVerses),
                  const SizedBox(height: 16),

                  // 释义（可折叠）
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () => setState(() => _expanded = !_expanded),
                            child: Row(
                              children: [
                                const Icon(Icons.menu_book_outlined,
                                    size: 18, color: GuoFeng.cinnabar),
                                const SizedBox(width: 6),
                                const Text('【释义】',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: GuoFeng.cinnabar,
                                        fontWeight: FontWeight.bold)),
                                const Spacer(),
                                Icon(
                                  _expanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: GuoFeng.ink.withOpacity(0.5),
                                ),
                              ],
                            ),
                          ),
                          if (_expanded) ...[
                            const SizedBox(height: 8),
                            Text(verse.meaning,
                                style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.7,
                                    color: GuoFeng.ink)),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 朗读 + 标记已读
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      FilledButton.icon(
                        icon: playing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: GuoFeng.paper))
                            : const Icon(Icons.volume_up, size: 18),
                        label: Text(playing ? '朗读中' : '朗读'),
                        onPressed: playing
                            ? () => state.stopAudio()
                            : () async {
                                final ok = await state.playVerse(id);
                                if (!context.mounted) return;
                                if (!ok) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('该句语音包缺失，无法朗读')),
                                  );
                                }
                              },
                        style: FilledButton.styleFrom(
                          backgroundColor: GuoFeng.cinnabar,
                          foregroundColor: GuoFeng.paper,
                        ),
                      ),
                      OutlinedButton.icon(
                        icon: Icon(
                          read
                              ? Icons.check_circle
                              : Icons.check_circle_outline,
                          size: 18,
                          color: read ? GuoFeng.bamboo : GuoFeng.ink,
                        ),
                        label: Text(read ? '已读' : '标为已读'),
                        onPressed: () => state.toggleRead(id),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: read ? GuoFeng.bamboo : GuoFeng.ink,
                          side: BorderSide(
                            color: read ? GuoFeng.bamboo : GuoFeng.line,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 跟读录音（孩子 / 家长）
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('跟读录音',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: GuoFeng.cinnabar,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              SegmentedButton<String>(
                                segments: const [
                                  ButtonSegment(
                                      value: 'child', label: Text('孩子')),
                                  ButtonSegment(
                                      value: 'parent', label: Text('家长')),
                                ],
                                selected: {_recWho},
                                onSelectionChanged: (s) =>
                                    setState(() => _recWho = s.first),
                                style: const ButtonStyle(
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                              const SizedBox(width: 12),
                              FilledButton.tonalIcon(
                                icon: Icon(
                                    _recording ? Icons.stop : Icons.mic,
                                    size: 18),
                                label: Text(_recording ? '停止' : '录音'),
                                onPressed: () async {
                                  if (_recording) {
                                    try {
                                      await state.stopRecording(_recWho, id);
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text('停止录音失败：$e')),
                                        );
                                      }
                                    }
                                    if (mounted) {
                                      setState(() => _recording = false);
                                    }
                                  } else {
                                    try {
                                      await state.startRecording(_recWho, id);
                                      if (mounted) {
                                        setState(() => _recording = true);
                                      }
                                    } on PlatformException catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text('无法录音：${e.message}')),
                                        );
                                      }
                                    }
                                  }
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: _recording
                                      ? GuoFeng.cinnabar
                                      : null,
                                  foregroundColor: _recording
                                      ? GuoFeng.paper
                                      : GuoFeng.ink,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // 朗读音源：用户可把某句「朗读」设为家长/孩子录音
                          const Text('朗读音源',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: GuoFeng.ink,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _SourceChip(
                                label: '系统',
                                selected: state.readSourceOf(id) == 'system',
                                onTap: () => state.setReadSource(id, 'system'),
                              ),
                              if (parentPath != null)
                                _SourceChip(
                                  label: '家长',
                                  selected:
                                      state.readSourceOf(id) == 'parent',
                                  onTap: () => state.setReadSource(id, 'parent'),
                                ),
                              if (childPath != null)
                                _SourceChip(
                                  label: '孩子',
                                  selected: state.readSourceOf(id) == 'child',
                                  onTap: () => state.setReadSource(id, 'child'),
                                ),
                            ],
                          ),
                          if (childPath != null || parentPath != null) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                if (childPath != null)
                                  TextButton.icon(
                                    icon: const Icon(Icons.child_care, size: 16),
                                    label: const Text('孩子录音'),
                                    onPressed: () =>
                                        state.playFile('child', id),
                                  ),
                                if (parentPath != null)
                                  TextButton.icon(
                                    icon: const Icon(Icons.elderly, size: 16),
                                    label: const Text('家长录音'),
                                    onPressed: () =>
                                        state.playFile('parent', id),
                                  ),
                                if (childPath != null || parentPath != null)
                                  OutlinedButton.icon(
                                    icon: _comparing
                                        ? const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2))
                                        : const Icon(Icons.family_restroom,
                                            size: 18),
                                    label: const Text('亲子共读'),
                                    onPressed: _comparing
                                        ? null
                                        : () async {
                                            setState(() => _comparing = true);
                                            await state.playParentChild(id);
                                            if (mounted) {
                                              setState(() => _comparing = false);
                                            }
                                          },
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 底部翻页栏：上一句 / 下一句
          _NavBar(
            isFirst: _isFirst,
            isLast: _isLast,
            onPrev: () => _goTo(widget.index - 1),
            onNext: () => _goTo(widget.index + 1),
          ),
        ],
      ),
    );
  }
}

/// 底部「上一句 / 下一句」翻页栏。
class _NavBar extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  const _NavBar({
    required this.isFirst,
    required this.isLast,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GuoFeng.paper,
        border: Border(top: BorderSide(color: GuoFeng.line)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: 10 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('上一句'),
              onPressed: isFirst ? null : onPrev,
              style: OutlinedButton.styleFrom(
                foregroundColor: GuoFeng.ink,
                side: const BorderSide(color: GuoFeng.line),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton.icon(
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('下一句'),
              onPressed: isLast ? null : onNext,
              style: FilledButton.styleFrom(
                backgroundColor: GuoFeng.bamboo,
                foregroundColor: GuoFeng.paper,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 朗读音源选择 chip（系统 / 家长 / 孩子）。
class _SourceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SourceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: GuoFeng.cinnabar,
      labelStyle: TextStyle(
        color: selected ? GuoFeng.paper : GuoFeng.ink,
        fontSize: 13,
      ),
      visualDensity: VisualDensity.compact,
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
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: subVerses.map((s) {
        return Column(
          children: [
            Text(s.pinyin,
                style: const TextStyle(
                    fontSize: 13, color: GuoFeng.ochre, letterSpacing: 1)),
            const SizedBox(height: 4),
            Text(s.text,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: GuoFeng.cinnabar)),
          ],
        );
      }).toList(),
    );
  }
}
