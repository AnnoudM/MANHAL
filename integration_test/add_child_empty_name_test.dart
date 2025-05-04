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

  testWidgets('Add child with empty name', (tester) async {
    await login(tester);

    final addChildButton = find.text('طفل جديد');
    expect(addChildButton, findsOneWidget);
    await tester.tap(addChildButton);
    await tester.pumpAndSettle();

    final imageIcon = find.byIcon(Icons.edit);
    expect(imageIcon, findsOneWidget);
    await tester.tap(imageIcon);
    await tester.pumpAndSettle();

    final avatar = find.byType(GestureDetector).at(8);
    await tester.tap(avatar);
    await tester.pumpAndSettle();

    final saveButton = find.text('حفظ');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    await tester.tap(find
        .byType(DropdownButtonFormField<String>)
        .at(0)); 
    await tester.pumpAndSettle();
    await tester.tap(find.text('أنثى').first); 
    await tester.pumpAndSettle();

    await tester.tap(find
        .byType(DropdownButtonFormField<String>)
        .at(1)); 
    await tester.pumpAndSettle();
    await tester.tap(find.text('٥').first); 
    await tester.pumpAndSettle();

    final confirmButton = find.text('إضافة');
    expect(confirmButton, findsOneWidget);
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    expect(find.text('هذا الحقل مطلوب'), findsOneWidget);
    print('Add child with empty name test passed!');
  });
}
