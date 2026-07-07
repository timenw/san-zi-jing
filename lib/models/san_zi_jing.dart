/// 三字经全文（按段落/分句切分，便于逐句朗读与跟读）。
class Verse {
  final String text;
  Verse(this.text);
}

class Section {
  final String title;
  final List<Verse> verses;
  Section(this.title, this.verses);
}

class SanZiJingData {
  static const List<Section> sections = [
    Section('一、人之初', [
      Verse('人之初，性本善。性相近，习相远。'),
      Verse('苟不教，性乃迁。教之道，贵以专。'),
      Verse('昔孟母，择邻处。子不学，断机杼。'),
      Verse('窦燕山，有义方。教五子，名俱扬。'),
      Verse('养不教，父之过。教不严，师之惰。'),
      Verse('子不学，非所宜。幼不学，老何为。'),
      Verse('玉不琢，不成器。人不学，不知义。'),
    ]),
    Section('二、首孝悌', [
      Verse('为人子，方少时。亲师友，习礼仪。'),
      Verse('香九龄，能温席。孝于亲，所当执。'),
      Verse('融四岁，能让梨。弟于长，宜先知。'),
      Verse('首孝悌，次见闻。知某数，识某文。'),
      Verse('一而十，十而百。百而千，千而万。'),
    ]),
    Section('三、三才者', [
      Verse('三才者，天地人。三光者，日月星。'),
      Verse('三纲者，君臣义。父子亲，夫妇顺。'),
      Verse('曰春夏，曰秋冬。此四时，运不穷。'),
      Verse('曰南北，曰西东。此四方，应乎中。'),
      Verse('曰水火，木金土。此五行，本乎数。'),
    ]),
    Section('四、勤有功', [
      Verse('犬守夜，鸡司晨。苟不学，曷为人。'),
      Verse('蚕吐丝，蜂酿蜜。人不学，不如物。'),
      Verse('幼而学，壮而行。上致君，下泽民。'),
      Verse('扬名声，显父母。光于前，裕于后。'),
      Verse('勤有功，戏无益。戒之哉，宜勉力。'),
    ]),
  ];

  static List<Verse> get allVerses =>
      sections.expand((s) => s.verses).toList();
}
