import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/EthicalValueModel.dart';

class EthicalValueController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 استرجاع جميع القيم الأخلاقية من Firestore
  Stream<List<EthicalValueModel>> fetchAllEthicalValues() {
    return _firestore.collection('EthicalValue').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return EthicalValueModel.fromFirestore(doc);
      }).toList();
    });
  }

  // 🔹 جلب مستوى الطفل من Firestore
  Stream<int?> fetchChildLevel(String parentId, String childId) {
    return _firestore
        .collection('Parent')
        .doc(parentId)
        .collection('Children')
        .doc(childId)
        .snapshots()
        .map((snapshot) => snapshot.data()?['level']);
  }

  // 🔹 تحديث مستوى الطفل بعد إكمال الفيديو
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
}