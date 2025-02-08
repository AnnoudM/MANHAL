import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../view/HomePageView.dart';
import '../view/ChildProfileView.dart';

class HomePageController extends StatefulWidget {
  final String childID; // معرف الطفل

  const HomePageController({Key? key, required this.childID}) : super(key: key);

  @override
  _HomePageControllerState createState() => _HomePageControllerState();
}

class _HomePageControllerState extends State<HomePageController> {
  String? parentId;

  @override
  void initState() {
    super.initState();
    _fetchParentID();
  }

  // 🔹 جلب معرف الوالد
  void _fetchParentID() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        parentId = user.uid;
      });
      print("✅ معرف الوالد: $parentId");
      print("✅ معرف الطفل: ${widget.childID}");
    } else {
      print("⚠️ لم يتم تسجيل الدخول.");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (parentId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Parent')
          .doc(parentId)
          .collection('Children')
          .doc(widget.childID)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('⚠️ لا توجد بيانات لهذا الطفل')),
          );
        }

        var childData = snapshot.data!.data() as Map<String, dynamic>;

        return HomePageView(
          userName: childData['name'] ?? 'غير معروف',
          age: childData['age'] ?? 0,
          gender: childData['gender'] ?? 'غير معروف',
          photoUrl: childData['photoUrl'] ?? 'assets/images/girl.png',
          childID: widget.childID,

          // التنقل إلى صفحة ملف الطفل
          onProfileClick: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChildProfileView(
                  childID: widget.childID,
                  name: childData['name'] ?? 'غير معروف',
                  age: childData['age'] ?? 0,
                  gender: childData['gender'] ?? 'غير معروف',
                  photoUrl: childData['photoUrl'] ?? 'assets/images/girl.png',
                ),
              ),
            );
          },

          onUserNameClick: () {
            print('تم النقر على اسم الطفل');
          },

          onScanImageClick: () {
            print('تم النقر على زر مسح الصورة');
          },
        );
      },
    );
  }
}