/// 三字经数据模型（分句 + 拼音 + 释义）。
///
/// 结构层级：Section（章节） -> Verse（一句，含若干 3 字小句） -> SubVerse（3 字小句 + 拼音）。
/// Verse 带稳定 [id]（如 "v0_0"），作为进度/录音的持久化 key，文本改动也不丢进度。

class SubVerse {
  final String text; // 3 字小句，如「人之初」
  final String pinyin; // 对应拼音，如「rén zhī chū」
  const SubVerse(this.text, this.pinyin);
}

class Verse {
  final String id;
  final String text; // 完整句，如「人之初，性本善。性相近，习相远。」
  final List<SubVerse> subVerses;
  final String meaning; // 简短释义

  const Verse({
    required this.id,
    required this.text,
    required this.subVerses,
    required this.meaning,
  });

  /// 整句拼音（由各小句拼音拼接）。
  String get fullPinyin => subVerses.map((s) => s.pinyin).join('  ');

  /// 整句去掉标点后的纯字（用于朗读）。
  String get speakText => text.replaceAll(RegExp(r'[，。、]'), '');
}

class Section {
  final int index;
  final String title;
  final String intro; // 章节一句话简介
  final List<Verse> verses;

  const Section({
    required this.index,
    required this.title,
    required this.intro,
    required this.verses,
  });
}

class SanZiJingData {
  static const int total = 22; // 总句数

  static final List<Section> sections = [
    Section(
      index: 0,
      title: '一、人之初',
      intro: '讲人的本性善良，以及教育的重要。',
      verses: [
        Verse(
          id: 'v0_0',
          text: '人之初，性本善。性相近，习相远。',
          subVerses: const [
            SubVerse('人之初', 'rén zhī chū'),
            SubVerse('性本善', 'xìng běn shàn'),
            SubVerse('性相近', 'xìng xiāng jìn'),
            SubVerse('习相远', 'xí xiāng yuǎn'),
          ],
          meaning:
              '人刚生下来时，本性都是善良的。只是后来的习染不同，彼此的差别才越来越远。',
        ),
        Verse(
          id: 'v0_1',
          text: '苟不教，性乃迁。教之道，贵以专。',
          subVerses: const [
            SubVerse('苟不教', 'gǒu bù jiào'),
            SubVerse('性乃迁', 'xìng nǎi qiān'),
            SubVerse('教之道', 'jiào zhī dào'),
            SubVerse('贵以专', 'guì yǐ zhuān'),
          ],
          meaning: '如果不好好教育，本性就会变坏。教育的方法，贵在专心一致。',
        ),
        Verse(
          id: 'v0_2',
          text: '昔孟母，择邻处。子不学，断机杼。',
          subVerses: const [
            SubVerse('昔孟母', 'xī mèng mǔ'),
            SubVerse('择邻处', 'zé lín chǔ'),
            SubVerse('子不学', 'zǐ bù xué'),
            SubVerse('断机杼', 'duàn jī zhù'),
          ],
          meaning:
              '从前孟子的母亲，为了孩子选择好邻居。孟子逃学，她割断织布机上的线来教育他。',
        ),
        Verse(
          id: 'v0_3',
          text: '窦燕山，有义方。教五子，名俱扬。',
          subVerses: const [
            SubVerse('窦燕山', 'dòu yān shān'),
            SubVerse('有义方', 'yǒu yì fāng'),
            SubVerse('教五子', 'jiào wǔ zǐ'),
            SubVerse('名俱扬', 'míng jù yáng'),
          ],
          meaning: '窦燕山教育孩子很有方法，他教导的五个儿子都很有名。',
        ),
        Verse(
          id: 'v0_4',
          text: '养不教，父之过。教不严，师之惰。',
          subVerses: const [
            SubVerse('养不教', 'yǎng bù jiào'),
            SubVerse('父之过', 'fù zhī guò'),
            SubVerse('教不严', 'jiào bù yán'),
            SubVerse('师之惰', 'shī zhī duò'),
          ],
          meaning:
              '生养孩子却不教育，是父亲的过错；教育学生不严格，是老师的懒惰。',
        ),
        Verse(
          id: 'v0_5',
          text: '子不学，非所宜。幼不学，老何为。',
          subVerses: const [
            SubVerse('子不学', 'zǐ bù xué'),
            SubVerse('非所宜', 'fēi suǒ yí'),
            SubVerse('幼不学', 'yòu bù xué'),
            SubVerse('老何为', 'lǎo hé wéi'),
          ],
          meaning: '小孩子不肯学习，是不应该的。小时候不学，老了能有什么作为呢？',
        ),
        Verse(
          id: 'v0_6',
          text: '玉不琢，不成器。人不学，不知义。',
          subVerses: const [
            SubVerse('玉不琢', 'yù bù zhuó'),
            SubVerse('不成器', 'bù chéng qì'),
            SubVerse('人不学', 'rén bù xué'),
            SubVerse('不知义', 'bù zhī yì'),
          ],
          meaning: '玉不打磨雕刻，就不能成为器物；人不学习，就不懂得道理。',
        ),
      ],
    ),
    Section(
      index: 1,
      title: '二、首孝悌',
      intro: '讲孝顺父母、敬爱兄长，以及为学入门。',
      verses: [
        Verse(
          id: 'v1_0',
          text: '为人子，方少时。亲师友，习礼仪。',
          subVerses: const [
            SubVerse('为人子', 'wéi rén zǐ'),
            SubVerse('方少时', 'fāng shào shí'),
            SubVerse('亲师友', 'qīn shī yǒu'),
            SubVerse('习礼仪', 'xí lǐ yí'),
          ],
          meaning:
              '做儿女的，在年少的时候，要亲近老师和朋友，学习待人接物的礼节。',
        ),
        Verse(
          id: 'v1_1',
          text: '香九龄，能温席。孝于亲，所当执。',
          subVerses: const [
            SubVerse('香九龄', 'xiāng jiǔ líng'),
            SubVerse('能温席', 'néng wēn xí'),
            SubVerse('孝于亲', 'xiào yú qīn'),
            SubVerse('所当执', 'suǒ dāng zhí'),
          ],
          meaning: '黄香九岁时就能为父亲暖被窝。孝顺父母，是应该做到的。',
        ),
        Verse(
          id: 'v1_2',
          text: '融四岁，能让梨。弟于长，宜先知。',
          subVerses: const [
            SubVerse('融四岁', 'róng sì suì'),
            SubVerse('能让梨', 'néng ràng lí'),
            SubVerse('弟于长', 'tì yú zhǎng'),
            SubVerse('宜先知', 'yí xiān zhī'),
          ],
          meaning: '孔融四岁时就懂得把大梨让给哥哥。尊敬兄长，应该早早懂得。',
        ),
        Verse(
          id: 'v1_3',
          text: '首孝悌，次见闻。知某数，识某文。',
          subVerses: const [
            SubVerse('首孝悌', 'shǒu xiào tì'),
            SubVerse('次见闻', 'cì jiàn wén'),
            SubVerse('知某数', 'zhī mǒu shù'),
            SubVerse('识某文', 'shí mǒu wén'),
          ],
          meaning:
              '首先要孝顺父母、敬爱兄长，其次才是增长见闻。要会数数，要认字读书。',
        ),
        Verse(
          id: 'v1_4',
          text: '一而十，十而百。百而千，千而万。',
          subVerses: const [
            SubVerse('一而十', 'yī ér shí'),
            SubVerse('十而百', 'shí ér bǎi'),
            SubVerse('百而千', 'bǎi ér qiān'),
            SubVerse('千而万', 'qiān ér wàn'),
          ],
          meaning:
              '从一到十，十到百，百到千，千到万，数目就是这样推算下去的。',
        ),
      ],
    ),
    Section(
      index: 2,
      title: '三、三才者',
      intro: '讲天地自然常识：三才、三光、四时、四方、五行。',
      verses: [
        Verse(
          id: 'v2_0',
          text: '三才者，天地人。三光者，日月星。',
          subVerses: const [
            SubVerse('三才者', 'sān cái zhě'),
            SubVerse('天地人', 'tiān dì rén'),
            SubVerse('三光者', 'sān guāng zhě'),
            SubVerse('日月星', 'rì yuè xīng'),
          ],
          meaning: '三才指天、地、人。三光指日、月、星。',
        ),
        Verse(
          id: 'v2_1',
          text: '三纲者，君臣义。父子亲，夫妇顺。',
          subVerses: const [
            SubVerse('三纲者', 'sān gāng zhě'),
            SubVerse('君臣义', 'jūn chén yì'),
            SubVerse('父子亲', 'fù zǐ qīn'),
            SubVerse('夫妇顺', 'fū fù shùn'),
          ],
          meaning:
              '三纲是君臣间要讲道义，父子间要相亲，夫妻间要和顺。',
        ),
        Verse(
          id: 'v2_2',
          text: '曰春夏，曰秋冬。此四时，运不穷。',
          subVerses: const [
            SubVerse('曰春夏', 'yuē chūn xià'),
            SubVerse('曰秋冬', 'yuē qiū dōng'),
            SubVerse('此四时', 'cǐ sì shí'),
            SubVerse('运不穷', 'yùn bù qióng'),
          ],
          meaning: '春、夏、秋、冬叫做四季，它们循环运转，没有尽头。',
        ),
        Verse(
          id: 'v2_3',
          text: '曰南北，曰西东。此四方，应乎中。',
          subVerses: const [
            SubVerse('曰南北', 'yuē nán běi'),
            SubVerse('曰西东', 'yuē xī dōng'),
            SubVerse('此四方', 'cǐ sì fāng'),
            SubVerse('应乎中', 'yìng hū zhōng'),
          ],
          meaning: '南、北、西、东叫做四方，它们都围绕着中央。',
        ),
        Verse(
          id: 'v2_4',
          text: '曰水火，木金土。此五行，本乎数。',
          subVerses: const [
            SubVerse('曰水火', 'yuē shuǐ huǒ'),
            SubVerse('木金土', 'mù jīn tǔ'),
            SubVerse('此五行', 'cǐ wǔ xíng'),
            SubVerse('本乎数', 'běn hū shù'),
          ],
          meaning: '水、火、木、金、土叫做五行，它们来源于自然的理数。',
        ),
      ],
    ),
    Section(
      index: 3,
      title: '四、勤有功',
      intro: '讲勤学有成、嬉戏无益的道理。',
      verses: [
        Verse(
          id: 'v3_0',
          text: '犬守夜，鸡司晨。苟不学，曷为人。',
          subVerses: const [
            SubVerse('犬守夜', 'quǎn shǒu yè'),
            SubVerse('鸡司晨', 'jī sī chén'),
            SubVerse('苟不学', 'gǒu bù xué'),
            SubVerse('曷为人', 'hé wéi rén'),
          ],
          meaning: '狗看门守夜，鸡报晓司晨。人要是不学习，怎么配做人呢？',
        ),
        Verse(
          id: 'v3_1',
          text: '蚕吐丝，蜂酿蜜。人不学，不如物。',
          subVerses: const [
            SubVerse('蚕吐丝', 'cán tǔ sī'),
            SubVerse('蜂酿蜜', 'fēng niàng mì'),
            SubVerse('人不学', 'rén bù xué'),
            SubVerse('不如物', 'bù rú wù'),
          ],
          meaning: '蚕会吐丝，蜂会酿蜜。人如果不学习，就不如这些小动物了。',
        ),
        Verse(
          id: 'v3_2',
          text: '幼而学，壮而行。上致君，下泽民。',
          subVerses: const [
            SubVerse('幼而学', 'yòu ér xué'),
            SubVerse('壮而行', 'zhuàng ér xíng'),
            SubVerse('上致君', 'shàng zhì jūn'),
            SubVerse('下泽民', 'xià zé mín'),
          ],
          meaning:
              '小时候努力学习，长大后付诸行动。对上能辅佐君王，对下能造福百姓。',
        ),
        Verse(
          id: 'v3_3',
          text: '扬名声，显父母。光于前，裕于后。',
          subVerses: const [
            SubVerse('扬名声', 'yáng míng shēng'),
            SubVerse('显父母', 'xiǎn fù mǔ'),
            SubVerse('光于前', 'guāng yú qián'),
            SubVerse('裕于后', 'yù yú hòu'),
          ],
          meaning: '扬名天下，荣耀父母，光耀祖先，造福后代。',
        ),
        Verse(
          id: 'v3_4',
          text: '勤有功，戏无益。戒之哉，宜勉力。',
          subVerses: const [
            SubVerse('勤有功', 'qín yǒu gōng'),
            SubVerse('戏无益', 'xì wú yì'),
            SubVerse('戒之哉', 'jiè zhī zāi'),
            SubVerse('宜勉力', 'yí miǎn lì'),
          ],
          meaning: '勤奋学习必有成就，嬉戏玩乐没有好处。要以此为戒，努力上进啊。',
        ),
      ],
    ),
  ];

  static List<Verse> get allVerses =>
      sections.expand((s) => s.verses).toList();

  static Verse verseById(String id) =>
      allVerses.firstWhere((v) => v.id == id, orElse: () => allVerses.first);
}
