import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:audioplayers/audioplayers.dart';
import '../model/letter_model.dart';

class LetterController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // التهيئة
  LetterController();

  // جلب البيانات من Firestore
  Future<LetterModel> fetchData(String letter) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('Category')
          .doc('letters')
          .collection('content')
          .doc(letter)
          .get();

      if (!doc.exists) {
        throw Exception("لم يتم العثور على الحرف");
      }

      var content = doc.data() as Map<String, dynamic>;
      return LetterModel.fromMap(content);
    } catch (e) {
      throw Exception("حدث خطأ أثناء تحميل البيانات: $e");
    }
  }

  // تشغيل الصوت باستخدام audioplayers
  Future<void> playAudio(String url) async {
    try {
      await _audioPlayer.setSourceUrl(url); // تعيين مصدر الصوت
      await _audioPlayer.resume(); // تشغيل الصوت
      print("📢 تشغيل الصوت بنجاح: $url");
    } catch (e) {
      print("❌ خطأ أثناء تشغيل الصوت: $e");
    }
  }

  // إيقاف تشغيل الصوت
  void stopAudio() {
    _audioPlayer.stop();
    print("🛑 تم إيقاف الصوت");
  }
}
