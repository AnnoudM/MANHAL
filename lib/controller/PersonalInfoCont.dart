import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/PersonalInfoModel.dart';
import '../view/InitialView.dart';

class PersonalInfoController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current parent info from Firestore
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

  // Update parent name in Firestore
  Future<void> updateUserName(
      BuildContext context, String newName, Function(String) onUpdate) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('Parent').doc(user.uid).update({'name': newName});
        onUpdate(newName);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تحديث الاسم بنجاح', style: TextStyle(fontFamily: 'alfont')),
            backgroundColor: Colors.green[300],
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating name: $e');
    }
  }

  // Update email with verification link and logout
  Future<void> updateUserEmail(BuildContext context, String newEmail) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      // Check if email is already used
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

      // Send verification link
      await user.verifyBeforeUpdateEmail(newEmail);

      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(0xFFF8F8F8),
            title: Text('تم إرسال رابط التحقق', style: TextStyle(fontFamily: 'alfont')),
            content: Text(
              'تم إرسال رابط التحقق إلى بريدك الإلكتروني الجديد. الرجاء الضغط على الرابط المرسل قبل تسجيل الدخول مرة أخرى.',
              style: TextStyle(fontFamily: 'alfont')),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => InitialPage()),
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

  // Delete parent account and all linked children
  Future<void> deleteUserAccount(BuildContext context) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      // Confirm dialog
      bool confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(0xFFF8F8F8),
            title: Text('تأكيد حذف الحساب', style: TextStyle(fontFamily: 'alfont')),
            content: Text(
              'هل أنت متأكد أنك تريد حذف حسابك؟ سيتم حذف جميع الأطفال المرتبطين به أيضًا.',
              style: TextStyle(fontFamily: 'alfont')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('إلغاء', style: TextStyle(fontFamily: 'alfont')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('حذف', style: TextStyle(color: Colors.red, fontFamily: 'alfont')),
              ),
            ],
          );
        },
      );

      if (!confirmDelete) return;

      // Delete all linked children
      QuerySnapshot childrenSnapshot = await _firestore
          .collection('Children')
          .where('parentId', isEqualTo: user.uid)
          .get();

      for (var childDoc in childrenSnapshot.docs) {
        await _firestore.collection('Children').doc(childDoc.id).delete();
      }

      // Delete parent from Firestore and Firebase Auth
      await _firestore.collection('Parent').doc(user.uid).delete();
      await user.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حذف الحساب بنجاح', style: TextStyle(fontFamily: 'alfont')),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => InitialPage()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Error deleting account: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء حذف الحساب', style: TextStyle(fontFamily: 'alfont')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
