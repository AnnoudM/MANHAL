import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/ArabicWordsModel.dart';

class WordsController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<WordModel>> fetchWords(String category) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('Category')
          .doc('words')
          .collection('content')
          .doc(category)
          .collection('words')
          .get();

      return snapshot.docs.map((doc) => WordModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print("Error fetching words: $e");
      return [];
    }
  }
}
