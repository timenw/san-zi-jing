import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/san_zi_jing.dart';

enum PlayState { stopped, playing, paused }

/// AI 配音走原生 Android TextToSpeech（平台通道），避免 flutter_tts 旧插件
/// 在 Flutter 现代 Gradle 插件加载器下不兼容；其余平台安全降级为无操作。
/// 同时管理「已读 / 已录」学习进度，持久化到 SharedPreferences。
class AppState extends ChangeNotifier {
  static const _tts = MethodChannel('com.timenw.sanzijing/tts');
  static const _rec = MethodChannel('com.timenw.sanzijing/recorder');
  final AudioPlayer player = AudioPlayer();

  // 每句独立的录音路径：key = verse.id，如 { 'v0_0': '/.../child_v0_0.m4a' }
  final Map<String, String> _childRecs = {};
  final Map<String, String> _parentRecs = {};

  bool _ttsReady = false;
  bool _zhReady = false; // 中文语音包是否可用（很多设备引擎就绪却缺中文语音）
  bool _recReady = false;

  // 学习进度：以句子稳定 id 为 key
  final Set<String> _readVerses = {};
  final Set<String> _recordedVerses = {};

  String? childPathOf(String id) => _childRecs[id];
  String? parentPathOf(String id) => _parentRecs[id];
  bool isRead(String id) => _readVerses.contains(id);
  bool isRecorded(String id) => _recordedVerses.contains(id);
  int get readCount => _readVerses.length;
  int get recordedCount => _recordedVerses.length;
  int get totalVerses => SanZiJingData.total;

  void toggleRead(String id) {
    if (_readVerses.contains(id)) {
      _readVerses.remove(id);
    } else {
      _readVerses.add(id);
    }
    _saveProgress();
    notifyListeners();
  }

  void markRecorded(String id) {
    if (_recordedVerses.add(id)) {
      _saveProgress();
      notifyListeners();
    }
  }

  AppState() {
    _initTts();
    _initRecorder();
  }

  Future<void> _initTts() async {
    try {
      // 原生返回 {'tts': 引擎就绪?, 'zh': 中文语音可用?}
      final r = await _tts.invokeMethod<Map<dynamic, dynamic>>(
          'init', {'rate': 0.6});
      _ttsReady = r?['tts'] == true;
      _zhReady = r?['zh'] == true;
    } on PlatformException {
      _ttsReady = false;
      _zhReady = false;
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

  /// AI 配音结果状态。
  enum SpeakResult { ok, noEngine, noChinese }

  /// AI 配音：经原生 TTS 朗读指定句子。
  /// 返回 ok=已发起；noEngine=设备无 TTS 引擎；noChinese=缺中文语音包。
  Future<SpeakResult> speakAi(String text) async {
    if (!_ttsReady) await _initTts();
    if (!_ttsReady) return SpeakResult.noEngine;
    if (!_zhReady) return SpeakResult.noChinese;
    try {
      await _tts.invokeMethod('speak', {'text': text});
      return SpeakResult.ok;
    } on PlatformException {
      return SpeakResult.noEngine;
    }
  }

  /// 跳转系统 TTS 设置（引导安装中文语音包）。
  Future<void> openTtsSettings() async {
    try {
      await _tts.invokeMethod('openSettings');
    } on PlatformException {
      // 设备无该设置页，忽略
    }
  }

  /// 注册 TTS 完成回调（原生朗读结束时触发），用于顺序三轨。
  void onTtsDone(Future<void> Function() cb) {
    _ttsDone = cb;
    _ensureTtsCallbackRegistered();
  }

  Future<void> Function()? _ttsDone;
  bool _ttsCbRegistered = false;

  void _ensureTtsCallbackRegistered() {
    if (_ttsCbRegistered) return;
    _ttsCbRegistered = true;
    _tts.setMethodCallHandler((call) async {
      if (call.method == 'onDone') {
        await _ttsDone?.call();
      }
      return;
    });
  }

  Future<void> stopAi() async {
    try {
      await _tts.invokeMethod('stop');
    } on PlatformException {
      // ignore
    }
  }

  /// 录音（家长或孩子），按 verse.id 独立保存。
  /// 抛出的异常会向上传播，由 UI 层捕获并提示用户（如未授权麦克风）。
  Future<String> startRecording(String who, String verseId) async {
    if (!_recReady) await _initRecorder();
    if (!_recReady) {
      throw PlatformException(code: 'recorder_unavailable', message: '录音不可用');
    }
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/${who}_$verseId.m4a';
    // 原生端在 Android 6.0+ 会弹出权限请求，用户拒绝时抛异常。
    await _rec.invokeMethod('start', {'path': path});
    return path;
  }

  Future<String?> stopRecording(String who, String verseId) async {
    final path = await _rec.invokeMethod<String>('stop');
    if (path != null && path.isNotEmpty) {
      if (who == 'child') {
        _childRecs[verseId] = path;
      } else {
        _parentRecs[verseId] = path;
      }
      await _saveRecs();
      markRecorded(verseId);
    }
    return path;
  }

  Future<void> _saveRecs() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('child_recs', _mapToJson(_childRecs));
    await sp.setString('parent_recs', _mapToJson(_parentRecs));
  }

  String _mapToJson(Map<String, String> m) =>
      '{${m.entries.map((e) => '"${e.key}":"${e.value}"').join(',')}}';

  Future<void> _saveProgress() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList('read_verses', _readVerses.toList());
    await sp.setStringList('recorded_verses', _recordedVerses.toList());
  }

  Future<void> loadLast() async {
    final sp = await SharedPreferences.getInstance();
    _readVerses.addAll(sp.getStringList('read_verses') ?? []);
    _recordedVerses.addAll(sp.getStringList('recorded_verses') ?? []);
    _childRecs.addAll(_jsonToMap(sp.getString('child_recs')));
    _parentRecs.addAll(_jsonToMap(sp.getString('parent_recs')));
  }

  Map<String, String> _jsonToMap(String? s) {
    final Map<String, String> out = {};
    if (s == null || s.isEmpty) return out;
    final body = s.substring(1, s.length - 1);
    if (body.trim().isEmpty) return out;
    for (final part in body.split(',')) {
      final kv = part.split(':');
      if (kv.length == 2) {
        out[kv[0].trim().replaceAll('"', '')] =
            kv[1].trim().replaceAll('"', '');
      }
    }
    return out;
  }

  /// 三轨对比：AI 朗读 ->（可选）家长录音 -> 孩子录音，依次播放。
  /// 用原生 TTS 完成回调串联，避免时长估算误差。
  Future<void> playCompare(String verseId, {bool hasParent = false}) async {
    await stopCompare();
    final verse = SanZiJingData.verseById(verseId);
    final childPath = _childRecs[verseId];
    final parentPath = _parentRecs[verseId];

    final queue = <Future<void> Function()>[];
    queue.add(() async {
      final ok = await speakAi(verse.speakText);
      // 若原生 TTS 不可用（非 Android），直接跳过该段。
      final completer = Completer<void>();
      if (!ok) {
        completer.complete();
      } else {
        onTtsDone(() async => completer.complete());
      }
      await completer.future;
    });
    if (hasParent && parentPath != null) {
      queue.add(() => _playFileThen(parentPath, null));
    }
    if (childPath != null) {
      queue.add(() => _playFileThen(childPath, null));
    }
    await _runQueue(queue);
  }

  Future<void> _playFileThen(String path, void Function()? after) async {
    try {
      await player.stop();
      await player.setFilePath(path);
      await player.play();
      final done = Completer<void>();
      late final StreamSubscription sub;
      sub = player.playerStateStream.listen((st) {
        if (st.processingState == ProcessingState.completed) {
          sub.cancel();
          done.complete();
        }
      });
      await done.future;
    } on Exception {
      // 文件可能已失效，忽略
    }
  }

  Future<void> _runQueue(List<Future<void> Function()> queue) async {
    for (final step in queue) {
      await step();
    }
  }

  Future<void> playFile(String who, String verseId) async {
    final path =
        who == 'child' ? _childRecs[verseId] : _parentRecs[verseId];
    if (path == null) return;
    await player.stop();
    await player.setFilePath(path);
    await player.play();
  }

  Future<void> stopCompare() async {
    await stopAi();
    try {
      await player.stop();
    } on Exception {
      // ignore
    }
  }

  @override
  void dispose() {
    stopAi();
    try {
      _rec.invokeMethod('stop');
    } on PlatformException {
      // ignore
    }
    player.dispose();
    super.dispose();
  }
}
