import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:manhal/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Successful parent login navigates to ChildListView',
      (WidgetTester tester) async {
    await app.startApp();

    // ✅ انتظر ظهور زر "تسجيل الدخول" بعد SplashScreen
    final loginNavButton = find.text('تسجيل الدخول');
    await tester.pumpUntilFound(loginNavButton);
    expect(loginNavButton, findsOneWidget);

    // ✅ اضغط زر تسجيل الدخول
    await tester.tap(loginNavButton);
    await tester.pumpAndSettle();

    // ✅ أدخل البريد
    final emailField = find.widgetWithText(TextFormField, 'البريد الالكتروني');
    expect(emailField, findsOneWidget);
    await tester.enterText(emailField, 'alanoud.ibrahim5@gmail.com');

    // ✅ أدخل كلمة المرور
    final passwordField = find.widgetWithText(TextFormField, 'كلمة المرور');
    expect(passwordField, findsOneWidget);
    await tester.enterText(passwordField, '12345A');

    // ✅ اضغط زر تسجيل
    final loginButton = find.text('تسجيل');
    expect(loginButton, findsOneWidget);
    await tester.tap(loginButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // ✅ تحقق من الوصول إلى صفحة أطفالي
    expect(find.text('أطفالي'), findsOneWidget);
  });
}

// ✅ امتداد لمساعدة التست في انتظار ظهور عناصر
extension PumpUntilFound on WidgetTester {
  Future<void> pumpUntilFound(
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
    Duration step = const Duration(milliseconds: 100),
  }) async {
    final endTime = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(endTime)) {
      await pump(step);
      if (any(finder)) return;
    }
    throw TestFailure('Widget not found within timeout: $finder');
  }
}
