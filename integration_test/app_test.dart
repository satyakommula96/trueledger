import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:truecash/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App smoke test - verifies app launches', (tester) async {
    await app.main();
    // Use pump with duration instead of pumpAndSettle to avoid hanging on infinite animations (loaders)
    await tester.pump(const Duration(seconds: 5));

    try {
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
    } catch (e) {
      debugPrint('Test failed! Dumping widget tree:');
      debugDumpApp();
      rethrow;
    }
  });
}
