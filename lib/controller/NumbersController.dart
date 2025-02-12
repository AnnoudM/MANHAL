import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/NumbersModel.dart';

class NumbersController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


// دالة لتحويل الأرقام الإنجليزية إلى أرقام عربية
String _convertToArabicNumeral(int number) {
  const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return number.toString().split('').map((digit) => arabicNumerals[int.parse(digit)]).join();
}
  // Fetch number data from Firebase
  Future<Map<String, dynamic>> fetchData(int number) async {
    try {
      DocumentSnapshot doc = await _firestore
    .collection('Category')
    .doc('numbers')
    .collection('NumberContent')
    .doc(_convertToArabicNumeral(number))  // تحويل الرقم إلى رقم عربي
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
} 

