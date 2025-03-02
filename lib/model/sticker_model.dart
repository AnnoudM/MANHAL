class Sticker {
  final String id;
  final String link; 

  Sticker({required this.id, required this.link});

  // تحويل من Firestore
  factory Sticker.fromMap(Map<String, dynamic> data) {
    return Sticker(
      id: data['id'] ?? '',
      link: data['link'] ?? '', 
    );
  }

  // تحويل إلى Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'link': link, 
    };
  }
}
