import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/daily_closure_card.dart';
import 'package:trueledger/core/theme/theme.dart';
import '../../helpers/test_wrapper.dart';

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
        wrapWidget(
          DailyClosureCard(
            transactionCount: 3,
            todaySpend: 500,
            dailyBudget: 1000,
            semantic: semantic,
            forceShow: true,
          ),
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("DAY RITUAL"), findsOneWidget);
      expect(find.text("Daily Review"), findsOneWidget);
      expect(find.text("You've logged 3 entries today."), findsOneWidget);
    });

    testWidgets('renders empty state when no transactions', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          DailyClosureCard(
            transactionCount: 0,
            todaySpend: 0,
            dailyBudget: 1000,
            semantic: semantic,
            forceShow: true,
          ),
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("DAY RITUAL"), findsOneWidget);
      expect(find.text("Still Day?"), findsOneWidget);
      expect(
          find.textContaining("No transactions logged today."), findsOneWidget);
    });
  });
}
