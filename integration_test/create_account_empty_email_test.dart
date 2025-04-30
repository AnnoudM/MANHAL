import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:manhal/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Create Account - empty email field', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 10));

    final createAccountButton = find.text('الانضمام إلى منهل');
    expect(createAccountButton, findsOneWidget);
    await tester.tap(createAccountButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.enterText(find.byType(TextFormField).at(0), 'نورة');
    await tester.enterText(find.byType(TextFormField).at(1), ''); // empty email
    await tester.enterText(find.byType(TextFormField).at(2), 'Password123');
    await tester.enterText(find.byType(TextFormField).at(3), 'Password123');
    await tester.pumpAndSettle();

    final continueButton = find.text('متابعة');
    expect(continueButton, findsOneWidget);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(find.text('يرجى إدخال البريد الإلكتروني'), findsOneWidget);

    print('Test for empty email field passed!');
  });
}
