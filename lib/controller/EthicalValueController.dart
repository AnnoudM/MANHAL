import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/EthicalValueModel.dart';

class EthicalValueController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // جلب مستوى الطفل من Firestore
  Stream<int?> fetchChildLevel(String parentId, String childId) {
    return _firestore
        .collection('Parent')
        .doc(parentId)
        .collection('Children')
        .doc(childId)
        .snapshots()
        .map((snapshot) => snapshot.data()?['level']);
  }

  // تحديث مستوى الطفل بعد إكمال الفيديو
  Future<void> updateChildLevel(String parentId, String childId, int newLevel) async {
    try {
      await _firestore
          .collection('Parent')
          .doc(parentId)
          .collection('Children')
          .doc(childId)
          .update({'level': newLevel});
    } catch (e) {
      print("❌ خطأ في تحديث مستوى الطفل: $e");
    }
  }
}