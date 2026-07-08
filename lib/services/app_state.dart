import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

enum PlayState { stopped, playing, paused }

/// AI 配音走原生 Android TextToSpeech（平台通道），避免 flutter_tts 旧插件
/// 在 Flutter 现代 Gradle 插件加载器下不兼容；其余平台安全降级为无操作。
class AppState {
  static const _tts = MethodChannel('com.timenw.sanzijing/tts');
  static const _rec = MethodChannel('com.timenw.sanzijing/recorder');
  final AudioPlayer parentPlayer = AudioPlayer();
  final AudioPlayer childPlayer = AudioPlayer();

  String? _childPath;
  String? _parentPath;
  String? get childPath => _childPath;
  String? get parentPath => _parentPath;
  bool _ttsReady = false;
  bool _recReady = false;

  AppState() {
    _initTts();
    _initRecorder();
  }

  Future<void> _initTts() async {
    try {
      await _tts.invokeMethod('init', {'rate': 0.6});
      _ttsReady = true;
    } on PlatformException {
      _ttsReady = false;
    }
  }

  Future<void> _initRecorder() async {
    try {
      await _rec.invokeMethod('init');
      _recReady = true;
    } on PlatformException {
      _recReady = false;
    }
  }

  /// AI 配音：经原生 TTS 朗读指定句子。
  Future<void> speakAi(String text) async {
    if (!_ttsReady) await _initTts();
    if (!_ttsReady) return;
    try {
      await _tts.invokeMethod('speak', {'text': text});
    } on PlatformException {
      // 平台不支持时静默降级
    }
  }

  Future<void> stopAi() async {
    try {
      await _tts.invokeMethod('stop');
    } on PlatformException {
      // ignore
    }
  }

  /// 录音（家长或孩子）。原生 MediaRecorder 录到文件，返回路径。
  Future<String> startRecording(String who) async {
    if (!_recReady) await _initRecorder();
    if (!_recReady) {
      throw PlatformException(code: 'recorder_unavailable', message: '录音不可用');
    }
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/${who}_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _rec.invokeMethod('start', {'path': path});
    return path;
  }

  Future<String?> stopRecording(String who) async {
    final path = await _rec.invokeMethod<String>('stop');
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

  /// 三轨对比：AI 朗读 ->（可选）家长录音 -> 孩子录音。
  Future<void> playCompare(String sentence, {bool hasParent = false}) async {
    await stopCompare();
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
    await stopAi();
    await parentPlayer.stop();
    await childPlayer.stop();
  }

  void dispose() {
    stopAi();
    try {
      _rec.invokeMethod('stop');
    } on PlatformException {
      // ignore
    }
    parentPlayer.dispose();
    childPlayer.dispose();
  }
}
