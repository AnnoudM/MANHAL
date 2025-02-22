import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../view/HomePageView.dart';
import '../view/ChildProfileView.dart';
import '../view/letter_view.dart';
import '../view/ArabicLettersView.dart';
import '../view/SettingsView.dart';
import '../view/ArabicNumberView.dart';
//import '../view/NumbersView.dart';
//import '../view/WordsView.dart';
import '../view/EthicalValueView.dart';
//import '../view/ScanView.dart';
import '../view/sticker_page.dart'; // Import the Sticker Page

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
          onSettingsClick: () {
  print('🔍 فتح SettingsView لمعرف الطفل: ${widget.childID}, معرف الوالد: $parentId');
  
  if (widget.childID.isNotEmpty && parentId != null && parentId!.isNotEmpty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsView(
          selectedChildId: widget.childID,  // ✅ تمرير معرف الطفل
          currentParentId: parentId!, // ✅ تمرير معرف الوالد
        ),
      ),
    );
  } else {
    print('❌ خطأ: معرف الطفل أو معرف الوالد غير صالح');
  }
},



              onStickersClick: (){
                Navigator.push(
              context,
             MaterialPageRoute(builder: (context) => StickerPage()), // Navigate to Sticker Page
            );},


          // 🔹 التنقل إلى الصفحات بناءً على العنصر الذي يتم الضغط عليه في GridView
          onItemClick: (String item) {
            Widget targetPage;
            switch (item) {
              case 'رحلة الأحرف':
                targetPage = const ArabicLettersView(); //   استبدلوها بصفحة الاحرف وسوو لها امبورت
                break;
              case 'رحلة الأرقام':
                targetPage = const ArabicNumberView(); // استبدلوها بصفحة الارقام
                break;
              case 'رحلة الكلمات':
                targetPage = const ArabicLetterPage(letter:'أ'); // استبدلوها بصفحة الكلمات
                break;
              case 'القيم الأخلاقية':
                targetPage = EthicalValueView(childId: widget.childID, parentId: parentId ??''); // استبدلوها بصفحة القيم
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