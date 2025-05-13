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
import '../view/ArabicWordsView.dart';

class HomePageController extends StatefulWidget {
  final String parentId;
  final String childID;

  const HomePageController({
    Key? key,
    required this.parentId,
    required this.childID,
  }) : super(key: key);

  @override
  _HomePageControllerState createState() => _HomePageControllerState();
}

class _HomePageControllerState extends State<HomePageController> {
  String? parentId;
  String? selectedChildId;

  @override
  void initState() {
    super.initState();
    _fetchParentID();
    _resetParentAreaOnHome();
  }

  // get parent ID from FirebaseAuth and save selected child ID
  void _fetchParentID() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        parentId = user.uid;
        selectedChildId = widget.childID;
      });

      print("✅ Parent ID: $parentId");
      print("✅ Child ID: $selectedChildId");

      await _saveSelectedChildId(widget.childID);
    } else {
      print("⚠️ Not logged in.");
    }
  }

  // reset isParentArea flag when entering the home screen
  void _resetParentAreaOnHome() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isParentArea", false);
    print(" isParentArea set to false on home entry");
  }

  // save selected child ID to SharedPreferences
  Future<void> _saveSelectedChildId(String childId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedChildId', childId);
  }

  // load selected child ID from SharedPreferences
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
            body: Center(child: Text('لايوجد بيانات لهذا الطفل')),
          );
        }
        var childData = snapshot.data!.data() as Map<String, dynamic>;
        return HomePageView(
          userName: childData['name'] ?? 'غير معروف',
          age: childData['age'] ?? 0,
          gender: childData['gender'] ?? 'غير معروف',
          photoUrl: childData['photoUrl'] ?? 'assets/images/default_avatar.jpg',
          childID: widget.childID,

          // go to child profile
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

          // go to camera scanner view
          onScanImageClick: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CameraView()),
            );
          },

          // go to settings (parent area)
          onSettingsClick: () async {
            print(' Opening SettingsView for child: $selectedChildId, parent: $parentId');
            if (selectedChildId != null &&
                selectedChildId!.isNotEmpty &&
                parentId != null &&
                parentId!.isNotEmpty) {
              print(" Navigating to PasscodeView with childId: $selectedChildId");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PasscodeView(
                    parentId: parentId!,
                    selectedChildId: selectedChildId!,
                    currentParentId: parentId!,
                  ),
                ),
              );

              // disable monitoring when entering parent area
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isParentArea', true);
              print(" Parent area access enabled");
            } else {
              print(' Error: Invalid parent or child ID');
            }
          },

          // go to sticker page
          onStickersClick: () {
            if (parentId != null && selectedChildId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StickerPage(
                      childId: widget.childID, parentId: parentId ?? ''),
                ),
              );
            } else {
              print(" Error: Can't open sticker page, IDs are missing.");
            }
          },

          // handle navigation based on tapped grid item
          onItemClick: (String item) {
            Widget targetPage;
            switch (item) {
              case 'رحلة الأحرف':
                targetPage = ArabicLettersView(
                  parentId: widget.parentId,
                  childId: widget.childID,
                );
                break;
              case 'رحلة الأرقام':
                targetPage = ArabicNumberView(
                  parentId: widget.parentId,
                  childId: widget.childID,
                );
                break;
              case 'رحلة الكلمات':
                targetPage = ArabicWordsPage(
                  parentId: widget.parentId,
                  childId: widget.childID,
                );
                break;
              case 'القيم الأخلاقية':
                targetPage = EthicalValueView(
                  childId: widget.childID,
                  parentId: parentId ?? '',
                );
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
