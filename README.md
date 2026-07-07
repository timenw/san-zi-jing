# 亲子共读三字经

Flutter App：三字经全文浏览 + AI 配音朗读 + 家长/孩子跟读录音三轨对比。

## 功能
- 全文按段落分句展示，逐句点读
- AI 配音：原生 Android TextToSpeech（平台通道，慢速中文朗读，适合跟读）
- 录音：家长 / 孩子分别录音（record 6.x）
- 三轨对比：AI 朗读 → 家长录音 → 孩子录音 依次播放对比
- 最近一次录音自动保存（shared_preferences），下次打开仍可回放

## 技术栈
- flutter / provider
- just_audio 0.9.38（回放）
- record ^6.1.0（录音，RecordConfig API）
- 原生 Android TextToSpeech（MethodChannel，替代 flutter_tts 4.2.x 的旧插件写法）
- shared_preferences ^2.2.3、path_provider ^2.1.5

## 构建说明（Android）
- 采用 Flutter 3.24.5 默认模板对应的 Gradle 配置：
  AGP 8.3.0 / Gradle 8.10.2 / Kotlin 1.9.22（与 flutter-plugin-loader 1.0.0 匹配）
- 不使用 dependency_overrides；依赖平台插件各自解析的兼容版本
- just_audio 需要 NDK 26.1.10909125（AGP 8.3.0 默认已满足，app/build.gradle 显式锁定）

## 运行
```
flutter pub get
flutter run
```
