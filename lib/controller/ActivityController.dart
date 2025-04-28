import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:manhal/model/ActivityModel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../constants/word_categories.dart';

// Controller class responsible for handling activities and stickers
class ActivityController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


// ============= Helper Functions and Constants =============
// Mapping Arabic letters to their corresponding sticker IDs
 final Map<String, int> _arabicLetterToStickerId = {
  "أ": 1, "ب": 2, "ت": 3, "ث": 4, "ج": 5, "ح": 6, "خ": 7,
  "د": 8, "ذ": 9, "ر": 10, "ز": 11, "س": 12, "ش": 13,
  "ص": 14, "ض": 15, "ط": 16, "ظ": 17, "ع": 18, "غ": 19,
  "ف": 20, "ق": 21, "ك": 22, "ل": 23, "م": 24, "ن": 25,
  "هـ": 26, "و": 27, "ي": 28,
};

// Converts Arabic digits to English digits (used internally for Firestore document keys)
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

// ================= Fetch Data Functions =================
  // Fetch an activity based on its value and type (letter, number, word)
  Future<ActivityModel?> fetchActivity(String value, String type) async {
    try {
      // Determine subcollection name based on the activity type
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

     // Fetch the document from the specified subcollection
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

// Get the next number sticker based on the number answered by the child
 Future<String?> getNextNumberSticker({
  required String parentId,
  required String childId,
  required String number,
}) async {
  try {
    final firestore = FirebaseFirestore.instance;

    print("📦 نحاول نجيب ملصق للرقم: $number");

    // Fetch the child document
    DocumentSnapshot childDoc = await firestore
        .collection("Parent")
        .doc(parentId)
        .collection("Children")
        .doc(childId)
        .get();

      // Check if the child has already solved this number
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
    // Convert Arabic number to English
    final englishNumber = _convertArabicToEnglish(number);

   // Fetch the sticker document
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

// Retrieves the sticker link corresponding to a given Arabic letter
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

 // Retrieves a sticker link based on the answered numbe
Future<String?> getNumberStickerByAnswer(String answer) async {
  try {
    final firestore = FirebaseFirestore.instance;

    // Fetch the sticker document based on the answer (number ID)
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

 // Internal helper to fetch the sticker link for a completed word category
Future<String?> _getStickerForWordCategory(String category) async {
  const Map<String, String> wordCategoryToStickerId = {
    'shapes': '1',
    'colors': '2',
    'animals': '3',
    'food': '4',
  };

  final id = wordCategoryToStickerId[category];
  if (id == null) return null;

  final doc = await _firestore.collection("stickersWords").doc(id).get();
  if (!doc.exists) return null;

  final data = doc.data() as Map<String, dynamic>;
  return data["link"];
}


// ============= Stickers Management Functions =============
 // Add a sticker to a child's data under stickersNumbers collection
Future<void> addStickerToChild(String parentId, String childId, String stickerId) async {
  try {
    // Convert Arabic number to English number before using it as a document key
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

// Add a letter sticker to the child's stickers list
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

// Add a word category sticker to the child's stickers list
Future<void> addWordCategoryStickerToChild({
  required String parentId,
  required String childId,
  required String category,
  required String link,
}) async {
  final childRef = _firestore
      .collection("Parent")
      .doc(parentId)
      .collection("Children")
      .doc(childId);

  await childRef.update({
    "stickers": FieldValue.arrayUnion([
      {
        "id": category,
        "link": link,
      }
    ]),
    "stickersProgress.wordsProgress.$category": FieldValue.increment(0), // موجودة أصلًا لكن نضمن
  });

  print("🎉 تمت إضافة ملصق فئة $category للطفل!");
}

// Assign a new number sticker to a child based on their progress
Future<void> giveNumberSticker(String parentId, String childId) async {
  final firestore = FirebaseFirestore.instance;

  try {
    // Fetch the child document
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

    // Fetch the next sticker from stickersNumbers collection
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

    // Update child's stickers list and progress
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


// ============= Progress and Answer Management Functions =============
  // Check if a child has already answered correctly for a specific type
  Future<bool> hasAnsweredCorrectly(String parentId, String childId, String type, String answer) async {
    try {
      // Determine the progress field based on activity type
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

      // Fetch child document reference
      DocumentReference childRef = _firestore
          .collection("Parent")
          .doc(parentId)
          .collection("Children")
          .doc(childId);

      // Fetch child data
      DocumentSnapshot childDoc = await childRef.get();

      if (childDoc.exists) {
        // Retrieve stored answers for the specific activity type
        List<dynamic> answers = childDoc.get("progress.$progressField") ?? [];

        // Check if the answer already exists
        return answers.contains(answer);
      }
      return false;
    } catch (e) {
      print("❌ خطأ أثناء التحقق من الإجابة: $e");
      return false;
    }
  }

 // Update child's progress by saving a correct answer
  Future<void> updateProgressWithAnswer(String parentId, String childId, String type, String answer) async {
    try {
      // Determine the progress field based on activity type
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

      // Fetch child document reference
      DocumentReference childRef = _firestore
          .collection("Parent")
          .doc(parentId)
          .collection("Children")
          .doc(childId);

      // Update the specific progress array with the new answer
      await childRef.update({
        "progress.$progressField": FieldValue.arrayUnion([answer]), // إضافة الإجابة إلى المصفوفة
      });

      print("🎉 تم تحديث حالة التقدم مع الإجابة بنجاح!");
    } catch (e) {
      print("❌ خطأ أثناء تحديث حالة التقدم: $e");
    }
  }

// Update word progress for a child and check if a word category sticker should be awarded
Future<String?> updateWordProgressAndCheckSticker({
  required String parentId,
  required String childId,
  required String word,
}) async {
  final category = wordToCategory[word];
  if (category == null) return null;

  final childRef = _firestore
      .collection("Parent")
      .doc(parentId)
      .collection("Children")
      .doc(childId);

  final doc = await childRef.get();
  if (!doc.exists) return null;

  final data = doc.data() as Map<String, dynamic>;

  List<String> learnedWords = List<String>.from(data["progress"]["words"] ?? []);
  Map<String, dynamic> wordsProgress = Map<String, dynamic>.from(
    data["stickersProgress"]["wordsProgress"] ?? {},
  );

   // Skip if the child already learned this word
  if (learnedWords.contains(word)) return null;

  // Save the new learned word
  learnedWords.add(word);
  int currentCount = wordsProgress[category] ?? 0;
  wordsProgress[category] = currentCount + 1;

  // Update child's word progress
  await childRef.update({
    "progress.words": learnedWords,
    "stickersProgress.wordsProgress": wordsProgress,
  });

  // If the required number of words for the category is reached, return the sticker link
  final requiredCount = wordCategoryThreshold[category] ?? 99;
  if (wordsProgress[category] == requiredCount) {
    return await _getStickerForWordCategory(category);
  }

  return null;
}

}