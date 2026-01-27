import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/budget_section.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/providers/usecase_providers.dart';
import 'package:trueledger/domain/usecases/budget_usecases.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockFinancialRepository extends Mock implements IFinancialRepository {}

class MockUpdateBudgetUseCase extends Mock implements UpdateBudgetUseCase {}

class MockDeleteBudgetUseCase extends Mock implements DeleteBudgetUseCase {}

void main() {
  late MockSharedPreferences mockPrefs;
  late MockFinancialRepository mockRepo;
  late MockUpdateBudgetUseCase mockUpdateBudget;
  late MockDeleteBudgetUseCase mockDeleteBudget;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    mockRepo = MockFinancialRepository();
    mockUpdateBudget = MockUpdateBudgetUseCase();
    mockDeleteBudget = MockDeleteBudgetUseCase();

    when(() => mockPrefs.getBool('is_private_mode')).thenReturn(false);
    when(() => mockPrefs.getString('currency')).thenReturn('USD');
    CurrencyFormatter.currencyNotifier.value = 'USD';
  });

  Widget createWidgetUnderTest({
    required List<Budget> budgets,
    required VoidCallback onLoad,
  }) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        financialRepositoryProvider.overrideWithValue(mockRepo),
        updateBudgetUseCaseProvider.overrideWithValue(mockUpdateBudget),
        deleteBudgetUseCaseProvider.overrideWithValue(mockDeleteBudget),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: SingleChildScrollView(
            child: BudgetSection(
              budgets: budgets,
              semantic: AppTheme.darkColors,
              onLoad: onLoad,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders empty state', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(
      budgets: [],
      onLoad: () {},
    ));

    expect(find.text('No active budgets'), findsOneWidget);
  });

  testWidgets('renders budget items', (WidgetTester tester) async {
    final budgets = [
      Budget(id: 1, category: 'Food', monthlyLimit: 500, spent: 200),
      Budget(id: 2, category: 'Rent', monthlyLimit: 1000, spent: 1200),
    ];

    await tester.pumpWidget(createWidgetUnderTest(
      budgets: budgets,
      onLoad: () {},
    ));

    // Wait for animations
    await tester.pumpAndSettle();

    expect(find.text('FOOD'), findsOneWidget);
    expect(find.text('RENT'), findsOneWidget);
    expect(find.textContaining('200'), findsOneWidget);
    expect(find.textContaining('500'), findsOneWidget);
    // 1200 might be formatted as 1.2K
    expect(find.textContaining('1.2K'), findsOneWidget);

    // Rent is overspent, should have overspent color
    final rentText = tester.widget<Text>(find.textContaining('1.2K'));
    expect(rentText.style?.color, AppTheme.darkColors.overspent);
  });

  testWidgets('navigates to EditBudgetScreen on tap',
      (WidgetTester tester) async {
    final budgets = [
      Budget(id: 1, category: 'Food', monthlyLimit: 500, spent: 200),
    ];
    int onLoadCalledCount = 0;

    await tester.pumpWidget(createWidgetUnderTest(
      budgets: budgets,
      onLoad: () => onLoadCalledCount++,
    ));

    await tester.pumpAndSettle();

    await tester.tap(find.text('FOOD'));
    await tester.pumpAndSettle();

    // Verify EditBudgetScreen title
    expect(find.textContaining('Food'), findsWidgets);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(onLoadCalledCount, 1);
  });
}
