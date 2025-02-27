import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:manhal/model/ActivityModel.dart';

class ActivityController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch activity data from Firestore based on type and value
  Future<ActivityModel?> fetchActivity(String value, String type) async {
    try {
     
      // تحديد اسم المجموعة الفرعية بناءً على النوع
      String subcollection;
      if (type == "letter") {
        subcollection = "letters";
      } else if (type == "number") {
        subcollection = "Numbers"; // لاحظ الحرف الكبير 'N'
      } else if (type == "word") {
        subcollection = "word";
      } else {
        print("⚠️ نوع غير معروف: $type");
        return null;
      }

      // جلب المستند من المجموعة الفرعية المحددة
      DocumentSnapshot doc = await _firestore
          .collection('Activity')
          .doc(subcollection)
          .collection('content')
          .doc(value)
          .get();

      if (doc.exists) {
        print("✅ تم العثور على البيانات في Firestore: ${doc.data()}");
        return ActivityModel.fromFirestore(doc.data() as Map<String, dynamic>);
      } else {
        print("⚠️ لم يتم العثور على نشاط لهذه القيمة في Firestore");
        return null;
      }
    } catch (e) {
      print("❌ خطأ أثناء جلب النشاط: $e");
      return null;
    }
  }
}