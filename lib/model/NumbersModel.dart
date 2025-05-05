import 'package:cloud_firestore/cloud_firestore.dart';

// This model handles static data and Firebase access related to numbers
class NumbersModel {
  // A static list of numbers from 1 to 20 that will be used in the app
  static final List<int> numbers = [
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
    11, 12, 13, 14, 15, 16, 17, 18, 19, 20
  ];

  // Fetches a list of locked numbers for a specific child from Firestore
  static Future<List<String>> fetchLockedNumbers(String parentId, String childId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("Parent")
          .doc(parentId)
          .collection("Children")
          .doc(childId)
          .get();

      if (!doc.exists) return [];

      // Extract locked numbers
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      List<String> lockedNumbers = List<String>.from(data["lockedContent"]["numbers"] ?? []);

      print("Locked numbers from Firebase: $lockedNumbers");
      return lockedNumbers;
    } catch (e) {
      print("Error fetching locked numbers: $e");
      return [];
    }
  }
}
