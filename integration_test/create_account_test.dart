import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:manhal/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Create Account - valid information', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 10));
    await tester.tap(find.text('الانضمام إلى منهل'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'نور'); 
    await tester.enterText(fields.at(1), 'parent@example.com'); 
    await tester.enterText(fields.at(2), 'Password123.'); 
    await tester.enterText(fields.at(3), 'Password123.'); 
    await tester.pumpAndSettle();

    await tester.tap(find.text('متابعة'));
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.text('سجل طفلك الأول'), findsOneWidget);
    await tester.enterText(fields.at(0), 'سلمان'); 
    await tester.tap(find.byType(DropdownButton<String>).at(0)); 
    await tester.pumpAndSettle();
    await tester.tap(find.text('ذكر').last); 
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(1)); 
    await tester.pumpAndSettle();
    await tester.tap(find.text('٤').first); 
    await tester.pumpAndSettle();

    await tester.tap(find.text('تسجيل'));
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.text('تم إرسال رابط التحقق'), findsOneWidget);
    
    await tester.tap(find.text('حسناً'));
    await tester.pumpAndSettle();
    print('Test passed! '); 
  });
}