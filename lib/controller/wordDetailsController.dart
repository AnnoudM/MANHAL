import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/wordDetailsModel.dart';

class WordController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<WordModel>> fetchWords(String category) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection("Category")
          .doc("words")
          .collection("content")
          .doc(category)
          .get();

      if (!doc.exists) return [];

      var data = doc.data() as Map<String, dynamic>;
      List<String> words = List<String>.from(data['examples'] ?? []);
      List<String> images = List<String>.from(data['images'] ?? []);

      List<WordModel> wordList = [];
      for (int i = 0; i < words.length; i++) {
        wordList.add(WordModel(word: words[i], imageUrl: images[i]));
      }

      return wordList;
    } catch (e) {
      print("Error fetching words: $e");
      return [];
    }
  }
}
