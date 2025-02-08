import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SelectImageController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateChildImage(BuildContext context, String childID, String imagePath) async {
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

        // 🔹 عرض SnackBar عند النجاح
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "✅ تم تحديث الصورة بنجاح!",
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.green[300],
            duration: const Duration(seconds: 2),
          ),
        );

        // 🔹 إغلاق الصفحة بعد التحديث الناجح
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      }
    } catch (e) {
      print("❌ خطأ في تحديث صورة الطفل: $e");

      // 🔹 عرض SnackBar عند الفشل
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "❌ فشل في تحديث الصورة: $e",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[300],
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}