class Sticker {
  final String id;
  final String link; 

  Sticker({required this.id, required this.link});

  // Factory constructor to create a Sticker object from Firestore data
  factory Sticker.fromMap(Map<String, dynamic> data) {
    return Sticker(
      id: data['id'] ?? '',
      link: data['link'] ?? '', 
    );
  }

  // Convert the Sticker object to a map to store in Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'link': link, 
    };
  }
}
