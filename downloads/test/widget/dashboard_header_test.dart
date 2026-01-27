import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/dashboard_header.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  late MockSharedPreferences mockPrefs;
  late MockFinancialRepository mockRepo;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    mockRepo = MockFinancialRepository();
    when(() => mockPrefs.getBool('is_private_mode')).thenReturn(false);
    when(() => mockPrefs.getString('user_name')).thenReturn('Test User');
    when(() => mockPrefs.setBool(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

    // For SettingsScreen if it builds
    when(() => mockRepo.getAllValues(any())).thenAnswer((_) async => []);
  });

  Widget createWidgetUnderTest({
    bool isDark = true,
    VoidCallback? onLoad,
  }) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        financialRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: MaterialApp(
        theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              DashboardHeader(
                isDark: isDark,
                onLoad: onLoad ?? () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('renders title', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Wait for animations
    await tester.pump(const Duration(seconds: 2));

    // Greeting changes based on time, but it should contain "Test User"
    expect(find.textContaining('Test User'), findsOneWidget);
    expect(find.text('TrueLedger'), findsOneWidget);
  });

  testWidgets('toggles privacy mode when visibility icon is tapped',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    // Wait for initial fade in
    await tester.pump(const Duration(seconds: 2));

    final visibilityIconFinder = find.byIcon(Icons.visibility_rounded);
    expect(visibilityIconFinder, findsOneWidget);

    await tester.tap(visibilityIconFinder);
    await tester.pumpAndSettle();

    // After toggle, it should show visibility_off
    expect(find.byIcon(Icons.visibility_off_rounded), findsOneWidget);
    verify(() => mockPrefs.setBool('is_private_mode', true)).called(1);
  });

  testWidgets('navigates to settings and calls onLoad on return',
      (WidgetTester tester) async {
    int onLoadCalledCount = 0;
    await tester
        .pumpWidget(createWidgetUnderTest(onLoad: () => onLoadCalledCount++));
    await tester.pump(const Duration(seconds: 2));

    final settingsIconFinder = find.byIcon(Icons.settings_rounded);
    expect(settingsIconFinder, findsOneWidget);

    await tester.tap(settingsIconFinder);
    // Wait for navigation animation
    await tester.pumpAndSettle();

    // Verify we are on Settings screen (or at least it pushed)
    // We can check for some text in SettingsScreen
    expect(find.text('Settings & Tools'), findsOneWidget);

    // Better: just pop
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(onLoadCalledCount, 1);
  });
}
