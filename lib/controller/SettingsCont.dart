import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../view/InitialView.dart';
import '../view/ChildListView.dart';
import '../view/PersonalInfoView.dart';
import '../view/ChildPageView.dart';
import '../view/ScreenLimitView.dart'; // ✅ استيراد صفحة الحد اليومي
import '../model/PersonalInfoModel.dart';
import '../model/child_model.dart';

class SettingsController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void onSettingSelected(BuildContext context, String settingName, {String? childId, String? parentId}) async {
    print('تم الضغط على: $settingName');
    print('🔹 القيم الممررة: childId=$childId, parentId=$parentId');

    if (settingName == 'أطفالي') {
      _navigateToChildList(context);
    } else if (settingName == 'معلوماتي الشخصية') {
      await _navigateToPersonalInfo(context);
    } else if (settingName == 'معلومات الطفل') {
      if (childId == null || childId.isEmpty ||  parentId == null || parentId.isEmpty) {
        print('❌ خطأ: childId أو parentId غير متوفرين');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚠️ لا يمكن عرض معلومات الطفل، المعرف غير صحيح!", style: TextStyle(fontFamily: 'alfont')),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      await _navigateToChildPage(context, childId, parentId);
    } else if (settingName == 'الحد اليومي للاستخدام') { 
      if (childId != null && parentId != null) {
        _navigateToScreenLimit(context, parentId, childId); // ✅ إضافة التنقل للحد اليومي
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
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('Parent').doc(user.uid).get();
        if (userDoc.exists) {
          PersonalInfoModel parentInfo = PersonalInfoModel.fromJson(userDoc.data() as Map<String, dynamic>);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PersonalInfoView(parentInfo: parentInfo),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ خطأ أثناء جلب بيانات المستخدم: $e');
    }
  }

  Future<void> _navigateToChildPage(BuildContext context, String childId, String parentId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> childDoc = await _firestore
          .collection('Parent')
          .doc(parentId)
          .collection('Children')
          .doc(childId)
          .get();

      if (childDoc.exists && childDoc.data() != null) {
        Map<String, dynamic> childDataMap = childDoc.data()!;
        Child childData = Child.fromMap(childId, childDataMap);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChildPageView(child: childData),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚠️ لم يتم العثور على معلومات الطفل!", style: TextStyle(fontFamily: 'alfont')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ خطأ أثناء جلب بيانات الطفل: $e');
    }
  }

  /// ✅ التنقل إلى شاشة الحد اليومي وتمرير `parentId` و `childId` فقط
  void _navigateToScreenLimit(BuildContext context, String parentId, String childId) {
    Navigator.push(context,
      MaterialPageRoute(
        builder: (context) => ScreenLimitView(parentId: parentId, childId: childId),
      ),
    );
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
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'alfont')),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _signOutUser(context);
              },
              child: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'alfont')),
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
        const SnackBar(
          content: Text('تم تسجيل الخروج بنجاح', style: TextStyle(fontFamily: 'alfont')),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
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
          content: Text('⚠️ حدث خطأ أثناء تسجيل الخروج: $e', style: const TextStyle(fontFamily: 'alfont')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}