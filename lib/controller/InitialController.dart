import 'package:flutter/material.dart';
import '../model/initialModel.dart';
import '../view/Login_view.dart';
import '../view/Signup_view.dart';

class InitialPageController {
  final InitialPageModel model = InitialPageModel();

  void navigateToSignUp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpView()),
    );
  }

  void navigateToLogIn(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginView()),
    );
  }
}
