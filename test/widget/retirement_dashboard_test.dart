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
    when(() => mockRepo.getRetirementAccounts()).thenAnswer((_) async => []);
  });

  Widget createTestWidget({
    List<RetirementAccount>? accounts,
    bool isPrivate = false,
  }) {
    final retirementData = RetirementData(
      accounts: accounts ?? [],
      totalCorpus:
          accounts?.fold<double>(0, (sum, item) => sum + item.balance) ?? 0,
      projections: [
        {'year': 2024, 'balance': 100000.0},
        {'year': 2025, 'balance': 200000.0},
      ],
    );

    return ProviderScope(
      overrides: [
        financialRepositoryProvider.overrideWithValue(mockRepo),
        retirementProvider.overrideWith((ref) => retirementData),
        privacyProvider.overrideWith(() => MockPrivacyNotifier(isPrivate)),
      ],
      child: MaterialApp(
        theme: ThemeData(
          extensions: [AppTheme.darkColors],
        ),
        home: const RetirementDashboard(),
      ),
    );
  }

  group('RetirementDashboard Tests', () {
    testWidgets('displays retirement dashboard with data', (tester) async {
      final accounts = [
        RetirementAccount(
            id: 1, name: 'EPF', balance: 500000, lastUpdated: '2023-10-01'),
        RetirementAccount(
            id: 2, name: 'NPS', balance: 200000, lastUpdated: '2023-10-01'),
      ];

      when(() => mockRepo.getRetirementAccounts())
          .thenAnswer((_) async => accounts);

      await tester.pumpWidget(createTestWidget(accounts: accounts));
      await tester.pump(); // Start loading
      await tester.pumpAndSettle();

      expect(find.text('RETIREMENT'), findsOneWidget);
      expect(find.text('TOTAL CORPUS'), findsOneWidget);
      expect(find.text('EPF'), findsOneWidget);
      expect(find.text('NPS'), findsOneWidget);

      // Check for presence of formatted amounts (approximate check)
      expect(find.textContaining('7,00,000'), findsOneWidget);
    });

    testWidgets('handles empty retirement data', (tester) async {
      when(() => mockRepo.getRetirementAccounts()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('RETIREMENT'), findsOneWidget);
      expect(find.textContaining('0'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows projections section', (tester) async {
      final accounts = [
        RetirementAccount(
            id: 1, name: 'EPF', balance: 100000, lastUpdated: '2023-10-01'),
      ];
      when(() => mockRepo.getRetirementAccounts())
          .thenAnswer((_) async => accounts);

      await tester.pumpWidget(createTestWidget(accounts: accounts));
      await tester.pumpAndSettle();

      expect(find.text('FUTURE WEALTH'), findsOneWidget);
      expect(find.textContaining('Estimated corpus at retirement'),
          findsOneWidget);
    });
    group('RetirementDashboard UI elements', () {
      testWidgets('renders all section headers', (tester) async {
        when(() => mockRepo.getRetirementAccounts())
            .thenAnswer((_) async => []);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('MY ACCOUNTS'), findsOneWidget);
        expect(find.text('FUTURE WEALTH'), findsOneWidget);
      });
    });
  });
}
