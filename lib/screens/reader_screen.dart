import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/phrase.dart';
import '../data/san_zi_jing_data.dart';

class ReaderScreen extends StatefulWidget {
  final Phrase phrase;

  const ReaderScreen({super.key, required this.phrase});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late Phrase _phrase;
  late int _phraseIndex;

  @override
  void initState() {
    super.initState();
    _phrase = widget.phrase;
    _phraseIndex = _phrase.id;
  }

  void _goToPhrase(int index) {
    if (index < 0 || index >= SanZiJingData.phrases.length) return;
    final appState = context.read<AppState>();
    // Stop any playback/recording before navigating
    appState.stopPlayback();
    if (appState.isRecording) {
      appState.stopRecording();
    }
    setState(() {
      _phraseIndex = index;
      _phrase = SanZiJingData.phrases[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final total = SanZiJingData.phrases.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('第 ${_phraseIndex + 1} / $total 句'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            appState.stopPlayback();
            if (appState.isRecording) appState.stopRecording();
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // 诗句展示区
          _buildPhraseDisplay(),
          // 三轨音频区
          Expanded(
            child: _buildTracksArea(appState),
          ),
          // 导航栏
          _buildNavigationBar(),
        ],
      ),
    );
  }

  Widget _buildPhraseDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFD4A055), Color(0xFFE6B870)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // 章节标签
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _phrase.section,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
          // 三字大字
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _phrase.characters.split('').map((char) {
              return Column(
                children: [
                  Text(
                    char,
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // 拼音
          Text(
            _phrase.pinyin,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
              letterSpacing: 4,
            ),
          ),
          if (_phrase.translation.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              _phrase.translation,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withAlpha(200),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTracksArea(AppState appState) {
    final isPlayingThis = appState.playingPhraseId == _phrase.id;
    final isRecordingThis = appState.recordingPhraseId == _phrase.id;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // AI配音轨道
        _buildTrackCard(
          appState: appState,
          track: TrackType.ai,
          icon: Icons.smart_toy,
          title: 'AI老师',
          subtitle: '点击播放标准读音',
          color: const Color(0xFF4A90D9),
          isPlaying: isPlayingThis && appState.playingTrack == TrackType.ai,
          canRecord: false,
        ),
        const SizedBox(height: 12),
        // 家长录音轨道
        _buildTrackCard(
          appState: appState,
          track: TrackType.parent,
          icon: Icons.family_restroom,
          title: '家长录音',
          subtitle: appState.hasRecording(_phrase.id, TrackType.parent)
              ? '点击播放 · 长按重录'
              : '长按开始录音',
          color: const Color(0xFF52C41A),
          isPlaying: isPlayingThis && appState.playingTrack == TrackType.parent,
          isRecording: isRecordingThis && appState.recordingTrack == TrackType.parent,
          recordingSeconds: appState.recordingSeconds,
          canRecord: true,
          hasRecording: appState.hasRecording(_phrase.id, TrackType.parent),
        ),
        const SizedBox(height: 12),
        // 孩子跟读轨道
        _buildTrackCard(
          appState: appState,
          track: TrackType.child,
          icon: Icons.child_care,
          title: '宝贝跟读',
          subtitle: appState.hasRecording(_phrase.id, TrackType.child)
              ? '点击播放 · 长按重录'
              : '长按开始录音',
          color: const Color(0xFFFF7A45),
          isPlaying: isPlayingThis && appState.playingTrack == TrackType.child,
          isRecording: isRecordingThis && appState.recordingTrack == TrackType.child,
          recordingSeconds: appState.recordingSeconds,
          canRecord: true,
          hasRecording: appState.hasRecording(_phrase.id, TrackType.child),
        ),
      ],
    );
  }

  Widget _buildTrackCard({
    required AppState appState,
    required TrackType track,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isPlaying,
    bool isRecording = false,
    int recordingSeconds = 0,
    bool canRecord = false,
    bool hasRecording = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isPlaying ? color.withAlpha(30) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPlaying ? color : Colors.grey.withAlpha(40),
          width: isPlaying ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 图标
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            // 标题和副标题
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isPlaying ? color : Colors.black87,
                        ),
                      ),
                      if (hasRecording && !isPlaying && !isRecording) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.check_circle, size: 16, color: color.withAlpha(180)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  if (isRecording)
                    Text(
                      '🔴 录音中 ${recordingSeconds}s',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.red[600],
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            // 播放按钮
            if (!isRecording)
              GestureDetector(
                onTap: () => appState.play(_phrase, track),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isPlaying ? color : color.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: isPlaying ? Colors.white : color,
                    size: 28,
                  ),
                ),
              ),
            // 录音按钮 (仅家长和孩子轨道)
            if (canRecord && !isRecording) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onLongPress: () => _startRecording(appState, track),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(40),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.red.withAlpha(120), width: 1),
                  ),
                  child: const Icon(
                    Icons.mic,
                    color: Colors.red,
                    size: 22,
                  ),
                ),
              ),
            ],
            // 停止录音按钮
            if (isRecording)
              GestureDetector(
                onTap: () => appState.stopRecording(),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.stop,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            // 删除录音按钮
            if (canRecord && hasRecording && !isPlaying && !isRecording) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _confirmDelete(appState, track),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _startRecording(AppState appState, TrackType track) async {
    final success = await appState.startRecording(_phrase.id, track);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('需要录音权限才能录音，请在设置中开启'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _confirmDelete(AppState appState, TrackType track) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除录音'),
        content: const Text('确定要删除这条录音吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除')),
        ],
      ),
    );
    if (confirmed == true) {
      await appState.deleteRecording(_phrase.id, track);
    }
  }

  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 上一句
          TextButton.icon(
            onPressed: _phraseIndex > 0
                ? () => _goToPhrase(_phraseIndex - 1)
                : null,
            icon: const Icon(Icons.arrow_back),
            label: const Text('上一句'),
          ),
          // 跟读模式
          ElevatedButton.icon(
            onPressed: () => _followAlongMode(),
            icon: const Icon(Icons.record_voice_over),
            label: const Text('跟读模式'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4A055),
              foregroundColor: Colors.white,
            ),
          ),
          // 下一句
          TextButton.icon(
            onPressed: _phraseIndex < SanZiJingData.phrases.length - 1
                ? () => _goToPhrase(_phraseIndex + 1)
                : null,
            icon: const Text('下一句'),
            label: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }

  /// 跟读模式：先播AI，等播完自动开始录音孩子轨道
  bool _followModeActive = false;

  Future<void> _followAlongMode() async {
    final appState = context.read<AppState>();

    // 先停止一切
    await appState.stopPlayback();
    if (appState.isRecording) {
      await appState.stopRecording();
    }

    if (!mounted) return;

    // 显示提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('请仔细听AI老师朗读...'),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF4A90D9),
      ),
    );

    _followModeActive = true;

    // 添加一次性监听器
    void listener() {
      if (_followModeActive &&
          !mounted) return;
      if (_followModeActive &&
          appState.playState == PlayState.idle &&
          appState.playingPhraseId == null &&
          !appState.isRecording) {
        _followModeActive = false;
        appState.removeListener(listener);
        // AI播放完了，开始孩子录音
        _startRecording(appState, TrackType.child);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('现在请宝贝跟着读！🎤'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }

    appState.addListener(listener);

    // 播放AI音频
    await appState.play(_phrase, TrackType.ai);
  }
}
