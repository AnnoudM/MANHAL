import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../view/initialView.dart';
import '../view/childlistview.dart'; // تأكد من استيراد الصفحة الصحيحة

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // إعداد الأنيميشن
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1), // مدة تأثير الفيد
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _animationController.forward();  // بدء تأثير الفيد

    // التحقق من تسجيل الدخول
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    await Future.delayed(Duration(seconds: 3)); // انتظار عرض الشاشة لمدة 3 ثوانٍ

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // 🔹 المستخدم مسجل دخول → توجيهه إلى ChildListView
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChildListView()), // عدل هذا وفقًا لصفحتك الفعلية
      );
    } else {
      // 🔹 المستخدم غير مسجل → توجيهه إلى InitialPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => InitialPage()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Image.asset(
            'assets/images/splash.png',
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }
}
