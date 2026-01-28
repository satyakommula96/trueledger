import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/presentation/screens/net_worth/net_worth_details.dart';
import 'package:trueledger/presentation/screens/transactions/add_expense.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/core/theme/theme.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockFinancialRepository mockRepo;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockRepo = MockFinancialRepository();
    mockPrefs = MockSharedPreferences();

    when(() => mockRepo.getAllValues(any())).thenAnswer((_) async => []);
    when(() => mockRepo.getCreditCards()).thenAnswer((_) async => []);
    when(() => mockRepo.getLoans()).thenAnswer((_) async => []);
    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
  });

  Widget createWidget(NetWorthDetailsScreen screen) {
    return ProviderScope(
      overrides: [
        financialRepositoryProvider.overrideWithValue(mockRepo),
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: screen,
      ),
    );
  }

  group('NetWorthDetailsScreen Navigation Tests', () {
    testWidgets(
        'Tapping add on Assets view opens AddExpense with restricted type',
        (tester) async {
      await tester.pumpWidget(createWidget(
          const NetWorthDetailsScreen(viewMode: NetWorthView.assets)));
      await tester.pump(); // Trigger initState load
      await tester.pumpAndSettle(); // Wait for animation and data

      // Default view is Assets. Tap first add icon in headers.
      final addIcon = find.byIcon(Icons.add_circle_outline_rounded);
      expect(addIcon, findsWidgets);

      await tester.tap(addIcon.first);
      await tester.pumpAndSettle();

      expect(find.byType(AddExpense), findsOneWidget);
      expect(find.text('NEW INVESTMENT'), findsOneWidget);
      expect(find.text('ENTRY TYPE'), findsNothing);
      expect(find.text('MUTUAL FUNDS'), findsOneWidget);
    });
  });
}
