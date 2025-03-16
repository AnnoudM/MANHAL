import 'package:cloud_firestore/cloud_firestore.dart';

class EthicalValueModel {
  final String name;
  final int level;
  final String videoUrl;
  final bool isLockedByParent; // raghad:new code

  EthicalValueModel({
    required this.name,
    required this.level,
    required this.videoUrl,
    required this.isLockedByParent, // raghad:new code
  });

  // 🔹 إنشاء كائن من Firestore
  factory EthicalValueModel.fromFirestore(
      DocumentSnapshot doc, List<String> lockedItems) {
    final data = doc.data() as Map<String, dynamic>;
    String ethicalId = doc.id; // معرف القيم الأخلاقية
    bool locked = lockedItems
        .contains(ethicalId); // raghad:new code 
    return EthicalValueModel(
      name: data['name'] ?? '',
      level: data['level'] ?? 1,
      videoUrl: data['video'] ?? '',
      isLockedByParent: locked, // raghad:new code 
    );
  }
}
