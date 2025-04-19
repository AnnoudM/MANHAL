import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:manhal/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('View ethical values from Firebase', (tester) async {
    // Start the full app
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // سجلي الدخول أو تأكدي إن الصفحة ظهرت
    expect(find.byKey(const Key('ethical_title')), findsOneWidget);


    print('✅ Test completed successfully');

  });
}
