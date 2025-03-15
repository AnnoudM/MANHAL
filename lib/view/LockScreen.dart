import 'package:flutter/material.dart';
import 'package:manhal/view/PasscodeView.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manhal/controller/HomePageController.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';

class LockScreenView extends StatefulWidget {
  final String childId;
  final String parentId;

  const LockScreenView(
      {super.key, required this.childId, required this.parentId});

  @override
  _LockScreenViewState createState() => _LockScreenViewState();
}

class _LockScreenViewState extends State<LockScreenView> {
  @override
  void initState() {
    super.initState();
    checkIfUnlocked(); // ✅ التحقق إذا كان يمكن إعادة الطفل
  }

  void checkIfUnlocked() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;

    while (mounted) {
      await Future.delayed(const Duration(seconds: 5)); // ✅ تحقق كل 5 ثوانٍ

      User? user = auth.currentUser;
      if (user == null) return;

      String parentId = widget.parentId;
      String childId = widget.childId;

      DocumentSnapshot<Map<String, dynamic>> childSnapshot = await firestore
          .collection('Parent')
          .doc(parentId)
          .collection('Children')
          .doc(childId)
          .get();

      if (!childSnapshot.exists) {
        // print("⚠️ بيانات الطفل غير موجودة في Firestore!");
        return;
      }

      var data = childSnapshot.data();

      // ✅ التحقق مما إذا كان `usageLimit` موجودًا أم لا
      if (data == null || !data.containsKey('usageLimit')) {
        // print("✅ لا يوجد حد زمني، سيتم فك القفل!");
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomePageController(
                childID: widget.childId,
                parentId: widget.parentId,
              ),
            ),
            (route) => false,
          );
        }
        return;
      }

      Map<String, dynamic> usageLimit = data['usageLimit'];
      if (!usageLimit.containsKey('startTime') ||
          !usageLimit.containsKey('endTime')) {
        // print("✅ لا يوجد وقت محدد، سيتم فك القفل!");
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomePageController(
                childID: widget.childId,
                parentId: widget.parentId,
              ),
            ),
            (route) => false,
          );
        }
        return;
      }

      String? startTimeString = usageLimit['startTime'];
      String? endTimeString = usageLimit['endTime'];
      if (startTimeString == null || endTimeString == null) continue;

      DateTime now = DateTime.now();
      intl.DateFormat format = intl.DateFormat("HH:mm");

      List<String> startParts = startTimeString.split(":");
      List<String> endParts = endTimeString.split(":");

      DateTime startTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(startParts[0]),
        int.parse(startParts[1]),
      );

      DateTime endTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(endParts[0]),
        int.parse(endParts[1]),
      );

      // ✅ معالجة حالة عبور منتصف الليل
      bool isWithinAllowedTime;
      if (endTime.isBefore(startTime)) {
        // 🟢 إذا كان `endTime` قبل `startTime` فهذا يعني أن الفترة تمتد عبر منتصف الليل
        isWithinAllowedTime = now.isAfter(startTime) || now.isBefore(endTime);
      } else {
        // 🟢 إذا كانت الفترة طبيعية داخل نفس اليوم
        isWithinAllowedTime = now.isAfter(startTime) && now.isBefore(endTime);
      }

      // print("⏰ الوقت الحالي: ${format.format(now)} | مسموح من: ${format.format(startTime)} إلى: ${format.format(endTime)}");

      if (isWithinAllowedTime) {
        // print("✅ الوقت داخل النطاق، سيتم فك القفل!");
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomePageController(
                childID: widget.childId,
                parentId: widget.parentId,
              ),
            ),
            (route) => false,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB3E5FC), // ✅ لون سماوي
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // ✅ صورة الكتكوت النائم
                      Image.asset(
                        "assets/images/sleeping.png",
                        width: 180,
                        height: 180,
                      ),

                      // ✅ صورة الساعة في يمين الكتكوت
                      Positioned(
                        bottom: 10,
                        right: 20,
                        child: Image.asset(
                          "assets/images/stopwatch.png",
                          width: 50,
                          height: 50,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ✅ نص "انتهى وقت اللعب!" تحت الكتكوت
                  Text(
                    "انتهى وقت اللعب!",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                      fontFamily: "Blabeloo",
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ✅ زر دخول الوالد (في أسفل الصفحة ولونه أحمر)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity, // ✅ بعرض الشاشة
              child: ElevatedButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool("isParentArea", true);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PasscodeView(
                        parentId: widget.parentId,
                        currentParentId: widget.parentId,
                        selectedChildId: widget.childId,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // ✅ لون أحمر لتحذير الطفل
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // ✅ زر دائري
                  ),
                  elevation: 5, // ✅ ظل خفيف
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_open, color: Colors.white, size: 24),
                    SizedBox(width: 10),
                    Text(
                      "دخول الوالد",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontFamily: "alfont",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
