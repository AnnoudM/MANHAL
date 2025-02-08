import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../view/HomePageView.dart';

class HomePageController extends StatefulWidget {
  final String childID; // معرف الطفل

  const HomePageController({Key? key, required this.childID}) : super(key: key);

  @override
  _HomePageControllerState createState() => _HomePageControllerState();
}

class _HomePageControllerState extends State<HomePageController> {
  late Map<String, dynamic>? childData;
  bool isLoading = true;
  String? parentId;

  @override
  void initState() {
    super.initState();
    _fetchChildData();
  }
  

  Future<void> _fetchChildData() async {
    try {
      // 🔹 جلب معرف الوالد
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("⚠️ لم يتم تسجيل الدخول.");
        setState(() => isLoading = false);
        return;
      }

      parentId = user.uid; // تعيين معرف الوالد
      print("✅ معرف الوالد: $parentId"); // 🔹 طباعة معرف الوالد
      print("✅ معرف الطفل: ${widget.childID}"); // 🔹 طباعة معرف الطفل

      // 🔹 جلب بيانات الطفل باستخدام معرف الوالد ومعرف الطفل
      final snapshot = await FirebaseFirestore.instance
          .collection('Parent')
          .doc(parentId)
          .collection('Children')
          .doc(widget.childID)
          .get();

      if (snapshot.exists) {
        print("✅ تم العثور على بيانات الطفل: ${snapshot.data()}"); // 🔹 طباعة البيانات المسترجعة
        setState(() {
          childData = snapshot.data();
          isLoading = false;
        });
      } else {
        print("⚠️ لا يوجد بيانات لهذا الطفل في Firestore.");
        setState(() {
          childData = null;
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ خطأ أثناء جلب بيانات الطفل: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (childData == null) {
      return const Scaffold(
        body: Center(child: Text('⚠️ لا توجد بيانات لهذا الطفل')),
      );
    }

    return HomePageView(
      userName: childData!['name'] ?? 'غير معروف', // تمرير اسم الطفل
      age: childData!['age'] ?? 'غير معروف',
      gender: childData!['gender'] ?? 'غير معروف',
      photoUrl: childData!['photoUrl'] ?? 'غير معروف',
      onUserNameClick: () {
        print('تم النقر على اسم الطفل');
      },
      onScanImageClick: () {
        print('تم النقر على زر مسح الصورة');
      },
    );
  }
}