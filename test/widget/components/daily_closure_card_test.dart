import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/daily_closure_card.dart';
import 'package:trueledger/core/theme/theme.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  final semantic = AppTheme.darkColors;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getBool(any())).thenReturn(false);
    when(() => mockPrefs.getString(any())).thenReturn(null);
  });

  group('DailyClosureCard Widget Tests', () {
    testWidgets('renders when forceShow is true', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: DailyClosureCard(
                transactionCount: 3,
                todaySpend: 500,
                dailyBudget: 1000,
                semantic: semantic,
                forceShow: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("DAY CLOSURE"), findsOneWidget);
      expect(find.text("Review your day"), findsOneWidget);
      expect(find.text("You logged 3 expenses today."), findsOneWidget);
    });

    testWidgets('renders empty state when no transactions', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: DailyClosureCard(
                transactionCount: 0,
                todaySpend: 0,
                dailyBudget: 1000,
                semantic: semantic,
                forceShow: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("DAY CLOSURE"), findsOneWidget);
      expect(find.text("No expenses today?"), findsOneWidget);
      expect(find.textContaining("Did you forget to log something?"),
          findsOneWidget);
    });
  });
}
