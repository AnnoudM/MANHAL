import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:manhal/view/PasscodeView.dart';
import 'package:manhal/view/camera_view.dart';
import '../view/HomePageView.dart';
import '../view/ChildProfileView.dart';
import '../view/letter_view.dart';
import '../view/ArabicLettersView.dart';
import '../view/ArabicNumberView.dart';
import '../view/EthicalValueView.dart';
import '../view/sticker_page.dart';

class HomePageController extends StatefulWidget {
  final String childID; // معرف الطفل
  const HomePageController({super.key, required this.childID});

  @override
  _HomePageControllerState createState() => _HomePageControllerState();
}

class _HomePageControllerState extends State<HomePageController> {
  String? parentId;
  String? selectedChildId; // ✅ تعريف متغير لحفظ معرف الطفل

  @override
  void initState() {
    super.initState();
    _fetchParentID();
    _resetParentAreaOnHome(); // ✅ إعادة ضبط isParentArea
  }

  // 🔹 جلب معرف الوالد
  void _fetchParentID() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        parentId = user.uid;
        selectedChildId = widget.childID;
      });

      print("✅ معرف الوالد: $parentId");
      print("✅ معرف الطفل: $selectedChildId");

      // ✅ حفظ معرف الطفل في SharedPreferences
      await _saveSelectedChildId(widget.childID);
    } else {
      print("⚠️ لم يتم تسجيل الدخول.");
    }
  }
  
// ✅ إعادة ضبط isParentArea عند دخول الطفل للصفحة الرئيسية
void _resetParentAreaOnHome() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool("isParentArea", false);
  print("🏠 تم ضبط Parent Area = false عند الدخول إلى الصفحة الرئيسية");
}

  /// ✅ حفظ selectedChildId في SharedPreferences
  Future<void> _saveSelectedChildId(String childId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedChildId', childId);
    print("✅ تم حفظ معرف الطفل في SharedPreferences: $childId");
  }

  /// ✅ استرجاع selectedChildId عند بدء التطبيق
  Future<String?> _getSelectedChildId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('selectedChildId');
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
              MaterialPageRoute(builder: (context) => CameraView()),
            );
          }, // 🔹 التنقل إلى صفحة الإعدادات
          onSettingsClick: () async {
            print('🔍 فتح SettingsView لمعرف الطفل: $selectedChildId، معرف الوالد: $parentId');
            if (selectedChildId != null && selectedChildId!.isNotEmpty && parentId != null && parentId!.isNotEmpty) {
              print("🔹 التنقل إلى PasscodeView - selectedChildId: $selectedChildId");
           Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PasscodeView(
      parentId: parentId!,
      selectedChildId: selectedChildId!, // ✅ تمرير معرف الطفل الصحيح
      currentParentId: parentId!, // ✅ تمرير معرف الوالد
    ),
  ),
);

// ✅ قبل الدخول إلى PasscodeView، تعطيل المراقبة
SharedPreferences prefs = await SharedPreferences.getInstance();
await prefs.setBool('isParentArea', true);
print("🛑 دخول إلى PasscodeView - تعطيل المراقبة");
            } else {
              print('❌ خطأ: معرف الطفل أو معرف الوالد غير صالح');
            }
          },

         // 🔹 التنقل إلى صفحة الملصقات مع تمرير parentId و childId
onStickersClick: () {
  if (parentId != null && selectedChildId != null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StickerPage(childId: widget.childID, parentId: parentId ?? ''),
      ),
    );
  } else {
    print("❌ خطأ: لا يمكن فتح صفحة الملصقات، parentId أو childId غير متوفر.");
  }
},


          // 🔹 التنقل إلى الصفحات بناءً على العنصر الذي يتم الضغط عليه في GridView
          onItemClick: (String item) {
            Widget targetPage;
            switch (item) {
              case 'رحلة الأحرف':
                targetPage = const ArabicLettersView();
                break;
              case 'رحلة الأرقام':
                targetPage = const ArabicNumberView();
                break;
              case 'رحلة الكلمات':
                targetPage = const ArabicLetterPage(letter: 'أ');
                break;
              case 'القيم الأخلاقية':
                targetPage = EthicalValueView(childId: widget.childID, parentId: parentId ?? '');
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