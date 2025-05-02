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
  expect(fahadChild, findsOneWidget);
  await tester.tap(fahadChild);
  await tester.pumpAndSettle(const Duration(seconds: 10)); 

  final settingsButton = find.byIcon(Icons.settings);
  expect(settingsButton, findsOneWidget);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Edit child name successfully', (tester) async {
    await login(tester); 
    await tester.pumpAndSettle(const Duration(seconds: 10));

    final settingsButton = find.byIcon(Icons.settings);
    expect(settingsButton, findsOneWidget);
    await tester.tap(settingsButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    for (var digit in ['1', '1', '1', '1']) {
      await tester.tap(find.text(digit));
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pumpAndSettle();

    final childInfoTile = find.text('معلومات الطفل');
    expect(childInfoTile, findsOneWidget);
    await tester.tap(childInfoTile);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    final nameTile = find.widgetWithIcon(ListTile, Icons.edit).at(0);
    expect(nameTile, findsOneWidget);
    await tester.tap(nameTile);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    final nameField = find.byType(TextFormField);
    expect(nameField, findsOneWidget);
    await tester.enterText(nameField, 'نورة');
    await tester.pump();

    final saveButton = find.text('حفظ');
    expect(saveButton, findsOneWidget);
    await tester.tap(saveButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('تم التعديل بنجاح'), findsOneWidget);
  });

  
}
