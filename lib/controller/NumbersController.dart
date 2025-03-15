import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/NumbersModel.dart';

class NumbersController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// دالة لتحويل الأرقام الإنجليزية إلى أرقام عربية
  String _convertToArabicNumeral(int number) {
    const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((digit) => arabicNumerals[int.parse(digit)])
        .join();
  }

  // Fetch number data from Firebase
  Future<Map<String, dynamic>> fetchData(int number) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('Category')
          .doc('numbers')
          .collection('NumberContent')
          .doc(_convertToArabicNumeral(number)) // تحويل الرقم إلى رقم عربي
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

  List<String> lockedNumbers = [];

  // 🔹 Fetch locked numbers through the model
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
