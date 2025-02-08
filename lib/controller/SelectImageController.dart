import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SelectImageController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateChildImage(String childID, String imagePath) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        String parentId = user.uid;

        // تحديث صورة الطفل في Firestore
        await _firestore
            .collection('Parent')
            .doc(parentId)
            .collection('Children')
            .doc(childID)
            .update({'photoUrl': imagePath});

        print("✅ تم تحديث صورة الطفل بنجاح!");
      }
    } catch (e) {
      print("❌ خطأ في تحديث صورة الطفل: $e");
    }
  }
}