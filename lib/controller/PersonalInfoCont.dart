import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/PersonalInfoModel.dart';
import '../view/InitialView.dart';

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

  Future<void> updateUserName(BuildContext context, String newName, Function(String) onUpdate) async {
  try {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('Parent').doc(user.uid).update({'name': newName});

      // تحديث الاسم في الواجهة مباشرة
      onUpdate(newName);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث الاسم بنجاح', style: TextStyle(fontFamily: 'alfont')),
          backgroundColor: Colors.green[300], // تعديل لون السناك بار
        ),
      );
    }
  } catch (e) {
    debugPrint('Error updating name: $e');
  }
}



  Future<void> updateUserEmail(BuildContext context, String newEmail) async {
  try {
    User? user = _auth.currentUser;
    if (user == null) return;

    // التحقق مما إذا كان البريد الإلكتروني الجديد مستخدمًا بالفعل
    var emailCheck = await _firestore
        .collection('Parent')
        .where('email', isEqualTo: newEmail)
        .get();

    if (emailCheck.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('البريد الإلكتروني مستخدم بالفعل', style: TextStyle(fontFamily: 'alfont')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // إرسال رابط التحقق للبريد الجديد
    await user.verifyBeforeUpdateEmail(newEmail);

    // تحديث البريد في قاعدة بيانات Firestore بعد التحقق منه
    await _firestore.collection('Parent').doc(user.uid).update({'email': newEmail});

    // إظهار ديالوج التأكيد
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF8F8F8),
          title: Text('تم إرسال رابط التحقق', style: TextStyle(fontFamily: 'alfont')),
          content: Text('تم إرسال رابط التحقق إلى بريدك الإلكتروني. الرجاء التحقق من بريدك.', style: TextStyle(fontFamily: 'alfont')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InitialPage(),
                  ),
                );
              },
              child: Text('حسناً', style: TextStyle(fontFamily: 'alfont')),
            ),
          ],
        );
      },
    );
  } catch (e) {
    debugPrint('Error updating email: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('حدث خطأ أثناء تحديث البريد', style: TextStyle(fontFamily: 'alfont')),
        backgroundColor: Colors.red,
      ),
    );
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
