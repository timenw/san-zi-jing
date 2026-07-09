package com.timenw.sanzijing

import android.Manifest
import android.content.pm.PackageManager
import android.media.MediaRecorder
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity : FlutterActivity() {
    private val TTS_CHANNEL = "com.timenw.sanzijing/tts"
    private val REC_CHANNEL = "com.timenw.sanzijing/recorder"
    private val REQ_REC = 1001

    private var tts: TextToSpeech? = null
    private var recorder: MediaRecorder? = null
    private var recordingPath: String? = null
    private var ttsChannel: MethodChannel? = null
    private var speaking = false

    // 录音权限异步请求期间，暂存 MethodChannel 结果，待用户授权后再返回。
    private var pendingRecResult: MethodChannel.Result? = null
    private var pendingRecPath: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ---- TTS 通道：原生 Android TextToSpeech ----
        // 关键修复：init 必须等 TextToSpeech 引擎真正就绪（onInit 回调）后才
        // result.success，否则首次朗读时引擎仍为 null 而静音。
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TTS_CHANNEL)
        ttsChannel = channel
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "init" -> {
                    if (tts != null) {
                        result.success(true)
                        return@setMethodCallHandler
                    }
                    val rate = (call.argument<Double>("rate") ?: 1.0).toFloat()
                    tts = TextToSpeech(this) { status ->
                        if (status == TextToSpeech.SUCCESS) {
                            tts?.language = Locale.SIMPLIFIED_CHINESE
                            tts?.setSpeechRate(rate.coerceIn(0.1f, 2.0f))
                            tts?.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
                                override fun onStart(utteranceId: String?) {}
                                override fun onDone(utteranceId: String?) { notifyTtsDone() }

                                @Deprecated("Deprecated in Java")
                                override fun onError(utteranceId: String?) { notifyTtsDone() }
                            })
                            result.success(true)
                        } else {
                            tts = null
                            result.success(false)
                        }
                    }
                }
                "speak" -> {
                    val ok = speak(call.argument<String>("text") ?: "")
                    result.success(ok)
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
        // 关键修复：Android 6.0+ 需在运行时申请 RECORD_AUDIO 权限，否则
        // MediaRecorder.start() 抛 SecurityException，录音按钮点了无任何反馈。
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, REC_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "init" -> result.success(null)
                    "start" -> {
                        val path = call.argument<String>("path")
                            ?: return@setMethodCallHandler result.error("no_path", "path required", null)
                        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)
                            == PackageManager.PERMISSION_GRANTED
                        ) {
                            try {
                                startRecording(path)
                                result.success(null)
                            } catch (e: Exception) {
                                result.error("rec_start_failed", e.message, null)
                            }
                        } else {
                            pendingRecResult = result
                            pendingRecPath = path
                            ActivityCompat.requestPermissions(
                                this,
                                arrayOf(Manifest.permission.RECORD_AUDIO),
                                REQ_REC
                            )
                        }
                    }
                    "stop" -> {
                        try {
                            val p = stopRecording()
                            result.success(p)
                        } catch (e: Exception) {
                            result.error("rec_stop_failed", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQ_REC) {
            if (grantResults.isNotEmpty() &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED &&
                pendingRecPath != null
            ) {
                try {
                    startRecording(pendingRecPath!!)
                    pendingRecResult?.success(null)
                } catch (e: Exception) {
                    pendingRecResult?.error("rec_start_failed", e.message, null)
                }
            } else {
                pendingRecResult?.error("permission_denied", "需要麦克风权限才能录音", null)
            }
            pendingRecResult = null
            pendingRecPath = null
        }
    }

    // 由 UtteranceProgressListener 在朗读完毕后回调 Flutter（通知 onDone），
    // 供 Dart 端串联顺序三轨对比。
    private fun notifyTtsDone() {
        if (!speaking) return
        speaking = false
        ttsChannel?.invokeMethod("onDone", null)
    }

    private fun speak(text: String): Boolean {
        val t = tts ?: return false
        speaking = true
        t.speak(text, TextToSpeech.QUEUE_FLUSH, null, "sanzi")
        return true
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
