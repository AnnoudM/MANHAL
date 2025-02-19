class WordModel {
  final String word;
  final String imageUrl;

  WordModel({required this.word, required this.imageUrl});

  factory WordModel.fromMap(Map<String, dynamic> map) {
    return WordModel(
      word: map['word'] ?? '',
      imageUrl: map['image'] ?? '',
    );
  }
}
