import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/daily_closure_card.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/providers/day_closure_provider.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

class MockDayClosureNotifier extends DayClosureNotifier {
  final bool initialValue;
  MockDayClosureNotifier(this.initialValue);

  @override
  bool build() => initialValue;
}

void main() {
  late MockFinancialRepository mockRepo;

  setUp(() {
    mockRepo = MockFinancialRepository();
  });

  testWidgets('DailyClosureCard shows content when forceShow is true',
      (WidgetTester tester) async {
    // 1. Setup Repo Mock
    when(() => mockRepo.getTodayTransactionCount()).thenAnswer((_) async => 5);
    when(() => mockRepo.getTodaySpend()).thenAnswer((_) async => 1000);

    // 2. Build Widget
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          financialRepositoryProvider.overrideWithValue(mockRepo),
          dayClosureProvider.overrideWith(() => MockDayClosureNotifier(false)),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: DailyClosureCard(
              transactionCount: 5,
              todaySpend: 1000,
              dailyBudget: 2000,
              semantic: AppTheme.lightColors,
              forceShow: true,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("DAY RITUAL"), findsOneWidget);
    expect(find.text("Daily Review"), findsOneWidget);
    expect(find.textContaining("5 entries"), findsOneWidget);
    expect(find.text("Finish Daily Review"), findsOneWidget);
  });

  testWidgets('DailyClosureCard shows success state when closed',
      (WidgetTester tester) async {
    // We need to override dayClosureProvider to true
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          financialRepositoryProvider.overrideWithValue(mockRepo),
          dayClosureProvider.overrideWith(() => MockDayClosureNotifier(true)),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: DailyClosureCard(
              transactionCount: 5,
              todaySpend: 1000,
              dailyBudget: 2000,
              semantic: AppTheme.lightColors,
              forceShow: true,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining("Ritual complete. Rest well."), findsOneWidget);
  });
}
