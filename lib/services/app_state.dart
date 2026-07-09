import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/san_zi_jing.dart';

enum PlayState { stopped, playing, paused }

/// 朗读来源：预录语音包（assets/audio 内每句一个 mp3）。
/// 不再依赖设备原生 TTS，所有平台一致发音、离线可用。
class AppState extends ChangeNotifier {
  static const _rec = MethodChannel('com.timenw.sanzijing/recorder');
  final AudioPlayer player = AudioPlayer();

  // 每句独立的录音路径：key = verse.id，如 { 'v0_0': '/.../child_v0_0.m4a' }
  final Map<String, String> _childRecs = {};
  final Map<String, String> _parentRecs = {};

  bool _recReady = false;

  // 学习进度：以句子稳定 id 为 key
  final Set<String> _readVerses = {};
  final Set<String> _recordedVerses = {};

  PlayState _playState = PlayState.stopped;
  String? _playingVerseId; // 正在播放朗读的句子 id

  AppState() {
    _initRecorder();
    player.playerStateStream.listen((st) {
      if (st.processingState == ProcessingState.completed) {
        _playState = PlayState.stopped;
        _playingVerseId = null;
        notifyListeners();
      } else if (st.playing) {
        _playState = PlayState.playing;
        notifyListeners();
      } else if (st.processingState == ProcessingState.ready) {
        _playState = PlayState.paused;
        notifyListeners();
      }
    });
  }

  String? get playingVerseId => _playingVerseId;
  bool get isPlaying => _playState == PlayState.playing;
  bool isPlayingVerse(String id) => _playState == PlayState.playing && _playingVerseId == id;

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

  Future<void> _initRecorder() async {
    try {
      await _rec.invokeMethod('init');
      _recReady = true;
    } on PlatformException {
      _recReady = false;
    }
  }

  /// 朗读指定句子：播放预录语音包 assets/audio/<id>.mp3。
  /// 返回 true=已发起播放；false=该句音频资源缺失。
  Future<bool> playVerse(String id) async {
    await player.stop();
    try {
      await player.setAsset('assets/audio/$id.mp3');
    } on Exception {
      return false;
    }
    _playingVerseId = id;
    _playState = PlayState.playing;
    notifyListeners();
    try {
      await player.play();
    } on Exception {
      // 播放失败，重置状态
      _playState = PlayState.stopped;
      _playingVerseId = null;
      notifyListeners();
      return false;
    }
    return true;
  }

  Future<void> stopAudio() async {
    try {
      await player.stop();
    } on Exception {
      // ignore
    }
    _playState = PlayState.stopped;
    _playingVerseId = null;
    notifyListeners();
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

  /// 三轨对比：预录朗读 ->（可选）家长录音 -> 孩子录音，依次播放。
  Future<void> playCompare(String verseId, {bool hasParent = false}) async {
    await stopAudio();
    final childPath = _childRecs[verseId];
    final parentPath = _parentRecs[verseId];

    final queue = <Future<void> Function()>[];
    queue.add(() => _playAssetThen(verseId, null));
    if (hasParent && parentPath != null) {
      queue.add(() => _playFileThen(parentPath, null));
    }
    if (childPath != null) {
      queue.add(() => _playFileThen(childPath, null));
    }
    await _runQueue(queue);
  }

  Future<void> _playAssetThen(String id, void Function()? after) async {
    final ok = await playVerse(id);
    if (!ok) {
      after?.call();
      return;
    }
    final done = Completer<void>();
    late final StreamSubscription sub;
    sub = player.playerStateStream.listen((st) {
      if (st.processingState == ProcessingState.completed) {
        sub.cancel();
        done.complete();
      }
    });
    await done.future;
    after?.call();
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
    after?.call();
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
    _playingVerseId = null;
    await player.play();
  }

  Future<void> stopCompare() async {
    await stopAudio();
  }

  @override
  void dispose() {
    try {
      _rec.invokeMethod('stop');
    } on PlatformException {
      // ignore
    }
    player.dispose();
    super.dispose();
  }
}
