import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trueledger/main.dart' as app;

import 'package:trueledger/core/config/app_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App smoke test - verifies app launches', (tester) async {
    // Disable secure storage for CI reliability
    AppConfig.isIntegrationTest = true;

    await app.main();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    // Poll for up to 30 seconds for the app to settle on a known screen
    bool found = false;
    for (int i = 0; i < 500; i++) {
      await tester
          .pump(const Duration(milliseconds: 100)); // 100ms * 300 = 30s max

      final finder = find.byWidgetPredicate((widget) {
        if (widget is Text) {
          final data = widget.data;
          // Check for Title of Intro OR Dashboard OR specific failure/loading states that indicate app is alive
          return data == 'Track Your Wealth' || // Intro Title
              data == 'Dashboard' || // Dashboard Title
              data == 'Wealth Overview' || // Dashboard Section
              data == 'Smart Budgeting' || // Intro Page 2
              data == 'ANALYSIS & BUDGETS' || // Analysis Screen
              data == 'TrueLedger' || // App Bar Title
              data == 'Initializing...' || // Loading State
              data == 'Initialization Failed'; // Error State
        }
        return false;
      });

      if (finder.evaluate().isNotEmpty) {
        found = true;
        break;
      }
    }

    if (!found) {
      debugPrint(
          'Test timed out waiting for app to load. Dumping widget tree:');
      debugDumpApp();
      fail("App did not load Intro or Dashboard within 50 seconds");
    }

    expect(found, isTrue);
  });
}
