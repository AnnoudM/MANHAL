import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../view/initialView.dart';
import '../view/childlistview.dart';
import '../controller/HomePageController.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    // Set up fade-in animation
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _animationController.forward();

    // Check if user is logged in
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    // Wait for splash delay
    await Future.delayed(Duration(seconds: 3));

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? selectedChildId = prefs.getString('selectedChildId');

      if (selectedChildId != null && selectedChildId.isNotEmpty) {
        // If a child is already selected, go to HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePageController(
              parentId: user.uid,
              childID: selectedChildId,
            ),
          ),
        );
      } else {
        // Logged in but no child selected → go to ChildList
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ChildListView()),
        );
      }
    } else {
      // Not logged in → go to initial screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => InitialPage()),
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
