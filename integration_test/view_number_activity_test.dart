import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:manhal/main.dart' as app;
import 'package:firebase_auth/firebase_auth.dart';

Future<void> login(WidgetTester tester) async {
  app.main();
  await tester.pumpAndSettle(const Duration(seconds: 10));

  final loginButton = find.text('تسجيل الدخول');
  expect(loginButton, findsOneWidget);
  await tester.tap(loginButton);
  await tester.pumpAndSettle();

  await tester.enterText(
      find.byType(TextFormField).at(0), 'Raghadkhalid.sa@outlook.com');
  await tester.enterText(find.byType(TextFormField).at(1), 'A12345\$');

  final continueButton = find.text('تسجيل');
  expect(continueButton, findsOneWidget);
  await tester.tap(continueButton);
  await tester.pumpAndSettle(const Duration(seconds: 5));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('View number activity successfully', (tester) async {
    await login(tester);

    final LoloProfile = find.text('لولو').first;
    expect(LoloProfile, findsOneWidget);
    await tester.tap(LoloProfile);
    await tester.pumpAndSettle();

    final numbersJourney = find.text('رحلة الأرقام');
    expect(numbersJourney, findsOneWidget);
    await tester.tap(numbersJourney);
    await tester.pumpAndSettle();

    final numberTwo = find.text('٢');
    expect(numberTwo, findsOneWidget);
    await tester.tap(numberTwo);
    await tester.pumpAndSettle();
    
    final nextButton = find.text('التالي');
    expect(nextButton, findsOneWidget);
    await tester.tap(nextButton);
    await tester.pumpAndSettle();
    await FirebaseAuth.instance.signOut();

    print('View number activity test passed!');
  });
}
