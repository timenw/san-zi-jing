import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'models/san_zi_jing.dart';

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
      body: ListView.builder(
        itemCount: SanZiJingData.sections.length,
        itemBuilder: (ctx, i) {
          final s = SanZiJingData.sections[i];
          return ExpansionTile(
            title: Text(s.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            children: s.verses.map((v) => VerseTile(verse: v.text)).toList(),
          );
        },
      ),
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
    final state = Provider.of<AppState>(context, listen: false);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.verse, style: const TextStyle(fontSize: 18)),
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
                      await state.stopRecording(_recWho);
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
                  onPressed: () => state.playCompare(widget.verse, hasParent: state.parentPath != null),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
