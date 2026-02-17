import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trueledger/main.dart' as app;

import 'package:trueledger/core/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Disable native dependencies for CI early
  AppConfig.isIntegrationTest = true;

  testWidgets('App smoke test - verifies app launches', (tester) async {
    // 1. Setup mock environment
    // Note: setMockInitialValues should be called before app.main()
    SharedPreferences.setMockInitialValues({});

    // 2. Launch the app
    await app.main();

    // 3. Wait for initial pump
    await tester.pump(const Duration(seconds: 2));

    // 4. Settle if possible
    try {
      await tester.pumpAndSettle(const Duration(seconds: 5));
    } catch (_) {
      // In some environments pumpAndSettle might fail due to infinite animations
      // We continue anyway and rely on our polling logic
    }

    // 5. Poll for success state
    bool found = false;
    final stopwatch = Stopwatch()..start();
    const timeout = Duration(seconds: 45);

    while (stopwatch.elapsed < timeout) {
      await tester.pump(const Duration(milliseconds: 500));

      final finder = find.byWidgetPredicate((widget) {
        if (widget is Text) {
          final data = widget.data;
          return data == 'Track Your Wealth' ||
              data == 'Dashboard' ||
              data == 'Wealth Overview' ||
              data == 'TrueLedger';
        }
        return false;
      });

      if (finder.evaluate().isNotEmpty) {
        found = true;
        break;
      }
    }

    if (!found) {
      debugPrint('Test timed out. Dumping widget tree:');
      debugDumpApp();
    }

    expect(found, isTrue,
        reason:
            "App failed to show initial screen within ${timeout.inSeconds}s");

    // 6. Finalization safety
    // Allow any pending async tasks to settle and the platform to stabilize
    // We use a simple pump to avoid hitting the 10-minute timeout of pumpAndSettle
    // if there are infinite animations (like the startup loading indicator).
    await tester.pump(const Duration(milliseconds: 500));
    await Future.delayed(const Duration(seconds: 1));
  });
}
