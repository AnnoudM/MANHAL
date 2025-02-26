import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' as intl;
import 'package:manhal/splash_screen.dart';
import 'firebase_options.dart';
import 'package:manhal/view/signup_view.dart';
import 'package:manhal/view/login_view.dart';
import 'package:manhal/view/SettingsView.dart';
import 'package:manhal/view/LockScreen.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;
Timer? usageTimer; // مؤقت لمراقبة الحد الزمني

// ✅ إضافة navigatorKey
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  void resetParentArea() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool("isParentArea", false);
  print("🔄 تم إعادة ضبط Parent Area عند تشغيل التطبيق");
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
        resetParentArea(); // ✅ إعادة ضبط الوضع عند بدء التطبيق
    runApp(const MyApp());
  } catch (e) {
    print("Error initializing Firebase: $e");
    runApp(const MyApp());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    startUsageMonitoring(); // ✅ بدء مراقبة الحد اليومي عند تشغيل التطبيق
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // ✅ ربط navigatorKey هنا
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firestore Test',
      locale: const Locale('ar'),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      theme: ThemeData(
        fontFamily: 'Blabeloo',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        '/signup': (context) => SignUpView(),
        '/login': (context) => LoginView(),
        '/settings': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final String? selectedChildId = args['selectedChildId'];
          final String currentParentId = args['currentParentId'] ?? "";

          if (selectedChildId == null) {
            print("⚠️ تحذير: لم يتم تمرير childId بشكل صحيح!");
          }

          return SettingsView(
            selectedChildId: selectedChildId ?? "",
            currentParentId: currentParentId,
          );
        },
      },
      home: SplashScreen(),
    );
  }



void startUsageMonitoring() async {
  usageTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // ✅ التحقق من isParentArea
    bool isParentArea = prefs.getBool("isParentArea") ?? false;
    if (isParentArea) {
      print("⚠️ الوالد داخل Parent Area، لن يتم التحقق من الحد الزمني.");
      return;
    }

    // ✅ جلب بيانات الحد الزمني من Firestore
    User? user = auth.currentUser;
    if (user == null) return;

    String? selectedChildId = prefs.getString('selectedChildId');
    if (selectedChildId == null || selectedChildId.isEmpty) {
      print("⚠️ لا يوجد selectedChildId محفوظ في SharedPreferences");
      return;
    }

    String parentId = user.uid;
    DocumentSnapshot<Map<String, dynamic>> childSnapshot = await firestore
        .collection('Parent')
        .doc(parentId)
        .collection('Children')
        .doc(selectedChildId)
        .get();

    if (!childSnapshot.exists || childSnapshot.data()?['usageLimit'] == null) {
      print("✅ لا يوجد حد زمني محدد، يمكن للطفل الاستمرار.");
      return;
    }

    Map<String, dynamic> usageLimit = childSnapshot.data()?['usageLimit'];
    String? startTime = usageLimit['startTime'];
    String? endTime = usageLimit['endTime'];

    if (startTime == null || endTime == null) {
      print("✅ لا يوجد وقت محدد، يمكن للطفل الاستمرار.");
      return;
    }

    DateTime now = DateTime.now();
    intl.DateFormat format = intl.DateFormat("HH:mm");

    List<String> startParts = startTime.split(":");
    List<String> endParts = endTime.split(":");

    DateTime start = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(startParts[0]),
      int.parse(startParts[1]),
    );

    DateTime end = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(endParts[0]),
      int.parse(endParts[1]),
    );

    print("⏰ الوقت الحالي: ${format.format(now)} | مسموح من: ${format.format(start)} إلى: ${format.format(end)}");

    if (now.isBefore(start) || now.isAfter(end)) {
      print("⛔️ الطفل تجاوز الحد المسموح، سيتم طرده!");

      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LockScreenView(childId: selectedChildId, parentId: parentId)),
        (route) => false,
      );
    } else {
      print("✅ الطفل داخل الوقت المسموح.");
    }
  });
}
  @override
  void dispose() {
    usageTimer?.cancel(); // ✅ إيقاف المراقبة عند إغلاق التطبيق
    super.dispose();
  }
}