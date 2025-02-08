import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChildProfileController {
  final String childID;

  ChildProfileController({required this.childID});

  Stream<DocumentSnapshot> childStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("No user logged in");
    }

    return FirebaseFirestore.instance
        .collection('Parent')
        .doc(user.uid)
        .collection('Children')
        .doc(childID)
        .snapshots(); // 🔹 جلب البيانات كـ Stream لتحديث الصورة فورًا عند تغييرها
  }
}