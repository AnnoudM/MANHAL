import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:manhal/main.dart' as app;
import 'package:flutter/material.dart';

Future<void> login(WidgetTester tester) async {
  app.startApp();
  await tester.pumpAndSettle(const Duration(seconds: 10));

  final loginButton = find.text('تسجيل الدخول');
  expect(loginButton, findsOneWidget);
  await tester.tap(loginButton);
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextFormField).at(0), 'alanoud.ibrahim5@gmail.com');
  await tester.enterText(find.byType(TextFormField).at(1), 'A12345');

  final continueButton = find.text('تسجيل');
  expect(continueButton, findsOneWidget);
  await tester.tap(continueButton);
  await tester.pumpAndSettle(const Duration(seconds: 5));

  final fahadChild = find.text('نورة');
expect(fahadChild, findsOneWidget, reason: '');
await tester.tap(fahadChild);
  await tester.pump(); 
  await tester.pumpAndSettle(const Duration(seconds: 10)); 

  final settingsButton = find.byIcon(Icons.settings);
  await tester.pumpAndSettle(const Duration(seconds: 3));
  expect(settingsButton, findsOneWidget, reason: '');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Scan unclear object and show error SnackBar', (tester) async {
  await login(tester);
  await tester.pumpAndSettle(const Duration(seconds: 10));

  final scanButton = find.text('مسح الصورة');
  expect(scanButton, findsOneWidget, reason: 'زر المسح غير موجود في الهوم بيج');
  await tester.tap(scanButton);
  await tester.pumpAndSettle(const Duration(seconds: 10));

  await tester.tap(find.byIcon(Icons.camera_alt_outlined));
  await tester.pumpAndSettle(const Duration(seconds: 20)); 

  expect(find.text('لم يتم العثور على نص، حاول مرة أخرى!'), findsOneWidget);
});

}
