class WordModel {
  final String name;
  final String imageUrl;
  final String soundUrl;
  final bool isLocked; // ✅ NEW: Add isLocked flag

  WordModel({
    required this.name,
    required this.imageUrl,
    required this.soundUrl,
    this.isLocked = false, // ✅ Default is unlocked
  });

  factory WordModel.fromMap(Map<String, dynamic> map) {
    return WordModel(
      name: map['name'] ?? '',
      imageUrl: map['image'] ?? '',
      soundUrl: map['soundUrl'] ?? '',
    );
  }

  // ✅ New: CopyWith method to update isLocked
  WordModel copyWith({bool? isLocked}) {
    return WordModel(
      name: name,
      imageUrl: imageUrl,
      soundUrl: soundUrl,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}
