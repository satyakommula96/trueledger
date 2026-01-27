import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/components/hover_wrapper.dart';
import 'package:trueledger/core/theme/theme.dart';

void main() {
  Widget createTestWidget(Widget child,
      {TargetPlatform platform = TargetPlatform.linux}) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.darkTheme.copyWith(platform: platform),
        home: Scaffold(body: child),
      ),
    );
  }

  group('HoverWrapper', () {
    testWidgets('renders child correctly', (tester) async {
      await tester.pumpWidget(createTestWidget(
        HoverWrapper(
          child: const Text('Test Child'),
        ),
      ));

      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('onTap callback works on desktop', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(createTestWidget(
        HoverWrapper(
          onTap: () => tapped = true,
          child: const Text('Tap Me'),
        ),
        platform: TargetPlatform.linux,
      ));

      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('onTap callback works on mobile (iOS)', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(createTestWidget(
        HoverWrapper(
          onTap: () => tapped = true,
          child: const Text('Tap Me'),
        ),
        platform: TargetPlatform.iOS,
      ));

      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('onTap callback works on mobile (Android)', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(createTestWidget(
        HoverWrapper(
          onTap: () => tapped = true,
          child: const Text('Tap Me'),
        ),
        platform: TargetPlatform.android,
      ));

      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('child is wrapped in GestureDetector on mobile',
        (tester) async {
      await tester.pumpWidget(createTestWidget(
        HoverWrapper(
          child: const Text('Mobile Test'),
        ),
        platform: TargetPlatform.iOS,
      ));

      // On mobile, HoverWrapper should render without MouseRegion
      // On mobile, HoverWrapper should render with GestureDetector
      expect(find.byType(GestureDetector), findsAtLeastNWidgets(1));
    });
  });
}
