class WordModel {
  final String name;
  final String imageUrl;
  final String soundUrl;

  WordModel({
    required this.name,
    required this.imageUrl,
    required this.soundUrl,
  });

  factory WordModel.fromMap(Map<String, dynamic> map) {
    return WordModel(
      name: map['name'] ?? '',
      imageUrl: map['image'] ?? '',
      soundUrl: map['soundUrl'] ?? '',
    );
  }
}
