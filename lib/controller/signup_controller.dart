import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/signup_model.dart';
import '../model/child_model.dart';
import 'package:flutter/material.dart';
import '../view/child_info_view.dart';
import '../view/InitialView.dart';

class SignUpController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // TextEditingControllers for the signup form
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  SignUpModel? _tempParentData;

  // Save temporary parent data
  Future<void> saveParentDataTemp(SignUpModel parent) async {
    _tempParentData = parent;
  }

  // Check if email is registered
  Future<bool> isEmailRegistered(String email) async {
    final result = await _firestore
        .collection('Parent')
        .where('email', isEqualTo: email)
        .get();

    return result.docs.isNotEmpty;
  }

  // Save parent data to Firestore
  Future<void> saveParentData(String uid, SignUpModel parent) async {
    await _firestore.collection('Parent').doc(uid).set(parent.toMap());
  }

  // Add child data under parent in Firestore
  Future<void> addChild(String parentId, Child child) async {
    try {
      await _firestore
          .collection('Parent')
          .doc(parentId)
          .collection('Children')
            .add({
      ...child.toMap(), // ✅ نأخذ جميع البيانات من child
      'level': 1, // ✅ نضيف level = 1 هنا حتى لو لم يكن في child.toMap()
      'stickers': [],
      'progress':{
        'letters':<String>[],
        'numbers':<String>[],
        'words':<String>[],
        'EthicalValue':<String>[],
      },
      'stickersProgress': {
      'numbers': 0,
      'letters': 0,
      'videos': 0,
      }
    }); 
    } catch (e) {
      print('Error adding child: $e');
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      print('Verification email sent to ${user.email}');
    }
  }

  // Check email verification
  Future<void> checkEmailVerification(BuildContext context) async {
    await _auth.currentUser?.reload();
    User? user = _auth.currentUser;

    if (user != null && user.emailVerified) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
             backgroundColor: Color(0xFFF8F8F8), 
            title: Text('تم تأكيد البريد الإلكتروني', style: TextStyle(fontFamily: 'alfont')),
            content: Text('تم تأكيد بريدك الإلكتروني بنجاح.', style: TextStyle(fontFamily: 'alfont')),
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
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
             backgroundColor: Color(0xFFF8F8F8), 
            title: Text('تأكيد البريد الإلكتروني', style: TextStyle(fontFamily: 'alfont')),
            content: Text('الرجاء تأكيد بريدك الإلكتروني عبر الرابط المرسل.', style: TextStyle(fontFamily: 'alfont')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('حسناً', style: TextStyle(fontFamily: 'alfont')),
              ),
            ],
          );
        },
      );
    }
  }

  // Proceed to Child Info page
  void proceedToChildInfo(BuildContext context, String parentId) {
    String childId = FirebaseFirestore.instance.collection('Children').doc().id;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChildInfoView(
        parentData: _tempParentData,
        parentId: parentId, // تمرير معرف الوالد
        childId: childId, 
      ),
    ),
  );
}


  // Register parent and child, and send email verification
  Future<void> registerParentAndChild(BuildContext context, Child child, SignUpModel parentData) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: parentData.email,
        password: parentData.password,
      );

      String parentId = userCredential.user!.uid;
await saveParentData(parentId, parentData);
await addChild(parentId, child);
await sendEmailVerification();

// استدعاء الصفحة بعد التسجيل
proceedToChildInfo(context, parentId);


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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString(), style: TextStyle(fontFamily: 'alfont'))),
      );
    }
  } 
}
