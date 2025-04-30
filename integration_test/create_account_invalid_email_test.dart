import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:manhal/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Create Account - invalid email format', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 10));

    await tester.tap(find.text('الانضمام إلى منهل'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);

    await tester.enterText(fields.at(0), 'نورة');
    await tester.enterText(fields.at(1), 'parent.com');
    await tester.enterText(fields.at(2), 'Password123');
    await tester.enterText(fields.at(3), 'Password123');

    await tester.tap(find.text('متابعة'));
    await tester.pumpAndSettle();

    expect(find.text('يرجى إدخال بريد إلكتروني صحيح'), findsOneWidget);

    print('Test for invalid email passed!');
  });
}
