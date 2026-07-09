package com.timenw.sanzijing

import android.Manifest
import android.content.Intent
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
        // init 返回 {'tts': 引擎是否就绪, 'zh': 中文语音是否可用}。
        // 关键：很多设备引擎初始化成功却没装中文语音包，speak 会静默无声，
        // 因此必须单独检测中文可用性，供 Dart 端给出「去安装语音」提示。
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TTS_CHANNEL)
        ttsChannel = channel
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "init" -> {
                    if (tts != null) {
                        val zh = zhAvailable()
                        result.success(mapOf("tts" to true, "zh" to zh))
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
                            val zh = zhAvailable()
                            result.success(mapOf("tts" to true, "zh" to zh))
                        } else {
                            tts = null
                            result.success(mapOf("tts" to false, "zh" to false))
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
                // 跳转系统 TTS 语音设置，引导用户安装中文语音包。
                "openSettings" -> {
                    try {
                        startActivity(
                            Intent().setAction("com.android.settings.TTS_SETTINGS")
                        )
                    } catch (_: Exception) {
                        // 个别设备无该设置页，忽略
                    }
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

    private fun zhAvailable(): Boolean {
        val t = tts ?: return false
        val avail = t.isLanguageAvailable(Locale.SIMPLIFIED_CHINESE)
        return avail >= TextToSpeech.LANG_AVAILABLE
    }

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
