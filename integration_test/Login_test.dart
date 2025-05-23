import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:manhal/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';


void main() {
  setUpAll(() async {
  await Firebase.initializeApp();
});

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Invalid email shows error message',
      (WidgetTester tester) async {
        await FirebaseAuth.instance.signOut();
    await app.startApp();

    final loginNavButton = find.text('تسجيل الدخول');
    await tester.pumpUntilFound(loginNavButton, timeout: Duration(seconds: 15));
    await tester.tap(loginNavButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final emailField = find.widgetWithText(TextFormField, 'البريد الالكتروني');
    await tester.pumpUntilFound(emailField);
    await tester.enterText(emailField, 'alanoud5@gmail.com');

    final passwordField = find.widgetWithText(TextFormField, 'كلمة المرور');
    await tester.enterText(passwordField, 'A12345');

    final loginButton = find.text('تسجيل');
    await tester.tap(loginButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.text('البريد الالكتروني أو كلمة المرور غير صحيحة'), findsOneWidget);
  });

  testWidgets('Empty email shows required email error',
      (WidgetTester tester) async {
        await FirebaseAuth.instance.signOut();
    await app.startApp();

    final loginNavButton = find.text('تسجيل الدخول');
    await tester.pumpUntilFound(loginNavButton);
    await tester.tap(loginNavButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final emailField = find.widgetWithText(TextFormField, 'البريد الالكتروني');
    await tester.pumpUntilFound(emailField);

    final passwordField = find.widgetWithText(TextFormField, 'كلمة المرور');
    await tester.enterText(passwordField, 'A12345');

    final loginButton = find.text('تسجيل');
    await tester.tap(loginButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('يرجى إدخال البريد الإلكتروني'), findsOneWidget);
  });

  testWidgets('Empty password shows required password error',
      (WidgetTester tester) async {
      await FirebaseAuth.instance.signOut();
      await app.startApp();

    final loginNavButton = find.text('تسجيل الدخول');
    await tester.pumpUntilFound(loginNavButton);
    await tester.tap(loginNavButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final emailField = find.widgetWithText(TextFormField, 'البريد الالكتروني');
    await tester.pumpUntilFound(emailField);
    await tester.enterText(emailField, 'alanoud.ibrahim5@gmail.com');

    final loginButton = find.text('تسجيل');
    await tester.tap(loginButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('يرجى إدخال كلمة المرور'), findsOneWidget);
  });

  testWidgets('Unverified email shows unverified email error',
      (WidgetTester tester) async {
        await FirebaseAuth.instance.signOut();
    await app.startApp();

    final loginNavButton = find.text('تسجيل الدخول');
    await tester.pumpUntilFound(loginNavButton);
    await tester.tap(loginNavButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final emailField = find.widgetWithText(TextFormField, 'البريد الالكتروني');
    await tester.pumpUntilFound(emailField);
    await tester.enterText(emailField, 'alanood_ibrahim@hotmail.com');

    final passwordField = find.widgetWithText(TextFormField, 'كلمة المرور');
    await tester.enterText(passwordField, 'A1234567');

    final loginButton = find.text('تسجيل');
    await tester.tap(loginButton);
    await tester.pumpAndSettle(const Duration(seconds: 10));

    expect(find.text('يرجى التحقق من بريدك الإلكتروني قبل تسجيل الدخول'), findsOneWidget);
  });

  testWidgets('Successful parent login',
      (WidgetTester tester) async {
    await FirebaseAuth.instance.signOut();
    await app.startApp();

    final loginNavButton = find.text('تسجيل الدخول');
    await tester.pumpUntilFound(loginNavButton, timeout: Duration(seconds: 15));
    await tester.tap(loginNavButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final emailField = find.widgetWithText(TextFormField, 'البريد الالكتروني');
    await tester.pumpUntilFound(emailField);
    await tester.enterText(emailField, 'alanoud.ibrahim5@gmail.com');

    final passwordField = find.widgetWithText(TextFormField, 'كلمة المرور');
    await tester.enterText(passwordField, 'A12345');

    final loginButton = find.text('تسجيل');
    await tester.tap(loginButton);
    await tester.pumpAndSettle(const Duration(seconds: 7));

    expect(find.text('أطفالي'), findsOneWidget);
    await FirebaseAuth.instance.signOut();
  });
}

// ✅ أداة انتظار مخصصة
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
