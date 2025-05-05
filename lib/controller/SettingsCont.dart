import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:manhal/view/ProgressView.dart';
import '../view/InitialView.dart';
import '../view/ChildListView.dart';
import '../view/PersonalInfoView.dart';
import '../view/ChildPageView.dart';
import '../view/ScreenLimitView.dart';
import '../view/manage_contnet_view.dart';
import '../model/PersonalInfoModel.dart';
import '../model/child_model.dart';

class SettingsController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Handle settings tap
  void onSettingSelected(BuildContext context, String settingName,
      {String? childId, String? parentId}) async {
    print('Tapped: $settingName');
    print('🔹 Params: childId=$childId, parentId=$parentId');

    if (settingName == 'أطفالي') {
      _navigateToChildList(context);
    } else if (settingName == 'معلوماتي الشخصية') {
      await _navigateToPersonalInfo(context);
    } else if (settingName == 'معلومات الطفل') {
      if (childId == null || childId.isEmpty || parentId == null || parentId.isEmpty) {
        print('❌ Missing childId or parentId');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚠️ لا يمكن عرض معلومات الطفل، المعرف غير صحيح!",
                style: TextStyle(fontFamily: 'alfont')),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      await _navigateToChildPage(context, childId, parentId);
    } else if (settingName == 'الحد اليومي للاستخدام') {
      if (childId != null && parentId != null) {
        _navigateToScreenLimit(context, parentId, childId);
      }
    } else if (settingName == 'إدارة المحتوى') {
      if (childId != null && parentId != null) {
        _navigateToManageContent(context, parentId, childId);
      }
    } else if (settingName == 'متابعة الطفل') {
      if (childId != null && parentId != null) {
        _navigateToProgress(context, parentId, childId);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$settingName clicked!',
              style: const TextStyle(fontFamily: 'alfont')),
          backgroundColor: Colors.blueAccent,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  // Navigate to child list
  void _navigateToChildList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChildListView()),
    );
  }

  // Navigate to parent info page
  Future<void> _navigateToPersonalInfo(BuildContext context) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('Parent').doc(user.uid).get();
        if (userDoc.exists) {
          PersonalInfoModel parentInfo =
              PersonalInfoModel.fromJson(userDoc.data() as Map<String, dynamic>);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PersonalInfoView(parentInfo: parentInfo),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error fetching user info: $e');
    }
  }

  // Navigate to specific child info
  Future<void> _navigateToChildPage(
      BuildContext context, String childId, String parentId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> childDoc = await _firestore
          .collection('Parent')
          .doc(parentId)
          .collection('Children')
          .doc(childId)
          .get();

      if (childDoc.exists && childDoc.data() != null) {
        Child childData = Child.fromMap(childId, childDoc.data()!);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChildPageView(child: childData),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚠️ Child info not found!",
                style: TextStyle(fontFamily: 'alfont')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Error fetching child info: $e');
    }
  }

  // Navigate to daily screen limit page
  void _navigateToScreenLimit(
      BuildContext context, String parentId, String childId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ScreenLimitView(parentId: parentId, childId: childId),
      ),
    );
  }

  // Navigate to content management page
  void _navigateToManageContent(
      BuildContext context, String parentId, String childId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ManageContentView(parentId: parentId, childId: childId),
      ),
    );
  }

  // Navigate to child progress page
  void _navigateToProgress(
      BuildContext context, String parentId, String childId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProgressView(parentId: parentId, childId: childId),
      ),
    );
  }

  // Logout confirmation and action
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
              child: const Text('تسجيل الخروج',
                  style: TextStyle(fontFamily: 'alfont')),
            ),
          ],
        );
      },
    );
  }

  // Sign out from Firebase and navigate to InitialPage
  Future<void> _signOutUser(BuildContext context) async {
    try {
      await _auth.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تسجيل الخروج بنجاح',
              style: TextStyle(fontFamily: 'alfont')),
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
          content: Text('⚠️ Error during logout: $e',
              style: const TextStyle(fontFamily: 'alfont')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
