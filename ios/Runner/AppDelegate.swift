import Flutter
import UIKit
import AVFoundation

/// 原生录音通道（iOS），与 Android 的 com.timenw.sanzijing/recorder 对齐：
///   init   -> 申请麦克风权限，返回 Bool（是否授权）
///   start  -> {path: 目标 m4a 路径} 开始录音（AAC/MPEG-4，与安卓一致）
///   stop   -> 停止录音并返回实际路径；未录音返回 nil
@objc class AppDelegate: FlutterAppDelegate {
  private var recorder: AVAudioRecorder?
  private var recordingURL: URL?
  private var micGranted = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    // 录音通道：在 FlutterViewController 的 messenger 上挂 MethodChannel。
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "com.timenw.sanzijing/recorder",
        binaryMessenger: controller.binaryMessenger)
      channel.setMethodCallHandler { [weak self] call, result in
        self?.handle(call, result: result)
      }
    }
    return result
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "init":
      requestMicPermission { granted in
        self.micGranted = granted
        result(granted)
      }
    case "start":
      guard let args = call.arguments as? [String: Any],
            let path = args["path"] as? String else {
        result(FlutterError(code: "no_path", message: "path required", details: nil))
        return
      }
      do {
        try startRecording(path: path)
        result(nil)
      } catch {
        result(FlutterError(code: "rec_start_failed",
                            message: error.localizedDescription, details: nil))
      }
    case "stop":
      let p = stopRecording()
      result(p?.path)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func requestMicPermission(completion: @escaping (Bool) -> Void) {
    switch AVAudioSession.sharedInstance().recordPermission {
    case .granted:
      completion(true)
    case .denied:
      completion(false)
    case .undetermined:
      AVAudioSession.sharedInstance().requestRecordPermission { granted in
        DispatchQueue.main.async { completion(granted) }
      }
    @unknown default:
      completion(false)
    }
  }

  private func startRecording(path: String) throws {
    stopRecording()
    let url = URL(fileURLWithPath: path)
    let session = AVAudioSession.sharedInstance()
    try session.setCategory(.playAndRecord,
                            mode: .default,
                            options: [.defaultToSpeaker, .mixWithOthers])
    try session.setActive(true)

    let settings: [String: Any] = [
      AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
      AVSampleRateKey: 44100,
      AVNumberOfChannelsKey: 1,
      AVEncoderBitRateKey: 128000,
      AVLinearPCMBitDepthKey: 16,
    ]
    let rec = try AVAudioRecorder(url: url, settings: settings)
    rec.prepareToRecord()
    guard rec.record() else {
      throw NSError(domain: "Recorder", code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "无法开始录音"])
    }
    recorder = rec
    recordingURL = url
  }

  private func stopRecording() -> URL? {
    let url = recordingURL
    if recorder?.isRecording == true { recorder?.stop() }
    recorder = nil
    recordingURL = nil
    try? AVAudioSession.sharedInstance().setActive(false,
                                                    options: .notifyOthersOnDeactivation)
    return url
  }
}
