import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/phrase.dart';
import '../data/san_zi_jing_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final phrases = SanZiJingData.phrases;
    final sections = SanZiJingData.sections;
    final currentSection = sections[_currentIndex];
    final sectionPhrases = SanZiJingData.grouped[currentSection]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('亲子共读三字经'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.pushNamed(context, '/about'),
          ),
        ],
      ),
      body: Column(
        children: [
          // 进度条
          _buildProgressCard(appState, phrases.length),
          // 章节选择
          _buildSectionTabs(sections, _currentIndex),
          // 诗句列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: sectionPhrases.length,
              itemBuilder: (ctx, index) {
                final phrase = sectionPhrases[index];
                // 联: 每两句一组显示
                final isPairStart = index % 2 == 0;
                final isPairEnd = index == sectionPhrases.length - 1;

                if (isPairStart) {
                  final nextPhrase = !isPairEnd ? sectionPhrases[index + 1] : null;
                  return _buildPhrasePairCard(phrase, nextPhrase, appState);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(AppState appState, int total) {
    final practiced = appState.totalPracticed;
    final percent = total > 0 ? (practiced / total * 100).round() : 0;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4A055), Color(0xFFE6B870)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '学习进度',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '$practiced / $total 句',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: total > 0 ? practiced / total : 0,
                    backgroundColor: Colors.white.withAlpha(60),
                    color: Colors.white,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$percent%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTabs(List<String> sections, int currentIndex) {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: sections.length,
        itemBuilder: (ctx, index) {
          final isSelected = index == currentIndex;
          return GestureDetector(
            onTap: () => setState(() => _currentIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFD4A055) : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                sections[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhrasePairCard(Phrase phrase1, Phrase? phrase2, AppState appState) {
    final hasAi1 = true;
    final hasParent1 = appState.hasRecording(phrase1.id, TrackType.parent);
    final hasChild1 = appState.hasRecording(phrase1.id, TrackType.child);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.pushNamed(context, '/reader', arguments: phrase1);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSinglePhraseRow(phrase1, hasAi1, hasParent1, hasChild1, appState),
              if (phrase2 != null) ...[
                const Divider(height: 16),
                _buildSinglePhraseRow(
                  phrase2,
                  true,
                  appState.hasRecording(phrase2.id, TrackType.parent),
                  appState.hasRecording(phrase2.id, TrackType.child),
                  appState,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSinglePhraseRow(
    Phrase phrase, bool hasAi, bool hasParent, bool hasChild, AppState appState,
  ) {
    return Row(
      children: [
        // 句号
        SizedBox(
          width: 36,
          child: Text(
            '${phrase.id + 1}',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ),
        // 三字
        Expanded(
          child: Text(
            phrase.characters,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
          ),
        ),
        // 状态图标
        _buildStatusIcon(Icons.smart_toy, hasAi, Colors.blue),
        const SizedBox(width: 4),
        _buildStatusIcon(Icons.family_restroom, hasParent, Colors.green),
        const SizedBox(width: 4),
        _buildStatusIcon(Icons.child_care, hasChild, Colors.orange),
      ],
    );
  }

  Widget _buildStatusIcon(IconData icon, bool has, Color color) {
    return Icon(
      icon,
      size: 18,
      color: has ? color : Colors.grey[300],
    );
  }
}
