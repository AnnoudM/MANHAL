import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/NumbersModel.dart';

// Controller responsible for handling number-related data operations
class NumbersController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//  Helper method to convert Western (English) numerals to Arabic numerals
// Example: 12 → '١٢'
  String _convertToArabicNumeral(int number) {
    const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((digit) => arabicNumerals[int.parse(digit)])
        .join();
  }

  // Fetches content related to a specific number from Firestore
  Future<Map<String, dynamic>> fetchData(int number) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('Category')
          .doc('numbers')
          .collection('NumberContent')
          .doc(_convertToArabicNumeral(number)) 
          .get();

      print("Fetched Data: ${doc.data()}");

      if (!doc.exists) {
        throw Exception("Number not found in the database");
      }

      return doc.data() as Map<String, dynamic>;
    } catch (e) {
      throw Exception("Error fetching number data: $e");
    }
  }
//Stores which numbers are locked for the current child 
  List<String> lockedNumbers = [];

  // Fetch locked numbers through the model
   // Returns a list of strings representing locked number IDs
  Future<List<String>> fetchLockedNumbers(
      String parentId, String childId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("Parent")
          .doc(parentId)
          .collection("Children")
          .doc(childId)
          .get();

      if (!doc.exists) return [];

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      List<String> lockedNumbers =
          List<String>.from(data["lockedContent"]["numbers"] ?? []);

      return lockedNumbers; // ✅ Return the list instead of void
    } catch (e) {
      print("❌ Error fetching locked numbers: $e");
      return [];
    }
  }
}
