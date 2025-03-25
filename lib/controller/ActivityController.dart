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
// ✅ دالة لإضافة الملصق إلى بيانات الطفل داخل Firestore
  Future<void> addStickerToChild(String parentId, String childId, String stickerId) async {
    try {
      print("🔹 جلب بيانات الملصق برقم: $stickerId");

      // 🔹 جلب بيانات الملصق من `stickers` باستخدام `stickerId`
      DocumentSnapshot stickerDoc = await _firestore.collection("stickers").doc(stickerId).get();

      if (!stickerDoc.exists) {
        print("❌ الملصق غير موجود في Firestore!");
        return;
      }

      // 🔹 استخراج بيانات الملصق
      Map<String, dynamic>? stickerData = stickerDoc.data() as Map<String, dynamic>?;

      if (stickerData == null || !stickerData.containsKey("link")) {
        print("❌ لا يوجد رابط للملصق!");
        return;
      }

      // 🔹 الوصول إلى المستند الخاص بالطفل داخل Firestore
      DocumentReference childRef = _firestore
          .collection("Parent")
          .doc(parentId)
          .collection("Children")
          .doc(childId);

      // 🔹 إضافة الملصق إلى `stickers` في وثيقة الطفل
      await childRef.update({
        "stickers": FieldValue.arrayUnion([
          {
            "id": stickerId,
            "link": stickerData["link"],
          }
        ])
      });

      print("🎉 تمت إضافة الملصق للطفل بنجاح!");
    } catch (e) {
      print("❌ خطأ أثناء إضافة الملصق: $e");
    }
  }
  
  // ✅ دالة لتحديث حالة الـ progress للطفل في Firestore
  Future<void> updateProgress(String parentId, String childId, String type) async {
    try {
      // تحديد الحقل الذي سيتم تحديثه بناءً على نوع النشاط
      String progressField = '';
      if (type == "letter") {
        progressField = 'letters';
      } else if (type == "number") {
        progressField = 'numbers';
      } else if (type == "word") {
        progressField = 'words';
      } else {
        print("⚠️ نوع غير معروف: $type");
        return;
      }

      // جلب مرجع الطفل داخل Firestore
      DocumentReference childRef = _firestore
          .collection("Parent")
          .doc(parentId)
          .collection("Children")
          .doc(childId);

      // تحديث حالة الـ progress بزيادة العدد الحالي في الحقل المناسب
      await childRef.update({
        "progress.$progressField": FieldValue.increment(1), // زيادة العدد في الحقل المناسب
      });

      print("🎉 تم تحديث حالة التقدم بنجاح!");
    } catch (e) {
      print("❌ خطأ أثناء تحديث حالة التقدم: $e");
    }
  }
}

