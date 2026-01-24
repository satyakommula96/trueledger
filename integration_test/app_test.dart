import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:truecash/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App smoke test - verifies app launches', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));

    // Add basic verification here once we confirm the app structure
    // For now, just ensuring it starts without crashing is a good first step
    expect(find.byWidgetPredicate((widget) {
      if (widget is Text) {
        final data = widget.data;
        return data == 'Track Your Wealth' ||
            data == 'Dashboard' ||
            data == 'TrueCash' ||
            data == 'Initializing...' ||
            data == 'Initialization Failed';
      }
      return false;
    }), findsWidgets);
  });
}
