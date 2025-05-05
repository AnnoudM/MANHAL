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

  // create model instance from Firestore document
  factory EthicalValueModel.fromFirestore(
      DocumentSnapshot doc, List<String> lockedItems) {
    final data = doc.data() as Map<String, dynamic>;
    String ethicalId = doc.id;

    return EthicalValueModel(
      name: data['name'] ?? '',
      level: data['level'] ?? 1,
      videoUrl: data['video'] ?? '',
    );
  }
}
