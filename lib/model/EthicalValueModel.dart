class EthicalValueModel {
  final String ethicalId;
  final String name;
  final String description;
  final String videoUrl;
  final int level;

  EthicalValueModel({
    required this.ethicalId,
    required this.name,
    required this.description,
    required this.videoUrl,
    required this.level,
  });

  // ✅ استرجاع البيانات من Firestore بشكل صحيح
  factory EthicalValueModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return EthicalValueModel(
      ethicalId: docId, // 🔹 نستخدم ID المستند كـ ethicalId
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      videoUrl: data['video'] ?? '',
      level: data['level'] ?? 1,
    );
  }
}