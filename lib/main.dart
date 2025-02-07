import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../view/letter_view.dart';
import 'firebase_options.dart'; // تأكد من استيراد ملف الإعدادات
import 'package:manhal/view/InitialView.dart';
import 'package:manhal/view/signup_view.dart';
import 'package:manhal/controller/HomePageController.dart';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<void> signIn() async {
  await auth.signInWithEmailAndPassword(
      email: "alanoud.ibrahim5@gmail.com", password: "password123");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    runApp(const MyApp());
  } catch (e) {
    print("Error initializing Firebase: $e");
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Flutter Firestore Test',
      locale: const Locale('ar'), // تعيين اللغة العربية
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl, // جعل كل شيء يبدأ من اليمين
          child: child!,
        );
      },
      theme: ThemeData(
        fontFamily: 'Tajawal', // استخدم خطًا عربياً إذا أردت
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SignUpView(),
    );
  }
} 

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _nameController = TextEditingController();

  Future<void> _saveName() async {
    String name = _nameController.text.trim();
    if (name.isNotEmpty) {
      try {
        await firestore.collection('Parent').add({'name': name});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم حفظ الاسم بنجاح!")),
        );
        _nameController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("حدث خطأ: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى إدخال اسم قبل الحفظ!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'أدخل اسمك ليتم تخزينه في قاعدة البيانات:',
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                textDirection: TextDirection.rtl, // إدخال النص من اليمين
                controller: _nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'الاسم',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _saveName,
              child: const Text('حفظ الاسم في Firestore'),
            ),
          ],
        ),
      ),
    );
  }
}
