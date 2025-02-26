import 'package:flutter/material.dart';
import 'package:manhal/view/PasscodeView.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manhal/controller/HomePageController.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LockScreenView extends StatefulWidget {
  final String childId;
  final String parentId;

  const LockScreenView({super.key, required this.childId, required this.parentId});

  @override
  _LockScreenViewState createState() => _LockScreenViewState();
}

class _LockScreenViewState extends State<LockScreenView> {
  @override
  void initState() {
    super.initState();
    checkIfUnlocked(); // ✅ التحقق إذا كان يمكن إعادة الطفل
  }

  /// ✅ التحقق بشكل دوري إذا كان الوقت المسموح قد بدأ
  void checkIfUnlocked() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;

    while (mounted) {
      await Future.delayed(const Duration(seconds: 5)); // ✅ تحقق كل 5 ثوانٍ

      User? user = auth.currentUser;
      if (user == null) {
        print("⚠️ لا يوجد مستخدم مسجل الدخول.");
        return;
      }

      String parentId = widget.parentId;
      String childId = widget.childId;

      DocumentSnapshot<Map<String, dynamic>> childSnapshot = await firestore
          .collection('Parent')
          .doc(parentId)
          .collection('Children')
          .doc(childId)
          .get();

      if (!childSnapshot.exists) {
        print("⚠️ بيانات الطفل غير موجودة في Firestore!");
        return;
      }

      var data = childSnapshot.data();
      print("📥 البيانات المسترجعة من Firestore: $data"); // ✅ طباعة البيانات المسترجعة

      if (data == null || !data.containsKey('usageLimit')) {
        print("⚠️ لا يوجد حقل usageLimit في البيانات!");
        return;
      }

      Map<String, dynamic> usageLimit = data['usageLimit'];

      if (!usageLimit.containsKey('startTime') || !usageLimit.containsKey('endTime')) {
        print("⚠️ لا يوجد startTime أو endTime في usageLimit!");
        return;
      }

      String? startTimeString = usageLimit['startTime'];
      String? endTimeString = usageLimit['endTime'];

      if (startTimeString == null || endTimeString == null) {
        print("⚠️ لا يوجد startTime أو endTime!");
        continue;
      }

      DateTime now = DateTime.now();
      DateFormat format = DateFormat("HH:mm");

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

      print("⏳ التحقق من الوقت: الآن = ${format.format(now)}, البداية = ${format.format(startTime)}, النهاية = ${format.format(endTime)}");

      if (now.isAfter(startTime) && now.isBefore(endTime)) {
        print("✅ الوقت المسموح بدأ، إعادة الطفل إلى الصفحة الرئيسية!");
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomePageController(
                childID: widget.childId,
              ),
            ),
            (route) => false,
          );
        }
      } else {
        print("❌ لا يزال الطفل خارج الوقت المسموح.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent.shade100,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "⏳ انتهى وقت اللعب!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.timer_off, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "سيكون بإمكانك اللعب مجددًا عند وصول الوقت المسموح 🎉",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool("isParentArea", true); // ✅ تفعيل Parent Area
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
              child: const Text("🔓 أدخل رمز الوالد"),
            ),
          ],
        ),
      ),
    );
  }
}