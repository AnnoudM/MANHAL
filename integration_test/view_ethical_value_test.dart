import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:manhal/main.dart' as app;

Future<void> login(WidgetTester tester) async {
  app.main();
  // انتظر حتى استقرار الصفحة بالكامل
  await tester.pumpAndSettle(const Duration(seconds: 10));

  // تحقق من وجود زر تسجيل الدخول
  final loginButton = find.text('تسجيل الدخول');
  expect(loginButton, findsOneWidget);
  await tester.tap(loginButton);
  await tester.pumpAndSettle();

  // إدخال بيانات الاعتماد
  print('إدخال بيانات الاعتماد...');
  await tester.enterText(
      find.byType(TextFormField).at(0), 'Raghadkhalid.sa@outlook.com');
  await tester.enterText(find.byType(TextFormField).at(1), 'A12345\$');

  // تحقق من وجود زر "تسجيل"
  final continueButton = find.text('تسجيل');
  expect(continueButton, findsOneWidget);
  await tester.tap(continueButton);
  await tester.pumpAndSettle(const Duration(seconds: 5));

  print('التنقل بعد تسجيل الدخول...');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('التحقق من شاشة القيم الأخلاقية', (tester) async {
    // تسجيل الدخول أولًا
    await login(tester);

    // التحقق من وجود اسم الطفل "غنى"
    final raghadChild = find.text('غنى').first;
    expect(raghadChild, findsOneWidget);
    await tester.tap(raghadChild);
    await tester.pumpAndSettle();

    print('التحقق من وجود زر القيم الأخلاقية...');
    final ethicsButton = find.text('القيم الأخلاقية');
    expect(ethicsButton, findsOneWidget);
    await tester.tap(ethicsButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));  

    // الانتظار لفترة إضافية
    await tester.pumpAndSettle(const Duration(seconds: 15)); 

    // التحقق من وجود القيم الأخلاقية على المسار
    final valuesOnPath = [
      'التعاون', 'الإحسان', 'الأمانة', 'الصدق'
    ];

    // البحث عن كل قيمة أخلاقية على المسار
    for (var value in valuesOnPath) {
      final valueWidget = find.widgetWithText(Container, value);
      expect(valueWidget, findsOneWidget);
      print('✅ تم العثور على القيمة الأخلاقية "$value"!');
    }

    print('✅ جميع القيم الأخلاقية تم عرضها بنجاح!');
  });
}
