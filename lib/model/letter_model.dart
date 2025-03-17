import 'package:audioplayers/audioplayers.dart';

class LetterModel {
  final List<String> examples;
    final List<String>? examplesTashkeel; // ✅ إضافة حقل جديد
  final List<String> images;
  final String letterSound;
  final String songUrl;

  LetterModel({
    required this.examples,
        this.examplesTashkeel, // ✅ اجعله اختياريًا لتفادي الأخطاء

    required this.images,
    required this.letterSound,
    required this.songUrl,
  });

 factory LetterModel.fromMap(Map<String, dynamic> map) {
    return LetterModel(
      examples: List<String>.from(map['examples'] ?? []),
      examplesTashkeel: map['examples_tashkeel'] != null
          ? List<String>.from(map['examples_tashkeel'])
          : null, // ✅ قراءة `examples_tashkeel` من Firestore
      images: List<String>.from(map['image'] ?? []),
      letterSound: map['letterSound'] ?? '',
      songUrl: map['songUrl'] ?? '',
    );
  }
}

final AudioPlayer _audioPlayer = AudioPlayer(); // ✅ مشغل ثابت

Future<void> playAudio(String url) async {
  await _audioPlayer.stop(); // ✅ أوقف أي صوت قيد التشغيل قبل تشغيل الجديد
  await _audioPlayer.play(UrlSource(url));
}

