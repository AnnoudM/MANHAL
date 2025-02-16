import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/EthicalValueModel.dart';

class EthicalValueController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ استرجاع القيم الأخلاقية بناءً على مستوى الطفل
  Stream<List<EthicalValueModel>> fetchEthicalValues(int childLevel) {
    return _firestore
        .collection('EthicalValue')
        .where('level', isLessThanOrEqualTo: childLevel) // 🔹 فقط القيم المناسبة
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return EthicalValueModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // ✅ تحديث مستوى الطفل عند الانتهاء من الفيديو
  Future<void> updateChildLevel(String parentId, String childId, int newLevel) async {
    try {
      await _firestore
          .collection('Parent')
          .doc(parentId)
          .collection('Children')
          .doc(childId)
          .update({'level': newLevel});

      print("✅ تم تحديث مستوى الطفل إلى $newLevel");
    } catch (e) {
      print("❌ خطأ في تحديث مستوى الطفل: $e");
    }
  }

  // ✅ جلب مستوى الطفل من Firestore
  Stream<int?> fetchChildLevel(String parentId, String childId) {
    return _firestore
        .collection('Parent')
        .doc(parentId)
        .collection('Children')
        .doc(childId)
        .snapshots()
        .map((snapshot) => snapshot.data()?['level']);
  }
}