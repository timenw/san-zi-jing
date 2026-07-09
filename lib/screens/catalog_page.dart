import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/san_zi_jing.dart';
import '../theme.dart';
import '../services/app_state.dart';
import 'chapter_page.dart';

/// 目录页：按章节为单位列出三字经的各个章节，点击进入章节页。
class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('三字经 · 目录',
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
              itemBuilder: (ctx, i) => SectionCatalogCard(section: SanZiJingData.sections[i]),
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

/// 目录中的章节卡片：标题 + 简介 + 进度，点击进入章节页。
class SectionCatalogCard extends StatelessWidget {
  final Section section;
  const SectionCatalogCard({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final done = section.verses
        .where((v) => state.isRecorded(v.id))
        .length;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChapterPage(section: section),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 46,
                decoration: BoxDecoration(
                  color: GuoFeng.cinnabar,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(section.title,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: GuoFeng.ink,
                            letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(section.intro,
                        style: const TextStyle(fontSize: 12, color: GuoFeng.ochre)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: GuoFeng.bamboo.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('$done/${section.verses.length}',
                        style: const TextStyle(fontSize: 12, color: GuoFeng.bamboo)),
                  ),
                  const SizedBox(height: 6),
                  const Icon(Icons.chevron_right, color: GuoFeng.ink),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
