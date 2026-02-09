import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/screens/goals/goals_screen.dart';
import 'package:trueledger/core/theme/theme.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockFinancialRepository mockRepo;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockRepo = MockFinancialRepository();
    mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getBool(any())).thenReturn(false);
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        financialRepositoryProvider.overrideWithValue(mockRepo),
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const GoalsScreen(),
      ),
    );
  }

  group('GoalsScreen', () {
    testWidgets('displays loading indicator initially',
        (WidgetTester tester) async {
      when(() => mockRepo.getSavingGoals()).thenAnswer((_) => Future.delayed(
            const Duration(milliseconds: 50),
            () => [],
          ));

      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Trigger first frame

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the test properly
      await tester.pumpAndSettle();
    });

    testWidgets('displays empty state when no goals exist',
        (WidgetTester tester) async {
      when(() => mockRepo.getSavingGoals()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('NO GOALS YET'), findsOneWidget);
      expect(
          find.text(
              'Set your first saving goal and start building your future!'),
          findsOneWidget);
      expect(find.byIcon(Icons.flag_rounded), findsOneWidget);
    });

    testWidgets('displays goals list when goals exist',
        (WidgetTester tester) async {
      final testGoals = [
        SavingGoal(
          id: 1,
          name: 'Emergency Fund',
          targetAmount: 100000,
          currentAmount: 50000,
        ),
        SavingGoal(
          id: 2,
          name: 'Vacation',
          targetAmount: 50000,
          currentAmount: 25000,
        ),
      ];

      when(() => mockRepo.getSavingGoals()).thenAnswer((_) async => testGoals);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('EMERGENCY FUND'), findsOneWidget);
      expect(find.text('VACATION'), findsOneWidget);
      expect(find.text('YOUR GOALS'), findsOneWidget);
    });

    testWidgets('displays overall summary card with correct totals',
        (WidgetTester tester) async {
      final testGoals = [
        SavingGoal(
          id: 1,
          name: 'Car',
          targetAmount: 500000,
          currentAmount: 200000,
        ),
        SavingGoal(
          id: 2,
          name: 'House',
          targetAmount: 1000000,
          currentAmount: 300000,
        ),
      ];

      when(() => mockRepo.getSavingGoals()).thenAnswer((_) async => testGoals);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Total saved: 500000, Total target: 1500000, Progress: 33.3%
      expect(find.text('TOTAL PROGRESS'), findsOneWidget);
      expect(find.text('33.3%'), findsOneWidget);
      expect(find.text('SAVED'), findsAtLeastNWidgets(1));
      expect(find.text('TARGET'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays goal completion indicator for completed goals',
        (WidgetTester tester) async {
      final testGoals = [
        SavingGoal(
          id: 1,
          name: 'Laptop',
          targetAmount: 80000,
          currentAmount: 80000,
        ),
      ];

      when(() => mockRepo.getSavingGoals()).thenAnswer((_) async => testGoals);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('LAPTOP'), findsOneWidget);
      expect(find.text('GOAL ACHIEVED! 🎉'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('displays remaining amount for incomplete goals',
        (WidgetTester tester) async {
      final testGoals = [
        SavingGoal(
          id: 1,
          name: 'Bike',
          targetAmount: 100000,
          currentAmount: 30000,
        ),
      ];

      when(() => mockRepo.getSavingGoals()).thenAnswer((_) async => testGoals);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('BIKE'), findsOneWidget);
      expect(find.text('30%'), findsOneWidget);
      // Should show remaining amount (70000)
      expect(find.textContaining('TO GO'), findsOneWidget);
    });

    testWidgets('shows floating action button to add new goal',
        (WidgetTester tester) async {
      when(() => mockRepo.getSavingGoals()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    });

    testWidgets('displays correct progress percentage for partial completion',
        (WidgetTester tester) async {
      final testGoals = [
        SavingGoal(
          id: 1,
          name: 'Camera',
          targetAmount: 50000,
          currentAmount: 37500, // 75% complete
        ),
      ];

      when(() => mockRepo.getSavingGoals()).thenAnswer((_) async => testGoals);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('displays multiple goals with different progress levels',
        (WidgetTester tester) async {
      final testGoals = [
        SavingGoal(
          id: 1,
          name: 'Goal 1',
          targetAmount: 100000,
          currentAmount: 10000, // 10%
        ),
        SavingGoal(
          id: 2,
          name: 'Goal 2',
          targetAmount: 100000,
          currentAmount: 60000, // 60%
        ),
        SavingGoal(
          id: 3,
          name: 'Goal 3',
          targetAmount: 100000,
          currentAmount: 100000, // 100%
        ),
      ];

      when(() => mockRepo.getSavingGoals()).thenAnswer((_) async => testGoals);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('GOAL 1'), findsOneWidget);
      expect(find.text('GOAL 2'), findsOneWidget);

      // Scroll to see Goal 3
      await tester.dragUntilVisible(
        find.text('GOAL 3'),
        find.byType(ListView),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      expect(find.text('GOAL 3'), findsOneWidget);
      expect(find.text('10%'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('handles zero target amount gracefully',
        (WidgetTester tester) async {
      final testGoals = [
        SavingGoal(
          id: 1,
          name: 'Invalid Goal',
          targetAmount: 0,
          currentAmount: 0,
        ),
      ];

      when(() => mockRepo.getSavingGoals()).thenAnswer((_) async => testGoals);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should not crash, should show 0%
      expect(find.text('INVALID GOAL'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('calculates overall progress correctly with multiple goals',
        (WidgetTester tester) async {
      final testGoals = [
        SavingGoal(
          id: 1,
          name: 'Goal A',
          targetAmount: 100000,
          currentAmount: 50000,
        ),
        SavingGoal(
          id: 2,
          name: 'Goal B',
          targetAmount: 100000,
          currentAmount: 50000,
        ),
      ];

      when(() => mockRepo.getSavingGoals()).thenAnswer((_) async => testGoals);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Total: 100k saved out of 200k target = 50%
      expect(find.text('50.0%'), findsOneWidget);
    });
  });
}
