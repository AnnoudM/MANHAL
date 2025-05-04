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

  testWidgets('Add child - gender is required', (tester) async {
    await login(tester);

    final addChildButton = find.text('طفل جديد');
    expect(addChildButton, findsOneWidget);
    await tester.tap(addChildButton);
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byType(TextFormField).at(0), 'لولو'); 
    await tester
        .tap(find.byType(DropdownButtonFormField<String>).at(1)); 
    await tester.pumpAndSettle();
    await tester.tap(find.text('٥').first); 
    await tester.pumpAndSettle();

    final pencilIcon = find.byIcon(Icons.edit); 
    expect(pencilIcon, findsOneWidget);
    await tester.tap(pencilIcon);
    await tester.pumpAndSettle();

    final avatar = find.byType(GestureDetector).at(8); 
    await tester.tap(avatar);
    await tester.pumpAndSettle();

    final saveButton = find.text('حفظ');
    expect(saveButton, findsOneWidget);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    final addButton = find.text('إضافة');
    expect(addButton, findsOneWidget);
    await tester.tap(addButton); 
    await tester.pumpAndSettle();

    expect(find.text('هذا الحقل مطلوب'), findsWidgets);
    await FirebaseAuth.instance.signOut();


    print('Gender required test passed!');
  });
}
