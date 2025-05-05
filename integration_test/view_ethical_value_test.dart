import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:manhal/main.dart' as app;

Future<void> login(WidgetTester tester) async {
  app.main();
  await tester.pumpAndSettle(const Duration(seconds: 10));

  final loginButton = find.text('تسجيل الدخول');
  expect(loginButton, findsOneWidget);
  await tester.tap(loginButton);
  await tester.pumpAndSettle();

  print('إدخال بيانات الاعتماد...');
  await tester.enterText(
      find.byType(TextFormField).at(0), 'Raghadkhalid.sa@outlook.com');
  await tester.enterText(find.byType(TextFormField).at(1), 'A12345\$');

  final continueButton = find.text('تسجيل');
  expect(continueButton, findsOneWidget);
  await tester.tap(continueButton);
  await tester.pumpAndSettle(const Duration(seconds: 5));

  print('التنقل بعد تسجيل الدخول...');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('التحقق من الضغط على القيمة الأخلاقية "الصدق"', (tester) async {
  await login(tester);

  final raghadChild = find.text('لولو').first;
  expect(raghadChild, findsOneWidget);
  await tester.tap(raghadChild);
  await tester.pumpAndSettle();

  final ethicsButton = find.text('القيم الأخلاقية');
  expect(ethicsButton, findsOneWidget);
  await tester.tap(ethicsButton);
  await tester.pumpAndSettle(const Duration(seconds: 5));  

  await tester.pumpAndSettle(const Duration(seconds: 15)); 

  final valueWidget = find.widgetWithText(Container, 'الصدق');
  expect(valueWidget, findsOneWidget); 

  await tester.tap(valueWidget);  
  await tester.pumpAndSettle(); 

  expect(find.text('الصدق'), findsOneWidget);
});

}