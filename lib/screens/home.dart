import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/san_zi_jing.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '亲子共读三字经',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.amber),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('亲子共读三字经')),
      body: Column(
        children: [
          const ProgressHeader(),
          Expanded(
            child: ListView.builder(
              itemCount: SanZiJingData.sections.length,
              itemBuilder: (ctx, i) {
                final s = SanZiJingData.sections[i];
                return ExpansionTile(
                  title: Text(s.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  children:
                      s.verses.map((v) => VerseTile(verse: v.text)).toList(),
                );
              },
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
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProgressRow(
              label: '已读',
              count: state.readCount,
              total: total,
              value: read,
              color: Colors.green,
            ),
            const SizedBox(height: 8),
            _ProgressRow(
              label: '已录',
              count: state.recordedCount,
              total: total,
              value: rec,
              color: Colors.orange,
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
        Text('$label $count / $total'),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

class VerseTile extends StatefulWidget {
  final String verse;
  const VerseTile({super.key, required this.verse});
  @override
  State<VerseTile> createState() => _VerseTileState();
}

class _VerseTileState extends State<VerseTile> {
  bool _recording = false;
  String _recWho = 'child';

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final read = state.isRead(widget.verse);
    final recorded = state.isRecorded(widget.verse);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.verse,
                    style: TextStyle(
                      fontSize: 18,
                      decoration: read ? TextDecoration.lineThrough : null,
                      color: read ? Colors.grey : null,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: read ? '取消已读' : '标为已读',
                  icon: Icon(
                    read ? Icons.check_circle : Icons.check_circle_outline,
                    color: read ? Colors.green : null,
                  ),
                  onPressed: () => state.toggleRead(widget.verse),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  icon: const Icon(Icons.volume_up),
                  label: const Text('AI朗读'),
                  onPressed: () => state.speakAi(widget.verse),
                ),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'child', label: Text('孩子')),
                    ButtonSegment(value: 'parent', label: Text('家长')),
                  ],
                  selected: {_recWho},
                  onSelectionChanged: (s) => setState(() => _recWho = s.first),
                ),
                FilledButton.tonalIcon(
                  icon: Icon(_recording ? Icons.stop : Icons.mic),
                  label: Text(_recording ? '停止' : '录音'),
                  onPressed: () async {
                    if (_recording) {
                      await state.stopRecording(_recWho, verse: widget.verse);
                      setState(() => _recording = false);
                    } else {
                      await state.startRecording(_recWho);
                      setState(() => _recording = true);
                    }
                  },
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.compare),
                  label: const Text('三轨对比'),
                  onPressed: () =>
                      state.playCompare(widget.verse, hasParent: state.parentPath != null),
                ),
                if (recorded)
                  const Chip(
                    avatar: Icon(Icons.mic, size: 16),
                    label: Text('已录'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
