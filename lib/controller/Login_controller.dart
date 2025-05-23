import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Handle user login with email and password
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null && userCredential.user!.emailVerified) {
        return null; // Login successful
      } else {
        return 'يرجى التحقق من بريدك الإلكتروني قبل تسجيل الدخول';
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        return 'البريد الالكتروني أو كلمة المرور غير صحيحة';
      } else {
        return 'البريد الالكتروني أو كلمة المرور غير صحيحة';
      }
    } catch (e) {
      return 'حدث خطأ غير متوقع. حاول مرة أخرى.';
    }
  }

  // Navigate to SignUp screen
  void navigateToSignUp(BuildContext context) {
    Navigator.pushNamed(context, '/signup');
  }

  // Send reset password email
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
