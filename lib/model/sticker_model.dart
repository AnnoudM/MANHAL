class Sticker {
  final String id;
  final String imageUrl;

  Sticker({required this.id, required this.imageUrl});

  // Convert from Firestore document
  factory Sticker.fromMap(Map<String, dynamic> data) {
    return Sticker(
      id: data['id'] ?? '',
      imageUrl: data['image'] ?? '',
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image': imageUrl,
    };
  }
}
