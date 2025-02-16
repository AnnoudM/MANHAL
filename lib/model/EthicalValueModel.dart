import 'package:cloud_firestore/cloud_firestore.dart';

class EthicalValueModel {
  final String name;
  final int level;
  final String videoUrl;

  EthicalValueModel({
    required this.name,
    required this.level,
    required this.videoUrl,
  });

  // 🔹 إنشاء كائن من Firestore
  factory EthicalValueModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EthicalValueModel(
      name: data['name'] ?? '',
      level: data['level'] ?? 1,
      videoUrl: data['video'] ?? '',
    );
  }
}