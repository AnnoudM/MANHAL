import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:manhal/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Create Account - weak password', (tester) async {
    app.main();

    await tester.pumpAndSettle(const Duration(seconds: 10));

    final joinButton = find.text('الانضمام إلى منهل');
    expect(joinButton, findsOneWidget);
    await tester.tap(joinButton);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'نورة');
    await tester.enterText(
        find.byType(TextFormField).at(1), 'Parent@example.com');
    await tester.enterText(
        find.byType(TextFormField).at(2), '123'); // weak password
    await tester.enterText(find.byType(TextFormField).at(3), '123');
    await tester.pumpAndSettle();

    final continueButton = find.text('متابعة');
    expect(continueButton, findsOneWidget);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(find.textContaining('يجب أن تتكون كلمة المرور من 6 خانات على الأقل'),
        findsOneWidget);

    print('Weak password test passed!');
  });
}
