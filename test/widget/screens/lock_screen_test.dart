import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/screens/startup/lock_screen.dart';
import 'package:flutter/services.dart';

void main() {
  const MethodChannel channel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  final Map<String, String> storage = {};

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'read') {
        final Map args = methodCall.arguments as Map;
        return storage[args['key']];
      }
      if (methodCall.method == 'write') {
        final Map args = methodCall.arguments as Map;
        storage[args['key']] = args['value'];
        return null;
      }
      if (methodCall.method == 'containsKey') {
        final Map args = methodCall.arguments as Map;
        return storage.containsKey(args['key']);
      }
      return null;
    });
    storage.clear();
  });

  testWidgets('LockScreen UI toggles PIN visibility', (tester) async {
    // Setup PIN
    storage['app_pin'] = '1234';

    // Set a realistic screen size
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(
        home: LockScreen(),
      ),
    ));

    // Wait for _loadPinLength
    await tester.pumpAndSettle();

    // Verify Eye Icon exists
    final eyeIcon = find.byIcon(Icons.visibility_rounded);
    expect(eyeIcon, findsOneWidget);

    // Type a number: '5'
    await tester.tap(find.text('5'));
    await tester.pump();

    // Verify '5' is NOT shown in the display (only on the keypad)
    // The keypad '5' exists.
    // The display '5' should not exist yet.
    // To distinguish, keypad text is size 28. Display text is size 24.
    // But easier: finding text '5' should find exactly 1 widget (the keypad button).
    expect(find.text('5'), findsOneWidget);

    // Toggle Eye Screen
    await tester.tap(eyeIcon);
    await tester.pump();

    // Verify Eye Icon changed
    expect(find.byIcon(Icons.visibility_off_rounded), findsOneWidget);

    // Now '5' should be visible in the display area.
    // So we should find 2 instances of '5'.
    expect(find.text('5'), findsNWidgets(2));

    // Type another number '2'
    await tester.tap(find.text('2'));
    await tester.pump();

    // Should find two '2's (one keypad, one display)
    expect(find.text('2'), findsNWidgets(2));

    // Toggle Eye Back
    await tester.tap(find.byIcon(Icons.visibility_off_rounded));
    await tester.pump();

    // Should find only one '5' and one '2' (hidden again)
    expect(find.text('5'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });
}
