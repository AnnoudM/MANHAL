import 'package:flutter/material.dart';
import 'package:manhal/view/PasscodeView.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manhal/controller/HomePageController.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class LockScreenView extends StatefulWidget {
  final String childId;
  final String parentId;

  const LockScreenView({
    super.key,
    required this.childId,
    required this.parentId,
  });

  @override
  _LockScreenViewState createState() => _LockScreenViewState();
}

class _LockScreenViewState extends State<LockScreenView> {
  StreamSubscription<DocumentSnapshot>? _childDocumentSubscription;
  Timer? _timeCheckTimer;
  Map<String, dynamic>? _cachedUsageLimit;

  @override
  void initState() {
    super.initState();
    setupMonitoring();
  }

  // listen to real-time updates and check allowed time periodically
  void setupMonitoring() {
    _childDocumentSubscription = FirebaseFirestore.instance
        .collection('Parent')
        .doc(widget.parentId)
        .collection('Children')
        .doc(widget.childId)
        .snapshots()
        .listen((docSnapshot) {
          if (!docSnapshot.exists) return;

          var data = docSnapshot.data();
          if (data == null || !data.containsKey('usageLimit')) {
            _cachedUsageLimit = null;
            navigateToHomeScreen();
            return;
          }

          _cachedUsageLimit = Map<String, dynamic>.from(data['usageLimit']);
          checkAllowedTime();
        });
//check allowed time
    _timeCheckTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      checkAllowedTime();
    });
  }

  // compare current time with usage window
  void checkAllowedTime() {
    if (_cachedUsageLimit == null) {
      navigateToHomeScreen();
      return;
    }

    String? startTimeString = _cachedUsageLimit?['startTime'];
    String? endTimeString = _cachedUsageLimit?['endTime'];

    if (startTimeString == null || endTimeString == null) {
      navigateToHomeScreen();
      return;
    }

    bool isAllowed = isWithinAllowedTime(startTimeString, endTimeString);

    if (isAllowed) {
      navigateToHomeScreen();
    }
  }

  // check if now is within allowed range
  bool isWithinAllowedTime(String startTimeString, String endTimeString) {
    DateTime now = DateTime.now();

    List<String> startParts = startTimeString.split(":");
    List<String> endParts = endTimeString.split(":");

    DateTime startTime = DateTime(
      now.year, now.month, now.day,
      int.parse(startParts[0]), int.parse(startParts[1]),
    );

    DateTime endTime = DateTime(
      now.year, now.month, now.day,
      int.parse(endParts[0]), int.parse(endParts[1]),
    );

    if (endTime.isBefore(startTime)) {
      return now.isAfter(startTime) || now.isBefore(endTime);
    } else {
      return now.isAfter(startTime) && now.isBefore(endTime);
    }
  }

  // open home screen if allowed
  void navigateToHomeScreen() {
    if (!mounted) return;

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

  @override
  void dispose() {
    _childDocumentSubscription?.cancel();
    _timeCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB3E5FC),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // sleeping chick image
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        "assets/images/sleeping.png",
                        width: 180,
                        height: 180,
                      ),
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
                  // time over message
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

          // parent access button
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
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
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
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
