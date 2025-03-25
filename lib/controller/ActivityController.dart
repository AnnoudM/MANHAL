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
  
  // ✅ دالة للتحقق إذا كانت الإجابة موجودة في المصفوفة الخاصة بالنشاط
  Future<bool> hasAnsweredCorrectly(String parentId, String childId, String type, String answer) async {
    try {
      // تحديد الحقل بناءً على نوع النشاط
      String progressField = '';
      if (type == "letter") {
        progressField = 'letters';
      } else if (type == "number") {
        progressField = 'numbers';
      } else if (type == "word") {
        progressField = 'words';
      } else {
        print("⚠️ نوع غير معروف: $type");
        return false;
      }

      // جلب مرجع وثيقة الطفل
      DocumentReference childRef = _firestore
          .collection("Parent")
          .doc(parentId)
          .collection("Children")
          .doc(childId);

      // جلب بيانات الطفل
      DocumentSnapshot childDoc = await childRef.get();

      if (childDoc.exists) {
        // جلب الإجابات المخزنة في المصفوفة المناسبة
        List<dynamic> answers = childDoc.get("progress.$progressField") ?? [];
        
        // التحقق إذا كانت الإجابة موجودة في المصفوفة
        return answers.contains(answer);
      }
      return false;
    } catch (e) {
      print("❌ خطأ أثناء التحقق من الإجابة: $e");
      return false;
    }
  }

  // ✅ دالة لتحديث حالة الـ progress للطفل في Firestore مع تخزين الإجابة
  Future<void> updateProgressWithAnswer(String parentId, String childId, String type, String answer) async {
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

      // إضافة الإجابة إلى المصفوفة المناسبة
      await childRef.update({
        "progress.$progressField": FieldValue.arrayUnion([answer]), // إضافة الإجابة إلى المصفوفة
      });

      print("🎉 تم تحديث حالة التقدم مع الإجابة بنجاح!");
    } catch (e) {
      print("❌ خطأ أثناء تحديث حالة التقدم: $e");
    }
  }
}

