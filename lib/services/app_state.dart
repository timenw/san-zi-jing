import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

enum PlayState { stopped, playing, paused }

class AppState {
  final FlutterTts tts = FlutterTts();
  final AudioRecorder recorder = AudioRecorder();
  final AudioPlayer aiPlayer = AudioPlayer();
  final AudioPlayer parentPlayer = AudioPlayer();
  final AudioPlayer childPlayer = AudioPlayer();

  // 最近一次录音文件路径（孩子 / 家长）
  String? _childPath;
  String? _parentPath;

  String? get childPath => _childPath;
  String? get parentPath => _parentPath;

  bool _ttsReady = false;

  AppState() {
    _initTts();
  }

  void _initTts() async {
    await tts.setLanguage('zh-CN');
    await tts.setSpeechRate(0.45); // 慢速，适合跟读
    await tts.setPitch(1.0);
    _ttsReady = true;
  }

  /// AI 配音：朗读指定句子（实时 TTS，无需音频文件）。
  Future<void> speakAi(String text) async {
    if (!_ttsReady) await _initTts();
    await tts.stop();
    await tts.speak(text);
  }

  Future<void> stopAi() async => tts.stop();

  /// 录音（家长或孩子）。返回保存路径；record 6.x 用 RecordConfig。
  Future<String> startRecording(String who) async {
    if (await recorder.isRecording()) await recorder.stop();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${who}_${DateTime.now().millisecondsSinceEpoch}.m4a');
    await recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
      path: file.path,
    );
    return file.path;
  }

  Future<String?> stopRecording(String who) async {
    final path = await recorder.stop();
    if (path != null) {
      if (who == 'child') _childPath = path;
      if (who == 'parent') _parentPath = path;
      await _saveLast(who, path);
    }
    return path;
  }

  Future<void> _saveLast(String who, String path) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('last_${who}_rec', path);
  }

  Future<void> loadLast() async {
    final sp = await SharedPreferences.getInstance();
    _childPath = sp.getString('last_child_rec');
    _parentPath = sp.getString('last_parent_rec');
  }

  /// 三轨对比播放：依次播放 AI(朗读) / 家长 / 孩子。分别在三个 Player 切换。
  Future<void> playCompare(String sentence, {bool hasParent = false}) async {
    await stopCompare();
    await tts.stop();
    await speakAi(sentence);
    await Future.delayed(const Duration(milliseconds: 200));
    if (hasParent && _parentPath != null) {
      await parentPlayer.setFilePath(_parentPath!);
      await parentPlayer.play();
    }
  }

  Future<void> playFile(String who) async {
    final path = who == 'child' ? _childPath : _parentPath;
    if (path == null) return;
    final p = who == 'child' ? childPlayer : parentPlayer;
    await p.stop();
    await p.setFilePath(path);
    await p.play();
  }

  Future<void> stopCompare() async {
    await tts.stop();
    await parentPlayer.stop();
    await childPlayer.stop();
  }

  void dispose() {
    tts.stop();
    aiPlayer.dispose();
    parentPlayer.dispose();
    childPlayer.dispose();
    recorder.dispose();
  }
}
