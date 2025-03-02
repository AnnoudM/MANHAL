import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StickerUploader {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadStickersToFirestore() async {
    try {
      // جلب قائمة الملفات في مجلد Stickers
      ListResult result = await _storage.ref('Stickers').listAll();

      for (var file in result.items) {
        // الحصول على الرابط المباشر لكل صورة
        String downloadURL = await file.getDownloadURL();

        // إنشاء وثيقة في Firestore للملصق
        await _firestore.collection('stickers').doc(file.name).set({
          'id': file.name, // اسم الصورة كمعرف
          'imageUrl': downloadURL,
        });
      }

      print("✅ تم حفظ الملصقات في Firestore بنجاح!");
    } catch (e) {
      print("❌ حدث خطأ أثناء رفع الملصقات: $e");
    }
  }
}
