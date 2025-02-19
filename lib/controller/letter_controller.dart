import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:audioplayers/audioplayers.dart';
import '../model/letter_model.dart';

class LetterController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AudioPlayer _audioPlayer = AudioPlayer();

  LetterController();

  Future<LetterModel> fetchData(String letter) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('Category')
          .doc('letters')
          .collection('content')
          .doc(letter)
          .get();

      if (!doc.exists) {
        throw Exception("Letter not found.");
      }

      var content = doc.data() as Map<String, dynamic>;
      LetterModel letterData = LetterModel.fromMap(content);

      if (letterData.songUrl.isNotEmpty) {
        await _audioPlayer.setSourceUrl(letterData.songUrl);
      }

      return letterData;
    } catch (e) {
      throw Exception("Error loading data: $e");
    }
  }

  Future<void> playAudio(String url) async {
    try {
      await _audioPlayer.setSourceUrl(url);
      await _audioPlayer.resume();
      print("Audio played successfully: $url");
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  void stopAudio() {
    _audioPlayer.stop();
    print("Audio stopped.");
  }
}
