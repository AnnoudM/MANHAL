// Entry point: Flutter + Firebase setup
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:manhal/splash_screen.dart';
import 'firebase_options.dart';
import 'package:manhal/view/signup_view.dart';
import 'package:manhal/view/login_view.dart';
import 'package:manhal/view/SettingsView.dart';
import 'package:manhal/view/LockScreen.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

// Firebase instances
FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;

// Global timer for checking child usage limit
Timer? _usageCheckTimer;

// Firestore subscription to child's document
StreamSubscription<DocumentSnapshot>? _childDocumentSubscription;

// Local cached usage limit for current child
Map<String, dynamic>? _cachedUsageLimit;
String? _currentMonitoredChildId;

// Global navigator key (for navigating outside widget tree)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Reset parent area flag on app start
void resetParentArea() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool("isParentArea", false);
  print("🔄 Parent Area reset on app startup");
}

// Initialize Firebase and start app
Future<void> startApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  resetParentArea();
  runApp(const MyApp());
}

// App entry point
void main() async {
  startApp();
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

    setupUsageMonitoring(); // Start periodic usage checks

    // Listen for login/logout changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        // Sync email with Firestore on login
        await FirebaseFirestore.instance.collection('Parent').doc(user.uid).update({
          'email': user.email
        });
        print('✅ Email updated in Firestore');

        // Start monitoring selected child
        setupChildMonitoring();
      } else {
        cancelChildMonitoring(); // stop monitoring on logout
      }
    });

    // When app starts, load selected child from local cache
    SharedPreferences.getInstance().then((prefs) {
      prefs.reload();
      String? selectedChildId = prefs.getString('selectedChildId');
      setupChildMonitoring(childId: selectedChildId);
    });
  }

  // Periodic timer to check if child is within allowed usage time
  void setupUsageMonitoring() {
    _usageCheckTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      checkUsageTime();
    });
  }

  // Check if child is allowed to use app right now
  void checkUsageTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isParentArea = prefs.getBool("isParentArea") ?? false;
    if (isParentArea) return;

    String? selectedChildId = prefs.getString('selectedChildId');
    if (selectedChildId == null || selectedChildId.isEmpty) return;

    // If child ID has changed, reload data
    if (_currentMonitoredChildId != selectedChildId) {
      print("👶 Child switched from $_currentMonitoredChildId to $selectedChildId");
      await setupChildMonitoring(childId: selectedChildId);

      // Immediately validate usage for new child
      if (_cachedUsageLimit != null) {
        String? startTimeString = _cachedUsageLimit?['startTime'];
        String? endTimeString = _cachedUsageLimit?['endTime'];

        if (startTimeString != null && endTimeString != null) {
          bool isAllowed = isWithinAllowedTime(startTimeString, endTimeString);
          if (!isAllowed) {
            User? user = auth.currentUser;
            if (user == null) return;

            navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => LockScreenView(
                childId: selectedChildId,
                parentId: user.uid
              )),
              (route) => false,
            );
            return;
          }
        }
      }
      return;
    }

    // Use cached values to avoid frequent Firestore reads
    if (_cachedUsageLimit == null) return;

    String? startTimeString = _cachedUsageLimit?['startTime'];
    String? endTimeString = _cachedUsageLimit?['endTime'];
    if (startTimeString == null || endTimeString == null) return;

    bool isAllowed = isWithinAllowedTime(startTimeString, endTimeString);
    if (!isAllowed) {
      User? user = auth.currentUser;
      if (user == null) return;

      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LockScreenView(
          childId: selectedChildId,
          parentId: user.uid
        )),
        (route) => false,
      );
    }
  }

  // Load and watch child document for changes in allowed time
  Future<void> setupChildMonitoring({String? childId}) async {
    cancelChildMonitoring(); // cleanup before new listener

    User? user = auth.currentUser;
    if (user == null) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selectedChildId = childId ?? prefs.getString('selectedChildId');
    if (selectedChildId == null || selectedChildId.isEmpty) return;

    _currentMonitoredChildId = selectedChildId;

    // Immediately fetch usage limit
    try {
      DocumentSnapshot<Map<String, dynamic>> childDoc = await firestore
          .collection('Parent')
          .doc(user.uid)
          .collection('Children')
          .doc(selectedChildId)
          .get();

      if (childDoc.exists) {
        var data = childDoc.data();
        if (data != null && data.containsKey('usageLimit')) {
          _cachedUsageLimit = Map<String, dynamic>.from(data['usageLimit']);
          print("✅ Usage limit loaded for child");
        } else {
          _cachedUsageLimit = null;
        }
      }
    } catch (e) {
      print("❌ Error fetching child data: $e");
    }

    // Listen for future changes in usageLimit
    _childDocumentSubscription = firestore
        .collection('Parent')
        .doc(user.uid)
        .collection('Children')
        .doc(selectedChildId)
        .snapshots()
        .listen((docSnapshot) {
      if (!docSnapshot.exists) return;

      var data = docSnapshot.data();
      if (data == null || !data.containsKey('usageLimit')) {
        _cachedUsageLimit = null;
        return;
      }

      _cachedUsageLimit = Map<String, dynamic>.from(data['usageLimit']);
      checkUsageTime(); // re-validate on update
    });
  }

  // Cancel Firestore listener
  void cancelChildMonitoring() {
    _childDocumentSubscription?.cancel();
    _childDocumentSubscription = null;
    _currentMonitoredChildId = null;
  }

  // Helper to check if current time is within allowed start/end time
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

    // Handle overnight usage window
    if (endTime.isBefore(startTime)) {
      return now.isAfter(startTime) || now.isBefore(endTime);
    } else {
      return now.isAfter(startTime) && now.isBefore(endTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // used for navigation outside widgets
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
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final String? selectedChildId = args['selectedChildId'];
          final String currentParentId = args['currentParentId'] ?? "";

          if (selectedChildId == null) {
            print("⚠️ Missing childId in settings route args");
          }

          return SettingsView(
            selectedChildId: selectedChildId ?? "",
            currentParentId: currentParentId,
          );
        },
      },
      home: SplashScreen(), // splash screen as app entry view
    );
  }

  @override
  void dispose() {
    _usageCheckTimer?.cancel(); // stop timer
    cancelChildMonitoring(); // cleanup listener
    super.dispose();
  }
}
