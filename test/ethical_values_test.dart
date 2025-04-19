import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manhal/firebase_options.dart'; // تأكد من المسار
import 'package:manhal/view/EthicalValueView.dart';

void main() {
  setUpAll(() async {
    // ✅ تهيئة Firebase
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // ✅ تسجيل الدخول بمستخدم وهمي
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: 'alanoud.ibrahim5@gmail.com', // ✳️ غيريها لمستخدم فعلي عندك
        password: '12345A',           // ✳️ لازم يكون صحيح
      );
    } catch (e) {
      print('⚠️ تسجيل الدخول فشل: $e');
    }
  });

  testWidgets('View ethical values displays values correctly', (WidgetTester tester) async {
    // ✅ عرض شاشة القيم الأخلاقية
    await tester.pumpWidget(
      const MaterialApp(
        home: EthicalValueView(
          parentId: 'aYMddkNaUwhKyGD6xfg3HuniueB3', // ✳️ عدليها للـ ID الصحيح من Firebase
          childId: 'qqSgYHZAluuxyRfdj57j',   // ✳️ عدليها للـ ID الصحيح من Firebase
        ),
      ),
    );

    // ⏳ الانتظار حتى تحميل الواجهة من الـ stream
    await tester.pumpAndSettle();

    // ✅ التحقق من ظهور قيمة أخلاقية (لازم تكون موجودة في Firestore)
    expect(find.text('الصدق'), findsOneWidget);
expect(find.text('الأمانة'), findsOneWidget);
  });
}
