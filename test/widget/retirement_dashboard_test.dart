import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/providers/retirement_provider.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';
import 'package:trueledger/presentation/screens/retirement/retirement_dashboard.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/constants/widget_keys.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import '../helpers/currency_test_helpers.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

class MockPrivacyNotifier extends PrivacyNotifier {
  final bool initialValue;
  MockPrivacyNotifier(this.initialValue);
  @override
  bool build() => initialValue;
}

void main() {
  late MockFinancialRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(
        RetirementAccount(id: 0, name: '', balance: 0, lastUpdated: ''));
  });

  setUp(() {
    mockRepo = MockFinancialRepository();
    CurrencyFormatter.currencyNotifier.value = '₹';
  });

  // Standardized stub for RetirementData to avoid mixed mocking inconsistencies
  RetirementData createRetirementStub({List<RetirementAccount>? accounts}) {
    final list = accounts ?? [];
    return RetirementData(
      accounts: list,
      totalCorpus: list.fold<double>(0, (sum, item) => sum + item.balance),
      projections: [
        {'year': 2024, 'balance': 100000.0, 'age': 30},
        {'year': 2025, 'balance': 200000.0, 'age': 31},
      ],
    );
  }

  Widget createTestWidget({
    RetirementData? data,
    bool isPrivate = false,
  }) {
    final retirementData = data ?? createRetirementStub();

    return ProviderScope(
      overrides: [
        financialRepositoryProvider.overrideWithValue(mockRepo),
        retirementProvider.overrideWith((ref) => retirementData),
        privacyProvider.overrideWith(() => MockPrivacyNotifier(isPrivate)),
      ],
      child: MaterialApp(
        theme: ThemeData(extensions: [AppTheme.darkColors]),
        home: const RetirementDashboard(),
      ),
    );
  }

  group('RetirementDashboard Tests', () {
    testWidgets('displays retirement dashboard with data using keys',
        (tester) async {
      final accounts = [
        RetirementAccount(
            id: 1, name: 'EPF', balance: 500000, lastUpdated: '2023-10-01'),
        RetirementAccount(
            id: 2, name: 'NPS', balance: 200000, lastUpdated: '2023-10-01'),
      ];

      final stub = createRetirementStub(accounts: accounts);

      await tester.pumpWidget(createTestWidget(data: stub));
      await tester.pumpAndSettle();

      // Verify structural components via keys
      expect(find.byKey(WidgetKeys.retirementCorpusValue), findsOneWidget);
      expect(find.byKey(WidgetKeys.retirementAccountItem(1)), findsOneWidget);
      expect(find.byKey(WidgetKeys.retirementAccountItem(2)), findsOneWidget);

      // Verify data via currency helper
      expect(findFormattedAmount(700000), findsOneWidget);

      expect(find.text('EPF'), findsOneWidget);
      expect(find.text('NPS'), findsOneWidget);
    });

    testWidgets('handles empty retirement data', (tester) async {
      final stub = createRetirementStub(accounts: []);

      await tester.pumpWidget(createTestWidget(data: stub));
      await tester.pumpAndSettle();

      expect(find.byKey(WidgetKeys.retirementCorpusValue), findsOneWidget);
      expect(findFormattedAmount(0), findsAtLeastNWidgets(1));
    });

    testWidgets('shows projections section using keys when available',
        (tester) async {
      final stub = createRetirementStub(accounts: [
        RetirementAccount(
            id: 1, name: 'EPF', balance: 100000, lastUpdated: '2023-10-01'),
      ]);

      await tester.pumpWidget(createTestWidget(data: stub));
      await tester.pumpAndSettle();

      expect(find.text('FUTURE WEALTH'), findsOneWidget);
      // We check for some data in the projection chart or labels
      expect(find.textContaining('YEARS'), findsOneWidget);
    });
  });
}
