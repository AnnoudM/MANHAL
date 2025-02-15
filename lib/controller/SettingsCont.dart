import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../view/InitialView.dart';
import '../view/ChildListView.dart';
import '../view/PersonalInfoView.dart';
import '../view/ChildPageView.dart'; // ✅ استيراد صفحة معلومات الطفل
import '../model/PersonalInfoModel.dart';
import '../model/child_model.dart'; // ✅ التأكد من استيراد مودل الطفل

class SettingsController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void onSettingSelected(BuildContext context, String settingName, {String? childId, String? parentId}) async {
    print('تم الضغط على: $settingName'); // ✅ التحقق من أن الدالة تُستدعى
    print('🔹 القيم الممررة: childId=$childId, parentId=$parentId');

    if (settingName == 'أطفالي') {
      _navigateToChildList(context);
    } else if (settingName == 'معلوماتي الشخصية') {
      print('يتم تنفيذ _navigateToPersonalInfo'); // ✅ تأكيد أن هذا الجزء يعمل
      await _navigateToPersonalInfo(context);
    } else if (settingName == 'معلومات الطفل') {
      print('Child ID: $childId, Parent ID: $parentId'); // ✅ طباعة القيم للتحقق
      if (childId != null && parentId != null) {
        print('يتم تنفيذ _navigateToChildPage'); // ✅ تأكيد أن المتغيرات متوفرة
        await _navigateToChildPage(context, childId, parentId);
      } else {
        print('❌ خطأ: childId أو parentId غير متوفرين');
      }
    } else {
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
  }

  void _navigateToChildList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChildListView()),
    );
  }

  Future<void> _navigateToPersonalInfo(BuildContext context) async {
    try {
      print('جلب بيانات المستخدم من Firebase...'); // ✅ طباعة للتأكد أن الدالة تُنفذ
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('Parent').doc(user.uid).get();
        if (userDoc.exists) {
          print('تم العثور على بيانات المستخدم ✅');
          PersonalInfoModel parentInfo = PersonalInfoModel.fromJson(userDoc.data() as Map<String, dynamic>);

          print('الانتقال إلى PersonalInfoView...');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PersonalInfoView(parentInfo: parentInfo),
            ),
          );
        } else {
          print('لم يتم العثور على بيانات المستخدم ❌');
        }
      } else {
        print('لا يوجد مستخدم مسجل دخول ❌');
      }
    } catch (e) {
      print('حدث خطأ أثناء جلب البيانات: $e ❌');
    }
  }

  Future<void> _navigateToChildPage(BuildContext context, String childId, String parentId) async {
  try {
    print('جلب بيانات الطفل من Firebase...');

    DocumentSnapshot<Map<String, dynamic>> childDoc = await _firestore
        .collection('Parent')
        .doc(parentId)
        .collection('Children')
        .doc(childId)
        .get();

    if (childDoc.exists && childDoc.data() != null) {
      print('تم العثور على بيانات الطفل ✅');

      // تأكد من تمرير `id` إلى `Child.fromMap`
      Map<String, dynamic> childDataMap = childDoc.data()!;
      Child childData = Child.fromMap(childId, childDataMap);

      print('الانتقال إلى ChildInfoView...');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChildPageView(child: childData),
        ),
      );
    } else {
      print('لم يتم العثور على بيانات الطفل ❌');
    }
  } catch (e) {
    print('❌ حدث خطأ أثناء جلب بيانات الطفل: $e');
  }
}



  void logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF8F8F8),
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
                Navigator.of(context).pop();
                await _signOutUser(context);
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
      await _auth.signOut();

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

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const InitialPage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
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
