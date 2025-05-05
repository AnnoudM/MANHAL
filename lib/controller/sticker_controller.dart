import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/sticker_model.dart';

class StickerController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Sticker>> getStickersForChild(String parentId, String childId) async {
    try {
      // Step 1: Retrieve the child's document from Firestore
      DocumentSnapshot childSnapshot = await _firestore
          .collection('Parent')
          .doc(parentId)
          .collection('Children')
          .doc(childId)
          .get();
      // If the document doesn't exist, return an empty list
      if (!childSnapshot.exists) {
        print("❌ لا يوجد بيانات لهذا الطفل $childId");
        return [];
      }

      // Step 2: Extract the 'stickers' list from the child's data
      List<dynamic>? stickerDataList = childSnapshot['stickers'];

      if (stickerDataList == null || stickerDataList.isEmpty) {
        print("ℹ️ الطفل لا يمتلك ملصقات بعد.");
        return [];
      }

      List<Sticker> stickers = [];

      // Step 3: Convert each element in the list to a Sticker object
      for (var stickerData in stickerDataList) {
        if (stickerData is Map<String, dynamic>) {
          stickers.add(Sticker.fromMap(stickerData));
        }
      }
      // Log how many stickers were retrieved and return them
      print("✅ تم جلب ${stickers.length} ملصقات للطفل $childId");
      return stickers;
    } catch (e) {
      print("❌ خطأ أثناء جلب الملصقات: $e");
      return [];
    }
  }
}
