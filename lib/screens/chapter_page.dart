import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/san_zi_jing.dart';
import '../theme.dart';
import '../services/app_state.dart';
import 'verse_page.dart';

/// 章节页：列出本章所有句子，点击进入单句学习页。
class ChapterPage extends StatelessWidget {
  final Section section;
  const ChapterPage({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(section.title,
            style: const TextStyle(fontSize: 19, letterSpacing: 1)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: GuoFeng.paper,
            child: Text(section.intro,
                style: const TextStyle(fontSize: 12, color: GuoFeng.ochre)),
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        itemCount: section.verses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) => VerseListItem(section: section, index: i),
      ),
    );
  }
}

/// 章节内的句子列表项：大字预览 + 进度标记，点击进入单句页。
class VerseListItem extends StatelessWidget {
  final Section section;
  final int index;
  const VerseListItem({super.key, required this.section, required this.index});

  @override
  Widget build(BuildContext context) {
    final verse = section.verses[index];
    final state = Provider.of<AppState>(context);
    final read = state.isRead(verse.id);
    final recorded = state.isRecorded(verse.id);
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => VersePage(section: section, index: index),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: read ? GuoFeng.bamboo : GuoFeng.line,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text('${index + 1}',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: read ? GuoFeng.paper : GuoFeng.ink)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  verse.text,
                  style: TextStyle(
                    fontSize: 17,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                    color: read ? GuoFeng.ochre : GuoFeng.ink,
                    decoration: read ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (recorded)
                const Icon(Icons.mic, size: 16, color: GuoFeng.bamboo),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: GuoFeng.ink),
            ],
          ),
        ),
      ),
    );
  }
}
