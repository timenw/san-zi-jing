import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/phrase.dart';

/// 三种录音角色
enum TrackType { ai, parent, child }

/// 播放状态
enum PlayState { idle, playing, paused }

/// App全局状态管理
class AppState extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final AudioRecorder _recorder = AudioRecorder();

  late SharedPreferences _prefs;
  late Directory _recordingsDir;

  // 当前播放的句号和轨道
  int? _playingPhraseId;
  TrackType? _playingTrack;
  PlayState _playState = PlayState.idle;

  // 录音状态
  bool _isRecording = false;
  int? _recordingPhraseId;
  TrackType? _recordingTrack;
  int _recordingSeconds = 0;

  // 进度数据: practiced phrases
  Set<int> _practiced = {};

  bool _initialized = false;

  PlayState get playState => _playState;
  bool get isRecording => _isRecording;
  int? get playingPhraseId => _playingPhraseId;
  TrackType? get playingTrack => _playingTrack;
  int? get recordingPhraseId => _recordingPhraseId;
  TrackType? get recordingTrack => _recordingTrack;
  int get recordingSeconds => _recordingSeconds;
  Set<int> get practiced => _practiced;

  /// 初始化
  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    final docs = await getApplicationDocumentsDirectory();
    _recordingsDir = Directory('${docs.path}/recordings');
    if (!_recordingsDir.existsSync()) {
      _recordingsDir.createSync(recursive: true);
    }
    // Load practiced set
    _practiced = (_prefs.getStringList('practiced') ?? [])
        .map((s) => int.tryParse(s) ?? -1)
        .where((i) => i >= 0)
        .toSet();

    // Listen to player events
    _player.playerStateStream.listen((state) {
      if (state.playing) {
        _playState = PlayState.playing;
      } else if (state.processingState == ProcessingState.completed) {
        _playState = PlayState.idle;
        _playingPhraseId = null;
        _playingTrack = null;
        _player.stop();
      } else {
        _playState = PlayState.paused;
      }
      notifyListeners();
    });

    _initialized = true;
    notifyListeners();
  }

  /// 获取录音文件路径
  String? _getRecordingPath(int phraseId, TrackType track) {
    if (!_initialized) return null;
    final role = track == TrackType.parent ? 'parent' : 'child';
    return '${_recordingsDir.path}/${role}_${phraseId.toString().padLeft(3, '0')}.m4a';
  }

  /// 检查录音是否存在
  bool hasRecording(int phraseId, TrackType track) {
    if (track == TrackType.ai) return true; // AI音频总是有
    final path = _getRecordingPath(phraseId, track);
    return path != null && File(path).existsSync();
  }

  /// 播放音频
  Future<void> play(Phrase phrase, TrackType track) async {
    // Stop recording if recording
    if (_isRecording) {
      await stopRecording();
    }

    // If already playing this exact track, toggle pause
    if (_playingPhraseId == phrase.id && _playingTrack == track) {
      if (_playState == PlayState.playing) {
        await _player.pause();
      } else if (_playState == PlayState.paused) {
        await _player.play();
      }
      return;
    }

    // Stop current playback
    await _player.stop();

    String source;
    if (track == TrackType.ai) {
      source = phrase.aiAudioPath;
      await _player.setAsset(source);
    } else {
      final path = _getRecordingPath(phrase.id, track);
      if (path == null || !File(path).existsSync()) return;
      await _player.setFilePath(path);
    }

    _playingPhraseId = phrase.id;
    _playingTrack = track;
    _playState = PlayState.playing;
    notifyListeners();

    await _player.play();
  }

  /// 停止播放
  Future<void> stopPlayback() async {
    await _player.stop();
    _playState = PlayState.idle;
    _playingPhraseId = null;
    _playingTrack = null;
    notifyListeners();
  }

  /// 开始录音
  Future<bool> startRecording(int phraseId, TrackType track) async {
    if (track == TrackType.ai) return false; // AI轨道不能录

    // Stop playback
    await stopPlayback();

    // Stop any existing recording
    if (_isRecording) {
      await stopRecording();
    }

    // Check permission
    if (!await _recorder.hasPermission()) {
      return false;
    }

    final path = _getRecordingPath(phraseId, track)!;

    // Delete old recording if exists
    final oldFile = File(path);
    if (oldFile.existsSync()) {
      oldFile.deleteSync();
    }

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: path,
    );

    _isRecording = true;
    _recordingPhraseId = phraseId;
    _recordingTrack = track;
    _recordingSeconds = 0;

    // Start timer
    _recordingTimerSub = Stream.periodic(const Duration(seconds: 1), (i) => i + 1).listen((sec) {
      _recordingSeconds = sec;
      notifyListeners();
    });

    notifyListeners();
    return true;
  }

  StreamSubscription<int>? _recordingTimerSub;

  /// 停止录音
  Future<String?> stopRecording() async {
    if (!_isRecording) return null;
    final recordedPhraseId = _recordingPhraseId;
    final path = await _recorder.stop();
    _recordingTimerSub?.cancel();
    _isRecording = false;
    _recordingPhraseId = null;
    _recordingTrack = null;
    _recordingSeconds = 0;

    // Mark as practiced
    if (recordedPhraseId != null) {
      _practiced.add(recordedPhraseId);
      _savePracticed();
    }

    notifyListeners();
    return path;
  }

  /// 删除录音
  Future<void> deleteRecording(int phraseId, TrackType track) async {
    if (track == TrackType.ai) return;
    final path = _getRecordingPath(phraseId, track);
    if (path != null) {
      final file = File(path);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
    // If currently playing this, stop
    if (_playingPhraseId == phraseId && _playingTrack == track) {
      await stopPlayback();
    }
    notifyListeners();
  }

  void _savePracticed() {
    _prefs.setStringList('practiced', _practiced.map((i) => i.toString()).toList());
  }

  /// 获取进度统计
  int get totalPracticed => _practiced.length;

  @override
  void dispose() {
    _player.dispose();
    _recorder.dispose();
    _recordingTimerSub?.cancel();
    super.dispose();
  }
}
