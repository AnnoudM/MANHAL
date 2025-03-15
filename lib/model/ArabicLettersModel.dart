import 'package:cloud_firestore/cloud_firestore.dart';

class ArabicLettersModel {
  static final List<String> arabicLetters = [
    'أ', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ', 'د', 'ذ', 'ر', 'ز', 'س', 'ش',
    'ص', 'ض', 'ط', 'ظ', 'ع', 'غ', 'ف', 'ق', 'ك', 'ل', 'م', 'ن', 'هـ', 'و', 'ي'
  ];


  /// ✅ جلب الحروف المقفلة من Firestore
  static Future<List<String>> fetchLockedLetters(String parentId, String childId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Parent')
          .doc(parentId)
          .collection('Children')
          .doc(childId)
          .get();

      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

        // 🔒 استرجاع قائمة الحروف المقفلة
        List<String> lockedLetters =
            List<String>.from(data?['lockedContent']['letters'] ?? []);

        print("🔒 الحروف المقفلة من Firebase: $lockedLetters");
        return lockedLetters;
      } else {
        print("⚠️ لم يتم العثور على بيانات الطفل في Firebase.");
      }
    } catch (e) {
      print("❌ خطأ أثناء جلب الحروف المقفلة: $e");
    }
    return [];
  }
}