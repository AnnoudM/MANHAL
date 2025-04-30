import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:manhal/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Create Account - empty password', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 10));

    final signUpButton = find.text('الانضمام إلى منهل');
    expect(signUpButton, findsOneWidget);
    await tester.tap(signUpButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.enterText(find.byType(TextFormField).at(0), 'نورة');
    await tester.enterText(find.byType(TextFormField).at(1), 'Parent@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), '');
    await tester.enterText(find.byType(TextFormField).at(3), '');
    await tester.pumpAndSettle();

    final continueButton = find.text('متابعة');
    expect(continueButton, findsOneWidget);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(find.textContaining('يرجى إدخال كلمة المرور'), findsOneWidget);

    print('Password field required validation test passed!');
  });
}
