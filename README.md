# 亲子共读三字经

> AI配音 · 家长录音 · 孩子跟读 — 三轨比对，让陪伴更有温度

## 功能

- **AI老师标准朗读**：392句三字经全程AI配音（Microsoft Edge TTS，XiaoxiaoNeural中文女声）
- **家长录音**：长按麦克风录制家长朗读，作为示范
- **宝贝跟读**：孩子跟着AI或家长的声音练习朗读并录音
- **三轨比对**：AI、家长、孩子的录音随时切换播放，方便对比跟读
- **跟读模式**：先播AI朗读，播完自动开始录音，让孩子跟着读
- **学习进度**：自动记录已练习的句子，追踪学习进度
- **每三字一段**：音频按三字一句分段，天然契合三字经韵律

## 技术栈

- Flutter 3.24+
- just_audio（音频播放）
- record（录音）
- shared_preferences（进度存储）
- provider（状态管理）

## 构建

本项目通过 GitHub Actions 自动编译 APK，无需本地配置 Flutter 环境。

```bash
# 本地构建（如已安装Flutter）
flutter pub get
flutter build apk --release
```

## 项目结构

```
lib/
  main.dart              # 入口 + 启动屏
  models/phrase.dart     # 诗句模型
  data/san_zi_jing_data.dart  # 392句数据（字符+拼音+译文）
  services/app_state.dart     # 状态管理（播放+录音+进度）
  screens/
    home_screen.dart     # 首页：章节列表+进度
    reader_screen.dart   # 跟读页：三轨音频+录音
    about_screen.dart    # 关于
scripts/
  generate_audio.py      # edge-tts批量生成392句AI配音
  generate_dart_data.py  # 生成Dart数据文件（含拼音）
assets/audio/ai/         # 392个预生成MP3音频文件
```

## 三字经版本

通行本（王应麟），共392句，分六章：
- 教育篇、人伦篇、数目篇、经典篇、历史篇、勤学篇
