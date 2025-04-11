import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:manhal/model/ActivityModel.dart';
import 'package:firebase_storage/firebase_storage.dart';


class ActivityController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 final Map<String, int> _arabicLetterToStickerId = {
  "أ": 1, "ب": 2, "ت": 3, "ث": 4, "ج": 5, "ح": 6, "خ": 7,
  "د": 8, "ذ": 9, "ر": 10, "ز": 11, "س": 12, "ش": 13,
  "ص": 14, "ض": 15, "ط": 16, "ظ": 17, "ع": 18, "غ": 19,
  "ف": 20, "ق": 21, "ك": 22, "ل": 23, "م": 24, "ن": 25,
  "هـ": 26, "و": 27, "ي": 28,
};

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
    // ✅ نحول الرقم من عربي إلى إنجليزي قبل استخدامه كمفتاح للمستند
    final englishId = _convertArabicToEnglish(stickerId);

    print("🔹 جلب بيانات الملصق برقم: $englishId");

    DocumentSnapshot stickerDoc = await _firestore.collection("stickersNumbers").doc(englishId).get();

    if (!stickerDoc.exists) {
      print("❌ الملصق غير موجود في Firestore داخل stickersNumbers!");
      return;
    }

    Map<String, dynamic>? stickerData = stickerDoc.data() as Map<String, dynamic>?;

    if (stickerData == null || !stickerData.containsKey("link")) {
      print("❌ لا يوجد رابط للملصق!");
      return;
    }

    String stickerLink = stickerData["link"];

    DocumentReference childRef = _firestore
        .collection("Parent")
        .doc(parentId)
        .collection("Children")
        .doc(childId);

    await childRef.update({
      "stickers": FieldValue.arrayUnion([
        {
          "id": englishId,
          "link": stickerLink,
        }
      ]),
      "stickersProgress.numbers": FieldValue.increment(1),
    });

    print("🎉 تمت إضافة الملصق للطفل بنجاح من stickersNumbers!");
  } catch (e) {
    print("❌ خطأ أثناء إضافة الملصق من stickersNumbers: $e");
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

  // ✅ دالة لجلب ملصق عشوائي من Firestore
  Future<String> getRandomStickerFromFirestore() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('stickers').get();
      if (snapshot.docs.isNotEmpty) {
        List<String> stickers = snapshot.docs.map((doc) => doc['link'] as String).toList();
        stickers.shuffle(); // خلط القائمة لاختيار عشوائي
        return stickers.first; // اختيار أول عنصر بعد الخلط
      }
    } catch (e) {
      print("❌ خطأ أثناء جلب الملصقات: $e");
    }
    return 'assets/images/default_sticker.png'; // صورة افتراضية في حالة عدم العثور على ملصقات
  }

 Future<String?> getNextNumberSticker({
  required String parentId,
  required String childId,
  required String number,
}) async {
  try {
    final firestore = FirebaseFirestore.instance;

    print("📦 نحاول نجيب ملصق للرقم: $number");

    // ✅ نحاول نجيب الطفل
    DocumentSnapshot childDoc = await firestore
        .collection("Parent")
        .doc(parentId)
        .collection("Children")
        .doc(childId)
        .get();

    // ✅ نتحقق إذا الطفل حل هذا الرقم مسبقًا
    if (childDoc.exists) {
      var data = childDoc.data() as Map<String, dynamic>;

      if (data.containsKey("progress") &&
          data["progress"].containsKey("numbers")) {
        List<dynamic> solvedNumbers = data["progress"]["numbers"];
        if (solvedNumbers.contains(number)) {
          print("⚠️ الطفل حل هذا الرقم مسبقًا، ما راح نعطي ملصق.");
          return null;
        }
      }
    }
    // نحول الرقم العربي إلى رقم إنجليزي
    final englishNumber = _convertArabicToEnglish(number);

    // ✅ نجيب الملصق من stickersNumbers باستخدام رقم السؤال
    DocumentSnapshot stickerDoc = await firestore
        .collection("stickersNumbers")
        .doc(englishNumber)
        .get();

    if (!stickerDoc.exists) {
      print("❌ لا يوجد ملصق لهذا الرقم: $number");
      return null;
    }

    Map<String, dynamic> stickerData =
        stickerDoc.data() as Map<String, dynamic>;

    return stickerData["link"];
  } catch (e) {
    print("❌ خطأ في getNextNumberSticker: $e");
    return null;
  }
}

Future<String?> getLetterSticker({
  required String parentId,
  required String childId,
  required String letter,
}) async {
  try {
    int? stickerId = _arabicLetterToStickerId[letter];
    if (stickerId == null) {
      print("⚠️ لا يوجد رقم مرتبط بهذا الحرف: $letter");
      return null;
    }

    DocumentSnapshot stickerDoc = await _firestore
        .collection("stickersLetters")
        .doc(stickerId.toString())
        .get();

    if (!stickerDoc.exists) {
      print("❌ لا يوجد مستند sticker لهذا الحرف: $letter");
      return null;
    }

    final data = stickerDoc.data() as Map<String, dynamic>;
    return data["link"];
  } catch (e) {
    print("❌ خطأ في getLetterSticker: $e");
    return null;
  }
}

Future<void> addLetterStickerToChild({
  required String parentId,
  required String childId,
  required String letter,
}) async {
  try {
    int? stickerId = _arabicLetterToStickerId[letter];
    if (stickerId == null) {
      print("⚠️ لا يوجد رقم مرتبط بهذا الحرف: $letter");
      return;
    }

    DocumentSnapshot stickerDoc = await _firestore
        .collection("stickersLetters")
        .doc(stickerId.toString())
        .get();

    if (!stickerDoc.exists) {
      print("❌ لا يوجد sticker للحرف $letter");
      return;
    }

    final data = stickerDoc.data() as Map<String, dynamic>;
    final link = data["link"];
    final id = data["id"];

    DocumentReference childRef = _firestore
        .collection("Parent")
        .doc(parentId)
        .collection("Children")
        .doc(childId);

    await childRef.update({
      "stickers": FieldValue.arrayUnion([
        {"id": id, "link": link}
      ]),
      "stickersProgress.letters": FieldValue.increment(1),
    });

    print("🎉 تم حفظ ملصق الحرف '$letter' للطفل بنجاح!");
  } catch (e) {
    print("❌ خطأ في addLetterStickerToChild: $e");
  }
}


Future<void> giveNumberSticker(String parentId, String childId) async {
  final firestore = FirebaseFirestore.instance;

  try {
    // 1. جلب مستند الطفل
    DocumentReference childRef = firestore
        .collection("Parent")
        .doc(parentId)
        .collection("Children")
        .doc(childId);
    DocumentSnapshot childDoc = await childRef.get();

    int currentIndex = 0;
    if (childDoc.exists) {
      final data = childDoc.data() as Map<String, dynamic>;
      if (data.containsKey("stickersProgress") &&
          data["stickersProgress"].containsKey("numbers")) {
        currentIndex = data["stickersProgress"]["numbers"];
      }
    }

    int nextIndex = currentIndex + 1;

    // 2. جلب ملصق من stickersNumbers
    DocumentSnapshot stickerDoc = await firestore
        .collection("stickersNumbers")
        .doc(nextIndex.toString())
        .get();

    if (!stickerDoc.exists) {
      print("❌ لا يوجد ملصق للرقم $nextIndex");
      return;
    }

    final stickerData = stickerDoc.data() as Map<String, dynamic>;
    String link = stickerData["link"];
    String id = stickerData["id"].toString();

    // 3. تحديث ملصقات الطفل + progress
    await childRef.update({
      "stickers": FieldValue.arrayUnion([
        {"id": id, "link": link}
      ]),
      "stickersProgress.numbers": nextIndex,
    });

    print("🎉 تم إعطاء ملصق جديد للطفل!");
  } catch (e) {
    print("❌ خطأ في giveNumberSticker: $e");
  }
}

Future<String?> getNumberStickerByAnswer(String answer) async {
  try {
    final firestore = FirebaseFirestore.instance;

    // الرقم هو الـ ID حق المستند
    DocumentSnapshot doc = await firestore.collection('stickersNumbers').doc(answer).get();

    if (doc.exists && doc.data() != null) {
      final data = doc.data() as Map<String, dynamic>;
      return data['link'];
    } else {
      print("❌ لا يوجد ملصق لهذا الرقم: $answer");
      return null;
    }
  } catch (e) {
    print("❌ خطأ في getNumberStickerByAnswer: $e");
    return null;
  }
}
String _convertArabicToEnglish(String input) {
  const arabicToEnglish = {
    '٠': '0',
    '١': '1',
    '٢': '2',
    '٣': '3',
    '٤': '4',
    '٥': '5',
    '٦': '6',
    '٧': '7',
    '٨': '8',
    '٩': '9',
  };

  return input.split('').map((char) => arabicToEnglish[char] ?? char).join();
}


}