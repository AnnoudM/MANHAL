import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/ChildProfileModel.dart';

class ChildProfileController {
  Future<ChildProfileModel?> fetchChildData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (snapshot.exists) {
          return ChildProfileModel.fromFirestore(snapshot.data()!);
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
    return null; // إذا لم تكن البيانات موجودة
  }
}