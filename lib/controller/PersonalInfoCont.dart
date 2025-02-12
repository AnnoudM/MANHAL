import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/PersonalInfoModel.dart';

class PersonalInfoController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<PersonalInfoModel?> getUserInfo() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('Parent').doc(user.uid).get();
        if (userDoc.exists) {
          return PersonalInfoModel.fromJson(userDoc.data() as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('Error fetching user info: $e');
    }
    return null;
  }

  Future<void> updateUserName(BuildContext context, String newName) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('Parent').doc(user.uid).update({'name': newName});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تحديث الاسم بنجاح', style: TextStyle(fontFamily: 'alfont'))),
        );
      }
    } catch (e) {
      debugPrint('Error updating name: $e');
    }
  }

  Future<void> updateUserEmail(BuildContext context, String newEmail) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.verifyBeforeUpdateEmail(newEmail);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم إرسال رابط التأكيد إلى البريد الجديد', style: TextStyle(fontFamily: 'alfont'))),
        );
      }
    } catch (e) {
      debugPrint('Error updating email: $e');
    }
  }

  Future<void> deleteUserAccount(BuildContext context) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('Parent').doc(user.uid).delete();
        await user.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حذف الحساب بنجاح', style: TextStyle(fontFamily: 'alfont'))),
        );
        Navigator.pop(context); // الرجوع للخلف بعد الحذف
      }
    } catch (e) {
      debugPrint('Error deleting account: $e');
    }
  }
}
