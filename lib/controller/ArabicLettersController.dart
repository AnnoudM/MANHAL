import '../model/ArabicLettersModel.dart';

class ArabicLettersController {
  Future<List<String>> fetchLockedLetters(String parentId, String childId) async {
    try {
      return await ArabicLettersModel.fetchLockedLetters(parentId, childId);
    } catch (e) {
      print("❌ خطأ أثناء جلب الحروف المقفلة: $e");
      return [];
    }
  }
}
