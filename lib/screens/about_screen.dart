import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('关于')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Logo
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFD4A055),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  '三\n字\n经',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              '亲子共读三字经',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const Center(
            child: Text('版本 1.0.0', style: TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 32),
          _buildSection('功能介绍', [
            'AI老师标准朗读：每句三字经由AI生成标准普通话配音',
            '家长录音：家长可以录下自己的朗读，作为示范',
            '宝贝跟读：孩子跟着AI或家长的声音练习朗读',
            '三轨比对：AI、家长、孩子的录音可以随时切换播放，方便对比跟读',
            '跟读模式：先听AI朗读，自动开始录音，让孩子跟着读',
            '学习进度：自动记录已练习的句子，追踪学习进度',
          ]),
          const SizedBox(height: 24),
          _buildSection('使用方法', [
            '1. 在首页选择章节，点击任意一句进入跟读',
            '2. 点击AI老师播放标准读音',
            '3. 长按麦克风图标录制家长/孩子的朗读',
            '4. 点击播放按钮可以随时切换三个版本的录音进行比对',
            '5. 点击"跟读模式"可以自动先播AI再录孩子跟读',
            '6. 录音保存在本地，保护隐私',
          ]),
          const SizedBox(height: 24),
          _buildSection('关于三字经', [
            '《三字经》相传为南宋王应麟所著，是中国古代启蒙教育的经典教材。',
            '全书三字一句，两句一韵，朗朗上口，涵盖了教育、伦理、天文、地理、历史、勤学等方面的内容。',
            '本App收录通行本全文共392句。',
          ]),
          const SizedBox(height: 24),
          _buildSection('说明', [
            'AI配音由Microsoft Edge TTS生成（XiaoxiaoNeural中文女声）',
            '所有录音存储在本地设备，不会上传到服务器',
            '本应用为开源免费软件',
          ]),
          const SizedBox(height: 32),
          Center(
            child: Text(
              '愿每个孩子都能在陪伴中快乐学习',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD4A055),
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('· ', style: TextStyle(color: Color(0xFFD4A055), fontWeight: FontWeight.bold)),
              Expanded(child: Text(item, style: const TextStyle(fontSize: 14, height: 1.5))),
            ],
          ),
        )),
      ],
    );
  }
}
