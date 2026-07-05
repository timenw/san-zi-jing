class Phrase {
  final int id;
  final String characters;
  final String pinyin;
  final String translation;
  final String section;

  const Phrase({
    required this.id,
    required this.characters,
    required this.pinyin,
    required this.translation,
    required this.section,
  });

  /// AI audio asset path
  String get aiAudioPath => 'assets/audio/ai/${id.toString().padLeft(3, '0')}.mp3';

  /// Parent recording file name
  String get parentAudioName => 'parent_${id.toString().padLeft(3, '0')}.m4a';

  /// Child recording file name
  String get childAudioName => 'child_${id.toString().padLeft(3, '0')}.m4a';
}
