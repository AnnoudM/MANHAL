import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:manhal/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


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

  final fahadChild = find.text('فهد');
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

  testWidgets('Manage content and lock first letter successfully', (tester) async {
    await login(tester);
    await tester.pumpAndSettle(const Duration(seconds: 10));

    final settingsButton = find.byIcon(Icons.settings);
    expect(settingsButton, findsOneWidget);
    await tester.tap(settingsButton);
    await tester.pumpAndSettle();

    for (var digit in ['1', '1', '1', '1']) {
      await tester.tap(find.text(digit));
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pumpAndSettle();

    await tester.tap(find.text('إدارة المحتوى'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('إدارة الحروف'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('ب')); 
    await tester.pumpAndSettle();

    await tester.tap(find.text('نعم'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final lockIcon = find.byWidgetPredicate((widget) =>
      widget is Image &&
      widget.image is AssetImage &&
      (widget.image as AssetImage).assetName == 'assets/images/Lock.png');

    expect(lockIcon, findsWidgets); 
  });
}

