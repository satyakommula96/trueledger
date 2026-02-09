import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/providers/dashboard_provider.dart';
import 'package:trueledger/presentation/screens/transactions/edit_entry.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/core/constants/widget_keys.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  late MockFinancialRepository mockRepo;

  setUp(() {
    mockRepo = MockFinancialRepository();
    CurrencyFormatter.currencyNotifier.value = '₹';
  });

  Widget createTestWidget(LedgerItem item, SharedPreferences prefs) {
    return ProviderScope(
      overrides: [
        financialRepositoryProvider.overrideWithValue(mockRepo),
        sharedPreferencesProvider.overrideWithValue(prefs),
        dashboardProvider.overrideWith((ref) => Future.value(null as dynamic)),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: EditEntryScreen(entry: item),
      ),
    );
  }

  testWidgets('EditEntryScreen renders initial values',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final item = LedgerItem(
        id: 1, type: 'Variable', label: 'Food', amount: 50, date: '2026-02-01');

    when(() => mockRepo.getCategories(any())).thenAnswer((_) async => []);

    await tester.pumpWidget(createTestWidget(item, prefs));
    await tester.pumpAndSettle();

    expect(find.text('EDIT VARIABLE'), findsOneWidget);
    expect(find.widgetWithText(TextField, '50.0'), findsAtLeastNWidgets(1));
    expect(find.widgetWithText(TextField, 'Food'), findsOneWidget);
  });

  testWidgets('EditEntryScreen updates entry', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final item = LedgerItem(
        id: 1, type: 'Variable', label: 'Food', amount: 50, date: '2026-02-01');

    when(() => mockRepo.getCategories(any())).thenAnswer((_) async => []);
    when(() => mockRepo.updateEntry(any(), any(), any()))
        .thenAnswer((_) async => {});

    await tester.pumpWidget(createTestWidget(item, prefs));
    await tester.pumpAndSettle();

    // Use key for save button
    final amountField = find.widgetWithText(TextField, '50.0').first;
    await tester.enterText(amountField, '100');

    final saveButton = find.byKey(WidgetKeys.saveButton);
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    verify(() => mockRepo.updateEntry('Variable', 1, any())).called(1);
    expect(find.byType(EditEntryScreen), findsNothing);
  });

  testWidgets('EditEntryScreen delete flow requires confirmation',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final item = LedgerItem(
        id: 1, type: 'Variable', label: 'Food', amount: 50, date: '2026-02-01');

    when(() => mockRepo.getCategories(any())).thenAnswer((_) async => []);
    when(() => mockRepo.deleteItem(any(), any())).thenAnswer((_) async => {});

    await tester.pumpWidget(createTestWidget(item, prefs));
    await tester.pumpAndSettle();

    // 1. Tap delete button via key
    await tester.tap(find.byKey(WidgetKeys.deleteButton));
    await tester.pumpAndSettle();

    // 2. Verify dialog
    expect(find.text('DELETE ITEM?'), findsOneWidget);

    // 3. Verify no deletion yet
    verifyNever(() => mockRepo.deleteItem(any(), any()));

    // 4. Tap DELETE and verify
    await tester.tap(find.text('DELETE'));
    await tester.pumpAndSettle();

    verify(() => mockRepo.deleteItem('variable_expenses', 1)).called(1);
    expect(find.byType(EditEntryScreen), findsNothing);
  });
}
