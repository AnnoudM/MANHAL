import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:manhal/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


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
  await tester.pumpAndSettle(const Duration(seconds: 10));

  final childTile = find.text('نورة');
  expect(childTile, findsOneWidget);
  await tester.tap(childTile);
  await tester.pumpAndSettle(const Duration(seconds: 10));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Edit child name with empty input', (tester) async {
    await login(tester);

    final settingsButton = find.byIcon(Icons.settings);
    expect(settingsButton, findsOneWidget);
    await tester.tap(settingsButton);
    await tester.pumpAndSettle();

    for (var digit in ['1', '1', '1', '1']) {
      await tester.tap(find.text(digit));
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pumpAndSettle();

    final childInfoTile = find.text('معلومات الطفل');
    expect(childInfoTile, findsOneWidget);
    await tester.tap(childInfoTile);
    await tester.pumpAndSettle();

    final nameTile = find.widgetWithIcon(ListTile, Icons.edit).at(0);
    expect(nameTile, findsOneWidget);
    await tester.tap(nameTile);
    await tester.pumpAndSettle();

    final nameField = find.byType(TextFormField);
    expect(nameField, findsOneWidget);
    await tester.enterText(nameField, '');
    await tester.pumpAndSettle();

    final saveButton = find.text('حفظ');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('هذا الحقل مطلوب'), findsOneWidget);
    await FirebaseAuth.instance.signOut();

  });
}
