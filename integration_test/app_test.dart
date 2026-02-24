library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trueledger/main.dart' as app;

import 'package:trueledger/core/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // Ensure we don't wait for infinite animations forever in CI
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  // Disable native dependencies for CI early
  AppConfig.isIntegrationTest = true;

  testWidgets('App smoke test - verifies app launches', (tester) async {
    debugPrint('INTEGRATION_TEST_LOG: Starting testWidgets...');

    // 1. Setup mock environment early
    debugPrint('INTEGRATION_TEST_LOG: Platform: ${Platform.operatingSystem}');
    debugPrint(
        'INTEGRATION_TEST_LOG: Environment: ${Platform.environment.keys.take(5).toList()}');

    // Note: setMockInitialValues should be called before app.main()
    // We only mock SharedPreferences to ensure a clean state
    SharedPreferences.setMockInitialValues({'intro_seen': false});
    debugPrint('INTEGRATION_TEST_LOG: Mocks initialized.');

    // 2. Launch the app
    try {
      debugPrint('INTEGRATION_TEST_LOG: Invoking app.main()...');
      // Ensure we don't have multiple bindings trying to initialized
      await app.main();
      debugPrint('INTEGRATION_TEST_LOG: app.main() completed.');
    } catch (e, stack) {
      debugPrint(
          'INTEGRATION_TEST_LOG: CRITICAL - app.main() threw exception: $e');
      debugPrint(stack.toString());
    }

    // 3. Wait for initial pump
    debugPrint('INTEGRATION_TEST_LOG: Performing initial pump...');
    await tester.pump(const Duration(seconds: 3));
    debugPrint('INTEGRATION_TEST_LOG: Initial pump completed.');

    // 4. Skip pumpAndSettle entirely to prevent iOS XCUITest deadlock on continuous animations
    debugPrint(
        'INTEGRATION_TEST_LOG: Skipping pumpAndSettle, navigating via manual pumps...');
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    // 5. Poll for success state
    debugPrint('INTEGRATION_TEST_LOG: Starting success state polling...');
    bool found = false;
    final stopwatch = Stopwatch()..start();
    const timeout = Duration(seconds: 60);

    while (stopwatch.elapsed < timeout) {
      await tester.pump(const Duration(milliseconds: 800));

      final finder = find.byWidgetPredicate((widget) {
        if (widget is Text) {
          final data = widget.data;
          // Look for any of the initial screen markers
          return data == 'Track Your Wealth' ||
              data == 'Dashboard' ||
              data == 'Wealth Overview' ||
              data == 'TrueLedger' ||
              data == 'Initializing...' ||
              data?.contains('Welcome') == true;
        }
        return false;
      });

      if (finder.evaluate().isNotEmpty) {
        debugPrint(
            'INTEGRATION_TEST_LOG: Found target widget: ${finder.toString()}');
        found = true;
        break;
      }

      if (stopwatch.elapsed.inSeconds % 10 == 0) {
        debugPrint(
            'INTEGRATION_TEST_LOG: Still polling... (${stopwatch.elapsed.inSeconds}s)');
      }
    }

    if (!found) {
      debugPrint(
          'INTEGRATION_TEST_LOG: Test polling timed out. Dumping widget tree for diagnosis:');
      try {
        debugDumpApp();
      } catch (e) {
        debugPrint('INTEGRATION_TEST_LOG: Failed to dump widget tree: $e');
      }
    }

    expect(found, isTrue,
        reason:
            "App failed to show initial screen within ${timeout.inSeconds}s");

    debugPrint('INTEGRATION_TEST_LOG: Finalizing test...');
    // 6. Finalization safety
    await tester.pump(const Duration(seconds: 1));
    await Future.delayed(const Duration(seconds: 1));
    debugPrint('INTEGRATION_TEST_LOG: Test completed successfully.');
  });
}
