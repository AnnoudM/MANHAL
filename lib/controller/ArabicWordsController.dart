import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/ArabicWordsModel.dart';

class WordsController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<WordModel>> fetchWords(String parentId, String childId, String category) async {
    try {
      // 🔹 Fetch locked words
      DocumentSnapshot doc = await _firestore
          .collection("Parent")
          .doc(parentId)
          .collection("Children")
          .doc(childId)
          .get();

      List<String> lockedWords = [];
      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        lockedWords = List<String>.from(data?["lockedContent"]?["words"] ?? []);
      }

      // 🔹 Fetch words from Firestore
      QuerySnapshot snapshot = await _firestore
          .collection('Category')
          .doc('words')
          .collection('content')
          .doc(category)
          .collection('words')
          .get();

      // 🔹 Map words and check if locked
      return snapshot.docs.map((doc) {
        WordModel word = WordModel.fromMap(doc.data() as Map<String, dynamic>);
        return word.copyWith(isLocked: lockedWords.contains(word.name));
      }).toList();
    } catch (e) {
      print("Error fetching words: $e");
      return [];
    }
  }
}
