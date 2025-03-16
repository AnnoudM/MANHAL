// In Main.dart

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

// المؤقت الرئيسي للتحقق من الوقت
Timer? _usageCheckTimer;

// مراقب للتغييرات على وثيقة الطفل
StreamSubscription<DocumentSnapshot>? _childDocumentSubscription;

// كاش البيانات المحلية للحد الزمني
Map<String, dynamic>? _cachedUsageLimit;
String? _currentMonitoredChildId;

// ✅ مفتاح للملاحة
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
    setupUsageMonitoring(); // ✅ إعداد نظام المراقبة بشكل أكثر كفاءة
    
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        await FirebaseFirestore.instance.collection('Parent').doc(user.uid).update({
          'email': user.email
        });
        print('✅ تم تحديث البريد في Firestore بنجاح');
        
        // ✅ عند تسجيل الدخول، سنتحقق من الطفل المحدد
        setupChildMonitoring();
      } else {
        // ✅ إلغاء الاشتراك عند تسجيل الخروج
        cancelChildMonitoring();
      }
    });
    
    // ✅ مراقبة التغييرات في الطفل المحدد
    SharedPreferences.getInstance().then((prefs) {
      prefs.reload(); // تحديث البيانات المحلية
      String? selectedChildId = prefs.getString('selectedChildId');
      setupChildMonitoring(childId: selectedChildId);
    });
  }

  // ✅ دالة لإعداد نظام المراقبة بطريقة أكثر كفاءة
  void setupUsageMonitoring() {
    // استخدام مؤقت بفاصل زمني أقل لضمان سرعة الاستجابة دون استهلاك موارد كثيرة
    _usageCheckTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      checkUsageTime();
    });
  }
  
  // ✅ دالة منفصلة للتحقق من الوقت
 // Modified checkUsageTime function in _MyAppState class

void checkUsageTime() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  
  // التحقق من isParentArea
  bool isParentArea = prefs.getBool("isParentArea") ?? false;
  if (isParentArea) return;
  
  String? selectedChildId = prefs.getString('selectedChildId');
  if (selectedChildId == null || selectedChildId.isEmpty) return;
  
  // ✅ تحسين: التحقق إذا تغير الطفل المحدد (تم التبديل بين الأطفال)
  if (_currentMonitoredChildId != selectedChildId) {
    print("👶 تم اكتشاف تبديل الطفل من $_currentMonitoredChildId إلى $selectedChildId");
    
    // إعادة تهيئة المراقبة للطفل الجديد والتحقق مباشرة من الوقت المسموح
    await setupChildMonitoring(childId: selectedChildId);
    
    // ✅ تنفيذ فحص فوري للوقت للطفل الجديد
    if (_cachedUsageLimit != null) {
      String? startTimeString = _cachedUsageLimit?['startTime'];
      String? endTimeString = _cachedUsageLimit?['endTime'];
      
      if (startTimeString != null && endTimeString != null) {
        bool isAllowed = isWithinAllowedTime(startTimeString, endTimeString);
        
        if (!isAllowed) {
          User? user = auth.currentUser;
          if (user == null) return;
          
         // print("⛔️ الطفل الجديد خارج الوقت المسموح. سيتم التوجيه إلى شاشة القفل.");
          
          // توجيه المستخدم إلى شاشة القفل فوراً
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
  
  // إذا لم تكن هناك بيانات مخزنة مؤقتًا، فلا حاجة للتحقق
  if (_cachedUsageLimit == null) return;
  
  // استخدام البيانات المخزنة مؤقتًا بدلاً من قراءة Firestore كل مرة
  String? startTimeString = _cachedUsageLimit?['startTime'];
  String? endTimeString = _cachedUsageLimit?['endTime'];
  
  if (startTimeString == null || endTimeString == null) return;
  
  // التحقق من الوقت المسموح
  bool isAllowed = isWithinAllowedTime(startTimeString, endTimeString);
  
  if (!isAllowed) {
    User? user = auth.currentUser;
    if (user == null) return;
    
    //print("⛔️ تجاوز الحد الزمني المسموح. سيتم التوجيه إلى شاشة القفل.");
    
    // توجيه المستخدم إلى شاشة القفل
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LockScreenView(
        childId: selectedChildId, 
        parentId: user.uid
      )),
      (route) => false,
    );
  }
}

// تعديل دالة setupChildMonitoring للتأكد من معالجة البيانات بشكل فوري
Future<void> setupChildMonitoring({String? childId}) async {
  // إلغاء أي اشتراك سابق
  cancelChildMonitoring();
  
  User? user = auth.currentUser;
  if (user == null) return;
  
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? selectedChildId = childId ?? prefs.getString('selectedChildId');
  
  if (selectedChildId == null || selectedChildId.isEmpty) return;
  
  //print("👶 إعداد مراقبة للطفل: $selectedChildId");
  _currentMonitoredChildId = selectedChildId;
  
  // جلب البيانات الحالية فورًا (لتجنب التأخير في مراقبة الطفل الجديد)
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
        print("✅ تم تحميل بيانات الحد الزمني للطفل الجديد فورًا");
      } else {
        _cachedUsageLimit = null;
      }
    }
  } catch (e) {
    print("❌ خطأ في جلب بيانات الطفل: $e");
  }
  
  // إنشاء اشتراك لمراقبة التغييرات في وثيقة الطفل
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
        
        // تخزين بيانات الحد الزمني مؤقتًا
        _cachedUsageLimit = Map<String, dynamic>.from(data['usageLimit']);
        
        // التحقق الفوري من الوقت بعد تحديث البيانات
        checkUsageTime();
      });
}
  // ✅ دالة لإلغاء الاشتراك في مراقبة الطفل
  void cancelChildMonitoring() {
    _childDocumentSubscription?.cancel();
    _childDocumentSubscription = null;
    _currentMonitoredChildId = null;
  }
  
  // ✅ دالة مساعدة للتحقق من الوقت المسموح
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
    
    // معالجة حالة عبور منتصف الليل
    if (endTime.isBefore(startTime)) {
      return now.isAfter(startTime) || now.isBefore(endTime);
    } else {
      return now.isAfter(startTime) && now.isBefore(endTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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

  @override
  void dispose() {
    _usageCheckTimer?.cancel();
    cancelChildMonitoring();
    super.dispose();
  }
}