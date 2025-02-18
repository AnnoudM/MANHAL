import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:manhal/model/ActivityModel.dart';

class ActivityController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // جلب البيانات من Firestore بناءً على الحرف
  Future<ActivityModel?> fetchActivity(String letter) async {
  
  try {
    DocumentSnapshot doc = await _firestore
        .collection('Activity')
        .doc('letters')
        .collection('content')
        .doc(letter)
        .get();

    if (doc.exists) {
      print("✅ تم العثور على البيانات في Firestore: ${doc.data()}");
      return ActivityModel.fromFirestore(doc.data() as Map<String, dynamic>);
    } else {
      print("⚠️ لا يوجد نشاط لهذا الحرف في Firestore");
      return null;
    }
  } catch (e) {
    print("❌ خطأ أثناء جلب النشاط: $e");
    return null;
  }
}
}