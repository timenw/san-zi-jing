package com.timenw.sanzijing

import android.media.MediaRecorder
import android.os.Bundle
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.Locale

class MainActivity : FlutterActivity() {
    private val TTS_CHANNEL = "com.timenw.sanzijing/tts"
    private val REC_CHANNEL = "com.timenw.sanzijing/recorder"

    private var tts: TextToSpeech? = null
    private var recorder: MediaRecorder? = null
    private var recordingPath: String? = null
    private var ttsChannel: MethodChannel? = null
    private var speaking = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ---- TTS 通道：原生 Android TextToSpeech ----
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TTS_CHANNEL)
        ttsChannel = channel
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "init" -> {
                    val rate = (call.argument<Double>("rate") ?: 1.0).toFloat()
                    initTts(rate)
                    result.success(null)
                }
                "speak" -> {
                    speak(call.argument<String>("text") ?: "")
                    result.success(null)
                }
                "stop" -> {
                    tts?.stop()
                    speaking = false
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // ---- 录音通道：原生 MediaRecorder ----
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, REC_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "init" -> result.success(null)
                    "start" -> {
                        val path = call.argument<String>("path")
                            ?: return@setMethodCallHandler result.error("no_path", "path required", null)
                        startRecording(path)
                        result.success(null)
                    }
                    "stop" -> {
                        stopRecording()
                        result.success(recordingPath)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    // 由 UtteranceProgressListener 在朗读完毕后回调 Flutter（通知 onDone），
    // 供 Dart 端串联顺序三轨对比。
    private fun notifyTtsDone() {
        if (!speaking) return
        speaking = false
        ttsChannel?.invokeMethod("onDone", null)
    }

    // ---------- TTS ----------
    private fun initTts(rate: Float) {
        if (tts != null) return
        tts = TextToSpeech(this) { status ->
            if (status == TextToSpeech.SUCCESS) {
                tts?.language = Locale.SIMPLIFIED_CHINESE
                tts?.setSpeechRate(rate.coerceIn(0.1f, 2.0f))
                tts?.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
                    override fun onStart(utteranceId: String?) {}
                    override fun onDone(utteranceId: String?) {
                        notifyTtsDone()
                    }

                    @Deprecated("Deprecated in Java")
                    override fun onError(utteranceId: String?) {
                        notifyTtsDone()
                    }
                })
            }
        }
    }

    private fun speak(text: String) {
        if (tts == null) initTts(0.6f)
        speaking = true
        tts?.speak(text, TextToSpeech.QUEUE_FLUSH, null, "sanzi")
    }

    // ---------- Recorder ----------
    private fun startRecording(path: String) {
        stopRecording()
        val mr = MediaRecorder(this).apply {
            setAudioSource(MediaRecorder.AudioSource.MIC)
            setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
            setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
            setAudioSamplingRate(44100)
            setAudioEncodingBitRate(128000)
            setOutputFile(path)
        }
        mr.prepare()
        mr.start()
        recorder = mr
        recordingPath = path
    }

    private fun stopRecording(): String? {
        return try {
            recorder?.stop()
            recorder?.release()
            recordingPath
        } catch (_: Exception) {
            null
        } finally {
            recorder = null
        }
    }

    override fun onDestroy() {
        tts?.stop()
        tts?.shutdown()
        tts = null
        ttsChannel = null
        stopRecording()
        super.onDestroy()
    }
}
