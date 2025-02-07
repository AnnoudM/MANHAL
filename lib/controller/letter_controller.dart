import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../model/letter_model.dart';

class LetterController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FlutterTts _flutterTts = FlutterTts();

  // التهيئة
  LetterController() { 
  _initializeTts();
  }

  // إعداد Text-to-Speech
  void _initializeTts() async {
    await _flutterTts.setLanguage("ar-SA"); // تعيين اللغة العربية (تأكد من اللغة المدعومة)
    await _flutterTts.setPitch(1.0); // ضبط النغمة
    await _flutterTts.setSpeechRate(0.5); // ضبط سرعة النطق
  }

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

  // تشغيل النص باستخدام Flutter TTS
  Future<void> speak(String text) async {
    try {
      if (text.isNotEmpty) {
        await _flutterTts.speak(text); // قراءة النص
        print("📢 تشغيل الصوت: $text");
      } else {
        print("⚠️ النص فارغ!");
      }
    } catch (e) {
      print("❌ خطأ أثناء تشغيل الصوت: $e");
    }
  }
}
