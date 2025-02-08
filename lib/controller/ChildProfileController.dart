import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/ChildProfileModel.dart';

class ChildProfileController {
  final String childID; // معرف الطفل

  ChildProfileController({required this.childID});

  Future<ChildProfileModel?> fetchChildData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('Parent')
            .doc(user.uid)
            .collection('Children') // تعديل المسار الصحيح
            .doc(childID) // استخدام معرف الطفل
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