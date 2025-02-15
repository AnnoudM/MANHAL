import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/child_model.dart';

class ChildController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateChildInfo(Child child) async {
    await _firestore
        .collection('Parent')
        .doc(child.parentId)
        .collection('Children')
        .doc(child.id)
        .update(child.toMap());
  }

  Future<void> deleteChild(String parentId, String childId) async {
    await _firestore
        .collection('Parent')
        .doc(parentId)
        .collection('Children')
        .doc(childId)
        .delete();
  }

  Future<void> addChildToParent(BuildContext context, String parentId, Child child) async {
    try {
      // الوصول إلى مجموعة الوالد ثم إضافة الطفل في مجموعة فرعية
      await _firestore
          .collection('Parent')
          .doc(parentId)
          .collection('Children')
          .add(child.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تمت إضافة الطفل بنجاح'),
              backgroundColor: Colors.green[300],
              duration: const Duration(seconds: 2),
            ),
      );

      // الرجوع بعد الإضافة الناجحة
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء إضافة الطفل: $e')),
      );
    }
  }
}
