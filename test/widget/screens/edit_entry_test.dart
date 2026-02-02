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

class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  late MockFinancialRepository mockRepo;

  setUp(() {
    mockRepo = MockFinancialRepository();
    CurrencyFormatter.currencyNotifier.value = '₹';
  });

  testWidgets('EditEntryScreen renders initial values',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final item = LedgerItem(
        id: 1, type: 'Variable', label: 'Food', amount: 50, date: '2026-02-01');

    when(() => mockRepo.getCategories(any())).thenAnswer((_) async => []);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          financialRepositoryProvider.overrideWithValue(mockRepo),
          sharedPreferencesProvider.overrideWithValue(prefs),
          dashboardProvider
              .overrideWith((ref) async => throw UnimplementedError()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: EditEntryScreen(entry: item),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('EDIT VARIABLE'), findsOneWidget);
    expect(find.widgetWithText(TextField, '50'), findsOneWidget);
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          financialRepositoryProvider.overrideWithValue(mockRepo),
          sharedPreferencesProvider.overrideWithValue(prefs),
          dashboardProvider
              .overrideWith((ref) => Future.value(null as dynamic)),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: EditEntryScreen(entry: item),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, '50'), '100');
    await tester.tap(find.text('UPDATE ENTRY'));

    // SnackBar visibility depends on timing and tree state
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    verify(() => mockRepo.updateEntry('Variable', 1, any())).called(1);

    // Use find.textContaining or find.text(..., skipOffstage: false)
    expect(find.textContaining('updated'), findsWidgets);

    await tester.pumpAndSettle();
    expect(find.byType(EditEntryScreen), findsNothing);
  });

  testWidgets('EditEntryScreen deletes entry', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final item = LedgerItem(
        id: 1, type: 'Variable', label: 'Food', amount: 50, date: '2026-02-01');

    when(() => mockRepo.getCategories(any())).thenAnswer((_) async => []);
    when(() => mockRepo.deleteItem(any(), any())).thenAnswer((_) async => {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          financialRepositoryProvider.overrideWithValue(mockRepo),
          sharedPreferencesProvider.overrideWithValue(prefs),
          dashboardProvider
              .overrideWith((ref) => Future.value(null as dynamic)),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: EditEntryScreen(entry: item),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('DELETE ITEM?'), findsOneWidget);
    await tester.tap(find.text('DELETE'));
    await tester
        .pumpAndSettle(); // Allow time for the dialog to close and navigation to occur

    verify(() => mockRepo.deleteItem('variable_expenses', 1)).called(1);
  });
}
