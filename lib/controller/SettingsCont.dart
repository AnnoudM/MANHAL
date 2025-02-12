import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../view/InitialView.dart';

class SettingsController {
  void onSettingSelected(BuildContext context, String settingName) {
    // حالياً فقط رسالة عند النقر
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$settingName تم النقر عليه!',
          style: const TextStyle(fontFamily: 'alfont'),
        ),
        backgroundColor: Colors.blueAccent,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'تأكيد تسجيل الخروج',
            style: TextStyle(fontFamily: 'alfont'),
          ),
          content: const Text(
            'هل أنت متأكد أنك تريد تسجيل الخروج؟',
            style: TextStyle(fontFamily: 'alfont'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'إلغاء',
                style: TextStyle(fontFamily: 'alfont'),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // إغلاق نافذة التأكيد
                await _signOutUser(context); // تنفيذ تسجيل الخروج
              },
              child: const Text(
                'تسجيل الخروج',
                style: TextStyle(fontFamily: 'alfont'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOutUser(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();  // تسجيل الخروج من فايربيس

      // عرض رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'تم تسجيل الخروج بنجاح',
            style: TextStyle(fontFamily: 'alfont'),
          ),
          backgroundColor: Colors.green[300],
          duration: const Duration(seconds: 2),
        ),
      );

      // الانتقال إلى صفحة InitialPage بعد تسجيل الخروج
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const InitialPage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      // في حال حدوث خطأ أثناء تسجيل الخروج
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ أثناء تسجيل الخروج: $e',
            style: const TextStyle(fontFamily: 'alfont'),
          ),
          backgroundColor: Colors.red[300],
        ),
      );
    }
  }
}
