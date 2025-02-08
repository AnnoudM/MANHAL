import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/signup_model.dart';
import '../model/child_model.dart';
import 'package:flutter/material.dart';
import '../view/child_info_view.dart';

class SignUpController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // TextEditingControllers for the signup form
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  // تسجيل الوالد وإرسال رابط التحقق
  Future<String?> registerParent(SignUpModel parent) async {
    try {
      if (parent.password != confirmPasswordController.text) {
        throw Exception("كلمتا المرور غير متطابقتين.");
      }
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: parent.email,
        password: parent.password,
      );
      await sendEmailVerification();
      return userCredential.user!.uid;
    } catch (e) {
      return e.toString();
    }
  }

  // حفظ بيانات الوالد في Firestore
  Future<void> saveParentData(String uid, SignUpModel parent) async {
    await _firestore.collection('Parent').doc(uid).set(parent.toMap());
  }

  // إضافة بيانات الطفل تحت الوالد في Firestore
  Future<void> addChild(String parentId, Child child) async {
    try {
      await _firestore
          .collection('Parent')
          .doc(parentId)
          .collection('Children')
          .add(child.toMap());
    } catch (e) {
      print('Error adding child: $e');
    }
  }

  // إرسال رابط التحقق بالبريد الإلكتروني
  Future<void> sendEmailVerification() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      print('Verification email sent to ${user.email}');
    }
  }

  // التحقق من تأكيد البريد الإلكتروني
  Future<void> checkEmailVerification(BuildContext context) async {
    await _auth.currentUser?.reload();
    User? user = _auth.currentUser;

    if (user != null && user.emailVerified) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('تم تأكيد البريد الإلكتروني'),
            content: Text('تم تأكيد بريدك الإلكتروني بنجاح.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  proceedToChildInfo(
                    context,
                    SignUpModel(
                      name: nameController.text,
                      email: emailController.text,
                      password: passwordController.text,
                    ),
                  );
                },
                child: Text('متابعة'),
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
            title: Text('تأكيد البريد الإلكتروني'),
            content: Text('الرجاء تأكيد بريدك الإلكتروني عبر الرابط المرسل.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('حسناً'),
              ),
            ],
          );
        },
      );
    }
  }

  // الانتقال إلى صفحة إدخال بيانات الطفل
  void proceedToChildInfo(BuildContext context, SignUpModel parent) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChildInfoView(parentData: parent),
      ),
    );
  }

  // الانتقال إلى صفحة تسجيل الدخول
  void navigateToLogin(BuildContext context) {
    Navigator.pushNamed(context, '/login');
  }
}
