import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../view/HomePageView.dart';
import '../view/ChildProfileView.dart';
import '../view/letter_view.dart';
import '../view/ArabicLettersView.dart';
import '../view/SettingsView.dart';
//import '../view/NumbersView.dart';
//import '../view/WordsView.dart';
//import '../view/EthicalView.dart';
//import '../view/ScanView.dart';

class HomePageController extends StatefulWidget {
  final String childID; // معرف الطفل
  const HomePageController({super.key, required this.childID});

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
          photoUrl: childData['photoUrl'] ?? 'assets/images/default_avatar.jpg',
          childID: widget.childID,
          
          // 🔹 التنقل إلى صفحة "ملفي الشخصي"
          onProfileClick: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChildProfileView(
                  childID: widget.childID,
                  name: childData['name'] ?? 'غير معروف',
                  age: childData['age'] ?? 0,
                  gender: childData['gender'] ?? 'غير معروف',
                  photoUrl: childData['photoUrl'] ?? 'assets/images/default_avatar.jpg',
                ),
              ),
            );
          },

          // 🔹 التنقل إلى صفحة "مسح الصورة"
          onScanImageClick: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ArabicLetterPage(letter: 'أ')),
            );
          },
          onSettingsClick: (){Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsView()), // add settings navigate 
            );},

              onStickersClick: (){
                Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ArabicLetterPage(letter: 'أ')), // add stickers navigate
            );},


          // 🔹 التنقل إلى الصفحات بناءً على العنصر الذي يتم الضغط عليه في GridView
          onItemClick: (String item) {
            Widget targetPage;
            switch (item) {
              case 'رحلة الأحرف':
                targetPage = const ArabicLettersView(); //   استبدلوها بصفحة الاحرف وسوو لها امبورت
                break;
              case 'رحلة الأرقام':
                targetPage = const ArabicLetterPage(letter:'أ'); // استبدلوها بصفحة الارقام
                break;
              case 'رحلة الكلمات':
                targetPage = const ArabicLetterPage(letter:'أ'); // استبدلوها بصفحة الكلمات
                break;
              case 'القيم الأخلاقية':
                targetPage = const ArabicLetterPage(letter:'أ'); // استبدلوها بصفحة القيم
                break;
              default:
                return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => targetPage),
            );
          },
        );
      },
    );
  }
}