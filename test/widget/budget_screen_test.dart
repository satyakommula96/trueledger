import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/screens/budget/budget_screen.dart';
import '../helpers/test_wrapper.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockFinancialRepository mockRepo;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockRepo = MockFinancialRepository();
    mockPrefs = MockSharedPreferences();

    // Register fallbacks for mocktail
    registerFallbackValue(const Duration(seconds: 1));

    when(() => mockPrefs.getBool(any())).thenReturn(false);
    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.getDouble(any())).thenReturn(null);
    when(() => mockPrefs.getInt(any())).thenReturn(null);
    when(() => mockPrefs.getStringList(any())).thenReturn(null);
    when(() => mockPrefs.setBool(any(), any())).thenAnswer((_) async => true);

    // Default mocks to avoid unhandled calls
    when(() => mockRepo.getBudgets()).thenAnswer((_) async => <Budget>[]);
    when(() => mockRepo.getSpendingTrend())
        .thenAnswer((_) async => <FinancialTrend>[]);
    when(() => mockRepo.getCategorySpending())
        .thenAnswer((_) async => <CategorySpending>[]);
    when(() => mockRepo.getCategories(any()))
        .thenAnswer((_) async => <TransactionCategory>[]);
  });

  Widget createTestWidget() {
    return wrapWidget(
      const BudgetScreen(),
      overrides: [
        financialRepositoryProvider.overrideWithValue(mockRepo),
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
      ],
    );
  }

  // Bounded settle: avoids infinite animation loops from flutter_animate
  Future<void> pumpSettle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 2));
  }

  group('BudgetScreen', () {
    testWidgets('displays loading state', (tester) async {
      when(() => mockRepo.getBudgets()).thenAnswer((_) => Future.delayed(
            const Duration(milliseconds: 50),
            () => <Budget>[],
          ));

      await tester.pumpWidget(createTestWidget());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
      await pumpSettle(tester);
    });

    testWidgets('displays budgets and spending limits', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;

      final testBudgets = [
        Budget(id: 1, category: 'Food', monthlyLimit: 5000, spent: 2000),
        Budget(id: 2, category: 'Rent', monthlyLimit: 15000, spent: 15000),
      ];

      when(() => mockRepo.getBudgets()).thenAnswer((_) async => testBudgets);

      await tester.pumpWidget(createTestWidget());
      // Pump microtasks to resolve FutureProvider
      await tester.pump();
      await tester.pump(Duration.zero);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(seconds: 3));

      // Should no longer be loading
      expect(find.byType(CircularProgressIndicator), findsNothing);
      // l10n.budgets = 'Budgets' — shown in SliverAppBar title
      expect(find.text('Budgets'), findsAtLeastNWidgets(1));
      // l10n.liveTracking = 'Live Tracking' — shown in AppleSectionHeader
      expect(find.text('Live Tracking'), findsOneWidget);
      // Budget category names are uppercased in BudgetSection
      expect(find.text('FOOD'), findsOneWidget);
      expect(find.text('RENT'), findsOneWidget);
      tester.view.resetPhysicalSize();
    });

    testWidgets('navigates to AddBudgetScreen when FAB is pressed',
        (tester) async {
      when(() => mockRepo.getBudgets()).thenAnswer((_) async => <Budget>[]);

      await tester.pumpWidget(createTestWidget());
      await pumpSettle(tester);

      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);

      await tester.tap(fab, warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await pumpSettle(tester);

      expect(find.text('CATEGORY IDENTIFIER'), findsOneWidget);
    });
  });
}
