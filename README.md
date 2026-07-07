# 亲子共读三字经

Flutter App：三字经全文浏览 + AI 配音朗读 + 家长/孩子跟读录音三轨对比。

## 功能
- 全文按段落分句展示，逐句点读
- AI 配音：flutter_tts 实时中文朗读（慢速，适合跟读）
- 录音：家长 / 孩子分别录音（record 6.x）
- 三轨对比：AI 朗读 → 家长录音 → 孩子录音 依次播放对比
- 最近一次录音自动保存（shared_preferences），下次打开仍可回放

## 技术栈
- flutter / provider
- just_audio 0.10.6（回放）
- record ^6.1.0（录音，RecordConfig API）
- flutter_tts ^4.2.0（AI 配音）
- shared_preferences ^2.2.3、path_provider ^2.1.5

## 构建说明（Android）
- AGP 8.5.2 / Gradle 8.9 / Kotlin 1.9.24
- 因 AGP 8.x 禁止同构建中插件版本不一致，已在 pubspec.yaml 用
  dependency_overrides 将两个 8.x 平台插件降级到 7.x（较旧、被兼容）：
  path_provider_android: 2.2.3、shared_preferences_android: 2.3.1

## 运行
```
flutter pub get
flutter run
```
