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
  static const int total = 95; // 总句数

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
          meaning: '人刚生下来时，本性都是善良的。只是后来的习染不同，彼此的差别才越来越远。',
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
            SubVerse('择邻处', 'zé lín chù'),
            SubVerse('子不学', 'zi bù xué'),
            SubVerse('断机杼', 'duàn jī zhù'),
          ],
          meaning: '从前孟子的母亲，为了孩子选择好邻居。孟子逃学，她割断织布机上的线来教育他。',
        ),
        Verse(
          id: 'v0_3',
          text: '窦燕山，有义方。教五子，名俱扬。',
          subVerses: const [
            SubVerse('窦燕山', 'dòu yān shān'),
            SubVerse('有义方', 'yǒu yì fāng'),
            SubVerse('教五子', 'jiào wǔ zi'),
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
          meaning: '生养孩子却不教育，是父亲的过错；教育学生不严格，是老师的懒惰。',
        ),
        Verse(
          id: 'v0_5',
          text: '子不学，非所宜。幼不学，老何为。',
          subVerses: const [
            SubVerse('子不学', 'zi bù xué'),
            SubVerse('非所宜', 'fēi suǒ yí'),
            SubVerse('幼不学', 'yòu bù xué'),
            SubVerse('老何为', 'lǎo hé wèi'),
          ],
          meaning: '小孩子不肯学习，是不应该的。小时候不学，老了能有什么作为呢？',
        ),
        Verse(
          id: 'v0_6',
          text: '玉不琢，不成器。人不学，不知义。',
          subVerses: const [
            SubVerse('玉不琢', 'yù bù zuó'),
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
            SubVerse('为人子', 'wéi rén zi'),
            SubVerse('方少时', 'fāng shào shí'),
            SubVerse('亲师友', 'qīn shī yǒu'),
            SubVerse('习礼仪', 'xí lǐ yí'),
          ],
          meaning: '做儿女的，在年少的时候，要亲近老师和朋友，学习待人接物的礼节。',
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
          meaning: '首先要孝顺父母、敬爱兄长，其次才是增长见闻。要会数数，要认字读书。',
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
          meaning: '从一到十，十到百，百到千，千到万，数目就是这样推算下去的。',
        ),
      ],
    ),
    Section(
      index: 2,
      title: '三、三才者',
      intro: '讲天地自然常识：三才、三光、四时、四方、五行等。',
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
          meaning: '三纲是君臣间要讲道义，父子间要相亲，夫妻间要和顺。',
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
            SubVerse('应乎中', 'yīng hū zhōng'),
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
        Verse(
          id: 'v2_5',
          text: '曰仁义，礼智信。此五常，不容紊。',
          subVerses: const [
            SubVerse('曰仁义', 'yuē rén yì'),
            SubVerse('礼智信', 'lǐ zhì xìn'),
            SubVerse('此五常', 'cǐ wǔ cháng'),
            SubVerse('不容紊', 'bù róng wěn'),
          ],
          meaning: '仁、义、礼、智、信叫做五常，是永远不能打乱的。',
        ),
        Verse(
          id: 'v2_6',
          text: '稻粱菽，麦黍稷。此六谷，人所食。',
          subVerses: const [
            SubVerse('稻粱菽', 'dào liáng shū'),
            SubVerse('麦黍稷', 'mài shǔ jì'),
            SubVerse('此六谷', 'cǐ liù gǔ'),
            SubVerse('人所食', 'rén suǒ shí'),
          ],
          meaning: '稻、粱、菽、麦、黍、稷叫做六谷，是人们所吃的粮食。',
        ),
        Verse(
          id: 'v2_7',
          text: '马牛羊，鸡犬豕。此六畜，人所饲。',
          subVerses: const [
            SubVerse('马牛羊', 'mǎ niú yáng'),
            SubVerse('鸡犬豕', 'jī quǎn shǐ'),
            SubVerse('此六畜', 'cǐ liù chù'),
            SubVerse('人所饲', 'rén suǒ sì'),
          ],
          meaning: '马、牛、羊、鸡、狗、猪叫做六畜，是人们所饲养的家畜。',
        ),
        Verse(
          id: 'v2_8',
          text: '曰喜怒，曰哀惧。爱恶欲，七情具。',
          subVerses: const [
            SubVerse('曰喜怒', 'yuē xǐ nù'),
            SubVerse('曰哀惧', 'yuē āi jù'),
            SubVerse('爱恶欲', 'ài è yù'),
            SubVerse('七情具', 'qī qíng jù'),
          ],
          meaning: '高兴、生气、忧伤、害怕、爱好、厌恶、贪欲，叫做七情。',
        ),
        Verse(
          id: 'v2_9',
          text: '匏土革，木石金。丝与竹，乃八音。',
          subVerses: const [
            SubVerse('匏土革', 'páo tǔ gé'),
            SubVerse('木石金', 'mù shí jīn'),
            SubVerse('丝与竹', 'sī yǔ zhú'),
            SubVerse('乃八音', 'nǎi bā yīn'),
          ],
          meaning: '匏、土、革、木、石、金、丝、竹，是八种材质的乐器。',
        ),
      ],
    ),
    Section(
      index: 3,
      title: '四、人伦',
      intro: '讲家族世系与人伦关系的准则。',
      verses: [
        Verse(
          id: 'v3_0',
          text: '高曾祖，父而身。身而子，子而孙。',
          subVerses: const [
            SubVerse('高曾祖', 'gāo zēng zǔ'),
            SubVerse('父而身', 'fù ér shēn'),
            SubVerse('身而子', 'shēn ér zi'),
            SubVerse('子而孙', 'zi ér sūn'),
          ],
          meaning: '高祖、曾祖、祖父、父亲，到自己，再到儿子、孙子。',
        ),
        Verse(
          id: 'v3_1',
          text: '自子孙，至玄曾。乃九族，人之伦。',
          subVerses: const [
            SubVerse('自子孙', 'zì zǐ sūn'),
            SubVerse('至玄曾', 'zhì xuán céng'),
            SubVerse('乃九族', 'nǎi jiǔ zú'),
            SubVerse('人之伦', 'rén zhī lún'),
          ],
          meaning: '由子孙往下到玄孙、曾孙，这就是九族，是家族的伦常。',
        ),
        Verse(
          id: 'v3_2',
          text: '父子恩，夫妇从。兄则友，弟则恭。',
          subVerses: const [
            SubVerse('父子恩', 'fù zǐ ēn'),
            SubVerse('夫妇从', 'fū fù cóng'),
            SubVerse('兄则友', 'xiōng zé yǒu'),
            SubVerse('弟则恭', 'dì zé gōng'),
          ],
          meaning: '父子间讲恩情，夫妻间讲和顺，哥哥要友爱，弟弟要恭敬。',
        ),
        Verse(
          id: 'v3_3',
          text: '长幼序，友与朋。君则敬，臣则忠。',
          subVerses: const [
            SubVerse('长幼序', 'zhǎng yòu xù'),
            SubVerse('友与朋', 'yǒu yǔ péng'),
            SubVerse('君则敬', 'jūn zé jìng'),
            SubVerse('臣则忠', 'chén zé zhōng'),
          ],
          meaning: '长幼间有次序，朋友间讲信用，君主要敬重，臣子要忠诚。',
        ),
        Verse(
          id: 'v3_4',
          text: '此十义，人所同。当顺叙，勿违背。',
          subVerses: const [
            SubVerse('此十义', 'cǐ shí yì'),
            SubVerse('人所同', 'rén suǒ tóng'),
            SubVerse('当顺叙', 'dāng shùn xù'),
            SubVerse('勿违背', 'wù wéi bèi'),
          ],
          meaning: '这十种大义是人人都要遵守的，应当顺从，不可违背。',
        ),
        Verse(
          id: 'v3_5',
          text: '斩齐衰，大小功。至缌麻，五服终。',
          subVerses: const [
            SubVerse('斩齐衰', 'zhǎn qí cuī'),
            SubVerse('大小功', 'dà xiǎo gōng'),
            SubVerse('至缌麻', 'zhì sī má'),
            SubVerse('五服终', 'wǔ fú zhōng'),
          ],
          meaning: '斩衰、齐衰、大功、小功、缌麻，是五等丧服的差别。',
        ),
      ],
    ),
    Section(
      index: 4,
      title: '五、训蒙四书五经',
      intro: '讲启蒙次第与儒家经典：四书、六经。',
      verses: [
        Verse(
          id: 'v4_0',
          text: '凡训蒙，须讲究。详训诂，明句读。',
          subVerses: const [
            SubVerse('凡训蒙', 'fán xùn méng'),
            SubVerse('须讲究', 'xū jiǎng jiū'),
            SubVerse('详训诂', 'xiáng xùn gǔ'),
            SubVerse('明句读', 'míng jù dòu'),
          ],
          meaning: '凡是教导小孩子，必须讲究方法，解释字义、弄清断句。',
        ),
        Verse(
          id: 'v4_1',
          text: '为学者，必有初。小学终，至四书。',
          subVerses: const [
            SubVerse('为学者', 'wèi xué zhě'),
            SubVerse('必有初', 'bì yǒu chū'),
            SubVerse('小学终', 'xiǎo xué zhōng'),
            SubVerse('至四书', 'zhì sì shū'),
          ],
          meaning: '求学一定要有开头，先学小学，再读四书。',
        ),
        Verse(
          id: 'v4_2',
          text: '论语者，二十篇。群弟子，记善言。',
          subVerses: const [
            SubVerse('论语者', 'lún yǔ zhě'),
            SubVerse('二十篇', 'èr shí piān'),
            SubVerse('群弟子', 'qún dì zǐ'),
            SubVerse('记善言', 'jì shàn yán'),
          ],
          meaning: '《论语》有二十篇，是孔子的弟子记录他的善言。',
        ),
        Verse(
          id: 'v4_3',
          text: '孟子者，七篇止。讲道德，说仁义。',
          subVerses: const [
            SubVerse('孟子者', 'mèng zi zhě'),
            SubVerse('七篇止', 'qī piān zhǐ'),
            SubVerse('讲道德', 'jiǎng dào dé'),
            SubVerse('说仁义', 'shuō rén yì'),
          ],
          meaning: '《孟子》有七篇，讲的是道德和仁义。',
        ),
        Verse(
          id: 'v4_4',
          text: '作中庸，乃孔伋。中不偏，庸不易。',
          subVerses: const [
            SubVerse('作中庸', 'zuò zhōng yōng'),
            SubVerse('乃孔伋', 'nǎi kǒng jí'),
            SubVerse('中不偏', 'zhōng bù piān'),
            SubVerse('庸不易', 'yōng bù yì'),
          ],
          meaning: '《中庸》是孔伋所作，中是不偏，庸是不变。',
        ),
        Verse(
          id: 'v4_5',
          text: '作大学，乃曾子。自修齐，至平治。',
          subVerses: const [
            SubVerse('作大学', 'zuò dà xué'),
            SubVerse('乃曾子', 'nǎi céng zi'),
            SubVerse('自修齐', 'zì xiū qí'),
            SubVerse('至平治', 'zhì píng zhì'),
          ],
          meaning: '《大学》是曾子所作，从修身齐家到治国平天下。',
        ),
        Verse(
          id: 'v4_6',
          text: '孝经通，四书熟。如六经，始可读。',
          subVerses: const [
            SubVerse('孝经通', 'xiào jīng tōng'),
            SubVerse('四书熟', 'sì shū shú'),
            SubVerse('如六经', 'rú liù jīng'),
            SubVerse('始可读', 'shǐ kě dú'),
          ],
          meaning: '《孝经》通了、四书熟了，才可以读六经。',
        ),
        Verse(
          id: 'v4_7',
          text: '诗书易，礼春秋。号六经，当讲求。',
          subVerses: const [
            SubVerse('诗书易', 'shī shū yì'),
            SubVerse('礼春秋', 'lǐ chūn qiū'),
            SubVerse('号六经', 'hào liù jīng'),
            SubVerse('当讲求', 'dāng jiǎng qiú'),
          ],
          meaning: '《诗》《书》《易》《礼》《春秋》叫做六经，应当研习。',
        ),
        Verse(
          id: 'v4_8',
          text: '有连山，有归藏。有周易，三易详。',
          subVerses: const [
            SubVerse('有连山', 'yǒu lián shān'),
            SubVerse('有归藏', 'yǒu guī cáng'),
            SubVerse('有周易', 'yǒu zhōu yì'),
            SubVerse('三易详', 'sān yì xiáng'),
          ],
          meaning: '《连山》《归藏》《周易》是三种《易》，以《周易》最详备。',
        ),
        Verse(
          id: 'v4_9',
          text: '有典谟，有训诰。有誓命，书之奥。',
          subVerses: const [
            SubVerse('有典谟', 'yǒu diǎn mó'),
            SubVerse('有训诰', 'yǒu xùn gào'),
            SubVerse('有誓命', 'yǒu shì mìng'),
            SubVerse('书之奥', 'shū zhī ào'),
          ],
          meaning: '《尚书》里有典、谟、训、诰、誓、命，含义深奥。',
        ),
        Verse(
          id: 'v4_10',
          text: '我周公，作周礼。著六官，存治体。',
          subVerses: const [
            SubVerse('我周公', 'wǒ zhōu gōng'),
            SubVerse('作周礼', 'zuò zhōu lǐ'),
            SubVerse('著六官', 'zhù liù guān'),
            SubVerse('存治体', 'cún zhì tǐ'),
          ],
          meaning: '周公作了《周礼》，记载六官制度，保存了治理的体统。',
        ),
        Verse(
          id: 'v4_11',
          text: '大小戴，注礼记。述圣言，礼乐备。',
          subVerses: const [
            SubVerse('大小戴', 'dà xiǎo dài'),
            SubVerse('注礼记', 'zhù lǐ jì'),
            SubVerse('述圣言', 'shù shèng yán'),
            SubVerse('礼乐备', 'lǐ yuè bèi'),
          ],
          meaning: '大戴、小戴注解《礼记》，记述圣人之言，礼乐才完备。',
        ),
        Verse(
          id: 'v4_12',
          text: '曰国风，曰雅颂。号四诗，当讽咏。',
          subVerses: const [
            SubVerse('曰国风', 'yuē guó fēng'),
            SubVerse('曰雅颂', 'yuē yǎ sòng'),
            SubVerse('号四诗', 'hào sì shī'),
            SubVerse('当讽咏', 'dāng fěng yǒng'),
          ],
          meaning: '《国风》《雅》《颂》合称四诗，应当吟诵。',
        ),
        Verse(
          id: 'v4_13',
          text: '诗既亡，春秋作。寓褒贬，别善恶。',
          subVerses: const [
            SubVerse('诗既亡', 'shī jì wáng'),
            SubVerse('春秋作', 'chūn qiū zuò'),
            SubVerse('寓褒贬', 'yù bāo biǎn'),
            SubVerse('别善恶', 'bié shàn è'),
          ],
          meaning: '《诗》衰落之后有了《春秋》，它寓含褒贬、分辨善恶。',
        ),
        Verse(
          id: 'v4_14',
          text: '三传者，有公羊。有左氏，有谷梁。',
          subVerses: const [
            SubVerse('三传者', 'sān zhuàn zhě'),
            SubVerse('有公羊', 'yǒu gōng yáng'),
            SubVerse('有左氏', 'yǒu zuǒ shì'),
            SubVerse('有谷梁', 'yǒu gǔ liáng'),
          ],
          meaning: '解说《春秋》的三传是：《公羊传》《左氏传》《谷梁传》。',
        ),
      ],
    ),
    Section(
      index: 5,
      title: '六、诸子与历史',
      intro: '讲诸子百家，以及从上古到明清的朝代更迭。',
      verses: [
        Verse(
          id: 'v5_0',
          text: '经既明，方读子。撮其要，记其事。',
          subVerses: const [
            SubVerse('经既明', 'jīng jì míng'),
            SubVerse('方读子', 'fāng dú zi'),
            SubVerse('撮其要', 'cuō qí yào'),
            SubVerse('记其事', 'jì qí shì'),
          ],
          meaning: '经书读通了，才读诸子，摘取要点，记住本事。',
        ),
        Verse(
          id: 'v5_1',
          text: '五子者，有荀扬。文中子，及老庄。',
          subVerses: const [
            SubVerse('五子者', 'wǔ zi zhě'),
            SubVerse('有荀扬', 'yǒu xún yáng'),
            SubVerse('文中子', 'wén zhōng zi'),
            SubVerse('及老庄', 'jí lǎo zhuāng'),
          ],
          meaning: '五位子书大家：荀子、扬雄、文中子、老子、庄子。',
        ),
        Verse(
          id: 'v5_2',
          text: '经子通，读诸史。考世系，知终始。',
          subVerses: const [
            SubVerse('经子通', 'jīng zi tōng'),
            SubVerse('读诸史', 'dú zhū shǐ'),
            SubVerse('考世系', 'kǎo shì xì'),
            SubVerse('知终始', 'zhī zhōng shǐ'),
          ],
          meaning: '经子都通了，再读史书，考究世系，知道朝代始终。',
        ),
        Verse(
          id: 'v5_3',
          text: '自羲农，至黄帝。号三皇，居上世。',
          subVerses: const [
            SubVerse('自羲农', 'zì xī nóng'),
            SubVerse('至黄帝', 'zhì huáng dì'),
            SubVerse('号三皇', 'hào sān huáng'),
            SubVerse('居上世', 'jū shàng shì'),
          ],
          meaning: '从伏羲、神农到黄帝，号称三皇，居上古之世。',
        ),
        Verse(
          id: 'v5_4',
          text: '唐有虞，号二帝。相揖逊，称盛世。',
          subVerses: const [
            SubVerse('唐有虞', 'táng yǒu yú'),
            SubVerse('号二帝', 'hào èr dì'),
            SubVerse('相揖逊', 'xiāng yī xùn'),
            SubVerse('称盛世', 'chēng shèng shì'),
          ],
          meaning: '唐尧、虞舜号称二帝，互相禅让，是太平盛世。',
        ),
        Verse(
          id: 'v5_5',
          text: '夏有禹，商有汤。周文武，称三王。',
          subVerses: const [
            SubVerse('夏有禹', 'xià yǒu yǔ'),
            SubVerse('商有汤', 'shāng yǒu tāng'),
            SubVerse('周文武', 'zhōu wén wǔ'),
            SubVerse('称三王', 'chēng sān wáng'),
          ],
          meaning: '夏禹、商汤、周文王武王，被称颂为三王。',
        ),
        Verse(
          id: 'v5_6',
          text: '夏传子，家天下。四百载，迁夏社。',
          subVerses: const [
            SubVerse('夏传子', 'xià chuán zi'),
            SubVerse('家天下', 'jiā tiān xià'),
            SubVerse('四百载', 'sì bǎi zài'),
            SubVerse('迁夏社', 'qiān xià shè'),
          ],
          meaning: '夏禹把帝位传给儿子，天下成一家，传四百年而亡。',
        ),
        Verse(
          id: 'v5_7',
          text: '汤伐夏，国号商。六百载，至纣亡。',
          subVerses: const [
            SubVerse('汤伐夏', 'tāng fá xià'),
            SubVerse('国号商', 'guó hào shāng'),
            SubVerse('六百载', 'liù bǎi zài'),
            SubVerse('至纣亡', 'zhì zhòu wáng'),
          ],
          meaning: '汤伐夏建商，传六百年，到纣王时灭亡。',
        ),
        Verse(
          id: 'v5_8',
          text: '周武王，始诛纣。八百载，最长久。',
          subVerses: const [
            SubVerse('周武王', 'zhōu wǔ wáng'),
            SubVerse('始诛纣', 'shǐ zhū zhòu'),
            SubVerse('八百载', 'bā bǎi zài'),
            SubVerse('最长久', 'zuì cháng jiǔ'),
          ],
          meaning: '周武王诛纣建周，传八百年，是最长久的朝代。',
        ),
        Verse(
          id: 'v5_9',
          text: '周辙东，王纲坠。逞干戈，尚游说。',
          subVerses: const [
            SubVerse('周辙东', 'zhōu zhé dōng'),
            SubVerse('王纲坠', 'wáng gāng zhuì'),
            SubVerse('逞干戈', 'chěng gān gē'),
            SubVerse('尚游说', 'shàng yóu shuì'),
          ],
          meaning: '周东迁后王纲崩坏，诸侯动干戈、重游说。',
        ),
        Verse(
          id: 'v5_10',
          text: '始春秋，终战国。五霸强，七雄出。',
          subVerses: const [
            SubVerse('始春秋', 'shǐ chūn qiū'),
            SubVerse('终战国', 'zhōng zhàn guó'),
            SubVerse('五霸强', 'wǔ bà qiáng'),
            SubVerse('七雄出', 'qī xióng chū'),
          ],
          meaning: '东周分春秋与战国，春秋有五霸强盛，战国有七雄。',
        ),
        Verse(
          id: 'v5_11',
          text: '嬴秦氏，始兼并。传二世，楚汉争。',
          subVerses: const [
            SubVerse('嬴秦氏', 'yíng qín shì'),
            SubVerse('始兼并', 'shǐ jiān bìng'),
            SubVerse('传二世', 'chuán èr shì'),
            SubVerse('楚汉争', 'chǔ hàn zhēng'),
          ],
          meaning: '秦王嬴政开始兼并六国，传二世而亡，楚汉相争。',
        ),
        Verse(
          id: 'v5_12',
          text: '高祖兴，汉业建。至孝平，王莽篡。',
          subVerses: const [
            SubVerse('高祖兴', 'gāo zǔ xīng'),
            SubVerse('汉业建', 'hàn yè jiàn'),
            SubVerse('至孝平', 'zhì xiào píng'),
            SubVerse('王莽篡', 'wáng mǎng cuàn'),
          ],
          meaning: '汉高祖建汉，到平帝时王莽篡位。',
        ),
        Verse(
          id: 'v5_13',
          text: '光武兴，为东汉。四百年，终于献。',
          subVerses: const [
            SubVerse('光武兴', 'guāng wǔ xīng'),
            SubVerse('为东汉', 'wèi dōng hàn'),
            SubVerse('四百年', 'sì bǎi nián'),
            SubVerse('终于献', 'zhōng yú xiàn'),
          ],
          meaning: '光武帝中兴为东汉，四百年到献帝而终。',
        ),
        Verse(
          id: 'v5_14',
          text: '蜀魏吴，争汉鼎。号三国，迄两晋。',
          subVerses: const [
            SubVerse('蜀魏吴', 'shǔ wèi wú'),
            SubVerse('争汉鼎', 'zhēng hàn dǐng'),
            SubVerse('号三国', 'hào sān guó'),
            SubVerse('迄两晋', 'qì liǎng jìn'),
          ],
          meaning: '蜀、魏、吴争天下，叫三国，直到两晋。',
        ),
        Verse(
          id: 'v5_15',
          text: '宋齐继，梁陈承。为南朝，都金陵。',
          subVerses: const [
            SubVerse('宋齐继', 'sòng qí jì'),
            SubVerse('梁陈承', 'liáng chén chéng'),
            SubVerse('为南朝', 'wèi nán cháo'),
            SubVerse('都金陵', 'dōu jīn líng'),
          ],
          meaning: '宋、齐、梁、陈相继，是南朝，都城建康。',
        ),
        Verse(
          id: 'v5_16',
          text: '北元魏，分东西。宇文周，与高齐。',
          subVerses: const [
            SubVerse('北元魏', 'běi yuán wèi'),
            SubVerse('分东西', 'fēn dōng xī'),
            SubVerse('宇文周', 'yǔ wén zhōu'),
            SubVerse('与高齐', 'yǔ gāo qí'),
          ],
          meaning: '北朝先有元魏，后分东西，是宇文周与高齐。',
        ),
        Verse(
          id: 'v5_17',
          text: '迨至隋，一土宇。不再传，失统绪。',
          subVerses: const [
            SubVerse('迨至隋', 'dài zhì suí'),
            SubVerse('一土宇', 'yī tǔ yǔ'),
            SubVerse('不再传', 'bù zài chuán'),
            SubVerse('失统绪', 'shī tǒng xù'),
          ],
          meaning: '到隋朝统一天下，但传到二代就失去统绪。',
        ),
        Verse(
          id: 'v5_18',
          text: '唐高祖，起义师。除隋乱，创国基。',
          subVerses: const [
            SubVerse('唐高祖', 'táng gāo zǔ'),
            SubVerse('起义师', 'qǐ yì shī'),
            SubVerse('除隋乱', 'chú suí luàn'),
            SubVerse('创国基', 'chuàng guó jī'),
          ],
          meaning: '唐高祖起兵，平隋乱，开创唐朝基业。',
        ),
        Verse(
          id: 'v5_19',
          text: '二十传，三百载。梁灭之，国乃改。',
          subVerses: const [
            SubVerse('二十传', 'èr shí chuán'),
            SubVerse('三百载', 'sān bǎi zài'),
            SubVerse('梁灭之', 'liáng miè zhī'),
            SubVerse('国乃改', 'guó nǎi gǎi'),
          ],
          meaning: '唐传二十代、三百年，被后梁所灭。',
        ),
        Verse(
          id: 'v5_20',
          text: '梁唐晋，及汉周。称五代，皆有由。',
          subVerses: const [
            SubVerse('梁唐晋', 'liáng táng jìn'),
            SubVerse('及汉周', 'jí hàn zhōu'),
            SubVerse('称五代', 'chēng wǔ dài'),
            SubVerse('皆有由', 'jiē yǒu yóu'),
          ],
          meaning: '后梁、后唐、后晋、后汉、后周，叫五代，各有原由。',
        ),
        Verse(
          id: 'v5_21',
          text: '炎宋兴，受周禅。十八传，南北混。',
          subVerses: const [
            SubVerse('炎宋兴', 'yán sòng xīng'),
            SubVerse('受周禅', 'shòu zhōu shàn'),
            SubVerse('十八传', 'shí bā chuán'),
            SubVerse('南北混', 'nán běi hùn'),
          ],
          meaning: '宋受后周禅让而兴，传十八代，南北混一。',
        ),
        Verse(
          id: 'v5_22',
          text: '辽与金，帝号纷。迨灭辽，宋犹存。',
          subVerses: const [
            SubVerse('辽与金', 'liáo yǔ jīn'),
            SubVerse('帝号纷', 'dì hào fēn'),
            SubVerse('迨灭辽', 'dài miè liáo'),
            SubVerse('宋犹存', 'sòng yóu cún'),
          ],
          meaning: '辽、金相继称帝，金灭辽时宋还存在。',
        ),
        Verse(
          id: 'v5_23',
          text: '至元兴，金绪歇。有宋世，一同灭。',
          subVerses: const [
            SubVerse('至元兴', 'zhì yuán xīng'),
            SubVerse('金绪歇', 'jīn xù xiē'),
            SubVerse('有宋世', 'yǒu sòng shì'),
            SubVerse('一同灭', 'yī tóng miè'),
          ],
          meaning: '到元朝兴起，金灭亡，宋朝也一并被灭。',
        ),
        Verse(
          id: 'v5_24',
          text: '并中国，兼戎翟。九十年，国祚废。',
          subVerses: const [
            SubVerse('并中国', 'bìng zhōng guó'),
            SubVerse('兼戎翟', 'jiān róng dí'),
            SubVerse('九十年', 'jiǔ shí nián'),
            SubVerse('国祚废', 'guó zuò fèi'),
          ],
          meaning: '元并中国、统戎狄，传九十年而亡。',
        ),
        Verse(
          id: 'v5_25',
          text: '明太祖，久亲师。传建文，方四祀。',
          subVerses: const [
            SubVerse('明太祖', 'míng tài zǔ'),
            SubVerse('久亲师', 'jiǔ qīn shī'),
            SubVerse('传建文', 'chuán jiàn wén'),
            SubVerse('方四祀', 'fāng sì sì'),
          ],
          meaning: '明太祖长年亲自统军，传位建文，仅四年。',
        ),
        Verse(
          id: 'v5_26',
          text: '迁北京，永乐嗣。迨崇祯，煤山逝。',
          subVerses: const [
            SubVerse('迁北京', 'qiān běi jīng'),
            SubVerse('永乐嗣', 'yǒng lè sì'),
            SubVerse('迨崇祯', 'dài chóng zhēn'),
            SubVerse('煤山逝', 'méi shān shì'),
          ],
          meaning: '永乐迁都北京，到崇祯帝在煤山自尽。',
        ),
        Verse(
          id: 'v5_27',
          text: '清太祖，膺景命。靖四方，克大定。',
          subVerses: const [
            SubVerse('清太祖', 'qīng tài zǔ'),
            SubVerse('膺景命', 'yīng jǐng mìng'),
            SubVerse('靖四方', 'jìng sì fāng'),
            SubVerse('克大定', 'kè dà dìng'),
          ],
          meaning: '清太祖受天命，平定四方，成就大定。',
        ),
        Verse(
          id: 'v5_28',
          text: '廿一史，全在兹。载治乱，知兴衰。',
          subVerses: const [
            SubVerse('廿一史', 'niàn yī shǐ'),
            SubVerse('全在兹', 'quán zài zī'),
            SubVerse('载治乱', 'zài zhì luàn'),
            SubVerse('知兴衰', 'zhī xīng shuāi'),
          ],
          meaning: '二十一史都在此，记载治乱，让人知兴衰。',
        ),
      ],
    ),
    Section(
      index: 6,
      title: '七、勤学',
      intro: '讲勤学故事，劝人自幼努力，是全文的结尾。',
      verses: [
        Verse(
          id: 'v6_0',
          text: '口而诵，心而惟。朝于斯，夕于斯。',
          subVerses: const [
            SubVerse('口而诵', 'kǒu ér sòng'),
            SubVerse('心而惟', 'xīn ér wéi'),
            SubVerse('朝于斯', 'zhāo yú sī'),
            SubVerse('夕于斯', 'xī yú sī'),
          ],
          meaning: '口里诵读，心里思考，从早到晚都不懈怠。',
        ),
        Verse(
          id: 'v6_1',
          text: '昔仲尼，师项橐。古圣贤，尚勤学。',
          subVerses: const [
            SubVerse('昔仲尼', 'xī zhòng ní'),
            SubVerse('师项橐', 'shī xiàng tuó'),
            SubVerse('古圣贤', 'gǔ shèng xián'),
            SubVerse('尚勤学', 'shàng qín xué'),
          ],
          meaning: '孔子曾拜项橐为师，古圣先贤尚且勤学。',
        ),
        Verse(
          id: 'v6_2',
          text: '赵中令，读鲁论。彼既仕，学且勤。',
          subVerses: const [
            SubVerse('赵中令', 'zhào zhōng lìng'),
            SubVerse('读鲁论', 'dú lǔ lún'),
            SubVerse('彼既仕', 'bǐ jì shì'),
            SubVerse('学且勤', 'xué qiě qín'),
          ],
          meaning: '赵普身居相位仍读《论语》，做了官还勤学。',
        ),
        Verse(
          id: 'v6_3',
          text: '披蒲编，削竹简。彼无书，且知勉。',
          subVerses: const [
            SubVerse('披蒲编', 'pī pú biān'),
            SubVerse('削竹简', 'xuē zhú jiǎn'),
            SubVerse('彼无书', 'bǐ wú shū'),
            SubVerse('且知勉', 'qiě zhī miǎn'),
          ],
          meaning: '路温舒用蒲草抄书、公孙弘削竹简，无书也自勉。',
        ),
        Verse(
          id: 'v6_4',
          text: '头悬梁，锥刺股。彼不教，自勤苦。',
          subVerses: const [
            SubVerse('头悬梁', 'tóu xuán liáng'),
            SubVerse('锥刺股', 'zhuī cì gǔ'),
            SubVerse('彼不教', 'bǐ bù jiào'),
            SubVerse('自勤苦', 'zì qín kǔ'),
          ],
          meaning: '孙敬悬梁、苏秦刺股，无人督促也自苦勤学。',
        ),
        Verse(
          id: 'v6_5',
          text: '如囊萤，如映雪。家虽贫，学不辍。',
          subVerses: const [
            SubVerse('如囊萤', 'rú náng yíng'),
            SubVerse('如映雪', 'rú yìng xuě'),
            SubVerse('家虽贫', 'jiā suī pín'),
            SubVerse('学不辍', 'xué bù chuò'),
          ],
          meaning: '车胤囊萤、孙康映雪，家虽贫也不停止学习。',
        ),
        Verse(
          id: 'v6_6',
          text: '如负薪，如挂角。身虽劳，犹苦卓。',
          subVerses: const [
            SubVerse('如负薪', 'rú fù xīn'),
            SubVerse('如挂角', 'guà jiǎo'),
            SubVerse('身虽劳', 'shēn suī láo'),
            SubVerse('犹苦卓', 'yóu kǔ zhuó'),
          ],
          meaning: '朱买臣负薪、李密挂角，身虽劳仍苦学卓绝。',
        ),
        Verse(
          id: 'v6_7',
          text: '苏老泉，二十七。始发愤，读书籍。',
          subVerses: const [
            SubVerse('苏老泉', 'sū lǎo quán'),
            SubVerse('二十七', 'èr shí qī'),
            SubVerse('始发愤', 'shǐ fā fèn'),
            SubVerse('读书籍', 'dú shū jí'),
          ],
          meaning: '苏洵二十七岁才发愤读书。',
        ),
        Verse(
          id: 'v6_8',
          text: '彼既老，犹悔迟。尔小生，宜早思。',
          subVerses: const [
            SubVerse('彼既老', 'bǐ jì lǎo'),
            SubVerse('犹悔迟', 'yóu huǐ chí'),
            SubVerse('尔小生', 'ěr xiǎo shēng'),
            SubVerse('宜早思', 'yí zǎo sī'),
          ],
          meaning: '他年老还悔恨太迟，你们少年应当早打算。',
        ),
        Verse(
          id: 'v6_9',
          text: '若梁灏，八十二。对大廷，魁多士。',
          subVerses: const [
            SubVerse('若梁灏', 'ruò liáng hào'),
            SubVerse('八十二', 'bā shí èr'),
            SubVerse('对大廷', 'duì dà tíng'),
            SubVerse('魁多士', 'kuí duō shì'),
          ],
          meaning: '梁灏八十二岁在殿试中状元，胜过众士。',
        ),
        Verse(
          id: 'v6_10',
          text: '彼既成，众称异。尔小生，宜立志。',
          subVerses: const [
            SubVerse('彼既成', 'bǐ jì chéng'),
            SubVerse('众称异', 'zhòng chēng yì'),
            SubVerse('尔小生', 'ěr xiǎo shēng'),
            SubVerse('宜立志', 'yí lì zhì'),
          ],
          meaning: '他成功后众称奇异，你们少年应当立志。',
        ),
        Verse(
          id: 'v6_11',
          text: '莹八岁，能咏诗。泌七岁，能赋棋。',
          subVerses: const [
            SubVerse('莹八岁', 'yíng bā suì'),
            SubVerse('能咏诗', 'néng yǒng shī'),
            SubVerse('泌七岁', 'mì qī suì'),
            SubVerse('能赋棋', 'néng fù qí'),
          ],
          meaning: '祖莹八岁能吟诗，李泌七岁能赋棋。',
        ),
        Verse(
          id: 'v6_12',
          text: '彼颖悟，人称奇。尔幼学，当效之。',
          subVerses: const [
            SubVerse('彼颖悟', 'bǐ yǐng wù'),
            SubVerse('人称奇', 'rén chēng qí'),
            SubVerse('尔幼学', 'ěr yòu xué'),
            SubVerse('当效之', 'dāng xiào zhī'),
          ],
          meaning: '他们聪颖被人称奇，你们幼年应当效法。',
        ),
        Verse(
          id: 'v6_13',
          text: '蔡文姬，能辨琴。谢道韫，能咏吟。',
          subVerses: const [
            SubVerse('蔡文姬', 'cài wén jī'),
            SubVerse('能辨琴', 'néng biàn qín'),
            SubVerse('谢道韫', 'xiè dào yùn'),
            SubVerse('能咏吟', 'néng yǒng yín'),
          ],
          meaning: '蔡文姬能辨琴音，谢道韫能吟诗。',
        ),
        Verse(
          id: 'v6_14',
          text: '彼女子，且聪敏。尔男子，当自警。',
          subVerses: const [
            SubVerse('彼女子', 'bǐ nǚ zǐ'),
            SubVerse('且聪敏', 'qiě cōng mǐn'),
            SubVerse('尔男子', 'ěr nán zi'),
            SubVerse('当自警', 'dāng zì jǐng'),
          ],
          meaning: '她们身为女子尚且聪敏，你们男子更当自勉。',
        ),
        Verse(
          id: 'v6_15',
          text: '唐刘晏，方七岁。举神童，作正字。',
          subVerses: const [
            SubVerse('唐刘晏', 'táng liú yàn'),
            SubVerse('方七岁', 'fāng qī suì'),
            SubVerse('举神童', 'jǔ shén tóng'),
            SubVerse('作正字', 'zuò zhèng zì'),
          ],
          meaning: '唐代刘晏七岁被举为神童，做了正字官。',
        ),
        Verse(
          id: 'v6_16',
          text: '彼虽幼，身已仕。尔幼学，勉而致。',
          subVerses: const [
            SubVerse('彼虽幼', 'bǐ suī yòu'),
            SubVerse('身已仕', 'shēn yǐ shì'),
            SubVerse('尔幼学', 'ěr yòu xué'),
            SubVerse('勉而致', 'miǎn ér zhì'),
          ],
          meaning: '他虽年幼已做官，你们幼年勤学也能达到。',
        ),
        Verse(
          id: 'v6_17',
          text: '有为者，亦若是。',
          subVerses: const [
            SubVerse('有为者', 'yǒu wéi zhě'),
            SubVerse('亦若是', 'yì ruò shì'),
          ],
          meaning: '凡有作为的人，也都是这样走过来的。',
        ),
        Verse(
          id: 'v6_18',
          text: '犬守夜，鸡司晨。苟不学，曷为人。',
          subVerses: const [
            SubVerse('犬守夜', 'quǎn shǒu yè'),
            SubVerse('鸡司晨', 'jī sī chén'),
            SubVerse('苟不学', 'gǒu bù xué'),
            SubVerse('曷为人', 'hé wéi rén'),
          ],
          meaning: '狗守夜、鸡报晓，人若不学，怎么配做人。',
        ),
        Verse(
          id: 'v6_19',
          text: '蚕吐丝，蜂酿蜜。人不学，不如物。',
          subVerses: const [
            SubVerse('蚕吐丝', 'cán tǔ sī'),
            SubVerse('蜂酿蜜', 'fēng niàng mì'),
            SubVerse('人不学', 'rén bù xué'),
            SubVerse('不如物', 'bù rú wù'),
          ],
          meaning: '蚕会吐丝、蜂会酿蜜，人若不学不如物。',
        ),
        Verse(
          id: 'v6_20',
          text: '幼而学，壮而行。上致君，下泽民。',
          subVerses: const [
            SubVerse('幼而学', 'yòu ér xué'),
            SubVerse('壮而行', 'zhuàng ér xíng'),
            SubVerse('上致君', 'shàng zhì jūn'),
            SubVerse('下泽民', 'xià zé mín'),
          ],
          meaning: '幼时学习、长大施行，对上辅君、对下利民。',
        ),
        Verse(
          id: 'v6_21',
          text: '扬名声，显父母。光于前，裕于后。',
          subVerses: const [
            SubVerse('扬名声', 'yáng míng shēng'),
            SubVerse('显父母', 'xiǎn fù mǔ'),
            SubVerse('光于前', 'guāng yú qián'),
            SubVerse('裕于后', 'yù yú hòu'),
          ],
          meaning: '扬名显亲，光耀祖先、造福后代。',
        ),
        Verse(
          id: 'v6_22',
          text: '勤有功，戏无益。戒之哉，宜勉力。',
          subVerses: const [
            SubVerse('勤有功', 'qín yǒu gōng'),
            SubVerse('戏无益', 'xì wú yì'),
            SubVerse('戒之哉', 'jiè zhī zāi'),
            SubVerse('宜勉力', 'yí miǎn lì'),
          ],
          meaning: '勤奋必有成就，嬉戏没有好处，要以此为戒、努力上进。',
        ),
      ],
    ),
  ];

  static List<Verse> get allVerses =>
      sections.expand((s) => s.verses).toList();

  static Verse verseById(String id) =>
      allVerses.firstWhere((v) => v.id == id, orElse: () => allVerses.first);
}
