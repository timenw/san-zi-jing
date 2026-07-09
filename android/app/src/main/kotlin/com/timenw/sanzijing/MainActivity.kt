package com.timenw.sanzijing

import android.Manifest
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val REC_CHANNEL = "com.timenw.sanzijing/recorder"
    private val REQ_REC = 1001

    private var recorder: android.media.MediaRecorder? = null
    private var recordingPath: String? = null

    // 录音权限异步请求期间，暂存 MethodChannel 结果，待用户授权后再返回。
    private var pendingRecResult: MethodChannel.Result? = null
    private var pendingRecPath: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 朗读已改为预录语音包（assets/audio 内 mp3，由 Dart 端 just_audio 播放），
        // 此处仅需保留录音通道（原生 MediaRecorder）。
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

    // ---------- Recorder ----------
    private fun startRecording(path: String) {
        stopRecording()
        val mr = android.media.MediaRecorder(this).apply {
            setAudioSource(android.media.MediaRecorder.AudioSource.MIC)
            setOutputFormat(android.media.MediaRecorder.OutputFormat.MPEG_4)
            setAudioEncoder(android.media.MediaRecorder.AudioEncoder.AAC)
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
        stopRecording()
        super.onDestroy()
    }
}
