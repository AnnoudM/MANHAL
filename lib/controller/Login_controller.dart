import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../view/ChildListView.dart';

class LoginController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // TextEditingControllers لحفظ البيانات المدخلة
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // دوال تسجيل الدخول
  Future<void> loginUser({
    required String email,
    required String password,
    required BuildContext context,
    required VoidCallback onLoginSuccess, // إضافة المعامل الخاص بنجاح تسجيل الدخول
  }) async {
    try {
      // محاولة تسجيل الدخول
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // التأكد من التحقق من البريد الإلكتروني
      if (userCredential.user != null && userCredential.user!.emailVerified) {
        onLoginSuccess();  // تنفيذ دالة النجاح عند تحقق تسجيل الدخول
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'يرجى التحقق من بريدك الإلكتروني قبل تسجيل الدخول.',
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'لا يوجد مستخدم بهذا البريد الإلكتروني.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'كلمة المرور غير صحيحة.';
      } else {
        errorMessage = 'حدث خطأ أثناء تسجيل الدخول. حاول مرة أخرى.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ غير متوقع. حاول مرة أخرى.'),
        ),
      );
    }
  }

  // الانتقال إلى صفحة التسجيل
  void navigateToSignUp(BuildContext context) {
    Navigator.pushNamed(context, '/signup');
  }

  // استرجاع كلمة المرور
  Future<void> resetPassword(String email, BuildContext context) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء إرسال رابط إعادة تعيين كلمة المرور.'),
        ),
      );
    }
  }
} 
