import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/sticker_model.dart';

class StickerController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Sticker>> getStickersForChild(String parentId, String childId) async {
    try {
      // 🟢 1️⃣ جلب بيانات الطفل من Firestore
      DocumentSnapshot childSnapshot = await _firestore
          .collection('Parent')
          .doc(parentId)
          .collection('Children')
          .doc(childId)
          .get();

      if (!childSnapshot.exists) {
        print("❌ لا يوجد بيانات لهذا الطفل $childId");
        return [];
      }

      // 🟢 2️⃣ استخراج قائمة الملصقات المخزنة كـ Map<String, dynamic>
      List<dynamic>? stickerDataList = childSnapshot['stickers'];

      if (stickerDataList == null || stickerDataList.isEmpty) {
        print("ℹ️ الطفل لا يمتلك ملصقات بعد.");
        return [];
      }

      List<Sticker> stickers = [];

      // 🟢 3️⃣ تحويل كل عنصر في القائمة إلى كائن Sticker
      for (var stickerData in stickerDataList) {
        if (stickerData is Map<String, dynamic>) {
          stickers.add(Sticker.fromMap(stickerData));
        }
      }

      print("✅ تم جلب ${stickers.length} ملصقات للطفل $childId");
      return stickers;
    } catch (e) {
      print("❌ خطأ أثناء جلب الملصقات: $e");
      return [];
    }
  }
}
