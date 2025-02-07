import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/signup_model.dart';
import '../model/child_model.dart';
import 'package:flutter/material.dart';

class SignUpController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // TextEditingControllers for the signup form
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

 Future<String?> registerParent(SignUpModel parent) async {
    try {
       if (parent.password != confirmPasswordController.text) {
        throw Exception("كلمتا المرور غير متطابقتين.");
      }
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: parent.email,
        password: parent.password,
      );
      return userCredential.user!.uid;
    } catch (e) {
      return e.toString();
    }
  }

   Future<void> saveParentData(String uid, SignUpModel parent) async {
    await _firestore.collection('Parent').doc(uid).set(parent.toMap());
  }

  Future<void> addChild(String parentId, Child child) async {
    await _firestore.collection('Parent').doc(parentId).collection('Children').add(child.toMap());
     await sendEmailVerification(); // إرسال رابط التحقق بعد تسجيل الطفل
  }
   Future<void> sendEmailVerification() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> checkEmailVerification(BuildContext context) async {
    User? user = _auth.currentUser;
    await user?.reload();
    if (user != null && user.emailVerified) {
      Navigator.pushReplacementNamed(context, '/home'); // الانتقال للصفحة الرئيسية بعد التحقق
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تأكيد بريدك الإلكتروني من الرابط المرسل.')),
      );
    }
  }

  void proceedToChildInfo(BuildContext context) {
    Navigator.pushNamed(context, '/childInfo');
  }

  void navigateToLogin(BuildContext context) {
    Navigator.pushNamed(context, '/login');
  }
}