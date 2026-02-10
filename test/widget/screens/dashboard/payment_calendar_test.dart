import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/payment_calendar.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:intl/intl.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  late MockFinancialRepository mockRepo;

  setUp(() {
    mockRepo = MockFinancialRepository();

    final emptySummary = MonthlySummary(
      totalIncome: 0,
      totalFixed: 0,
      totalVariable: 0,
      totalSubscriptions: 0,
      totalInvestments: 0,
    );
    when(() => mockRepo.getMonthlySummary())
        .thenAnswer((_) async => emptySummary);
    when(() => mockRepo.getPaidBillLabels(any())).thenAnswer((_) async => []);
  });

  Widget createWidgetUnderTest(List<Map<String, dynamic>> bills) {
    return ProviderScope(
      overrides: [
        financialRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: SingleChildScrollView(
            child: PaymentCalendar(
              bills: bills,
              semantic: AppTheme.darkColors,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('PaymentCalendar renders and handles empty bills',
      (tester) async {
    await tester.pumpWidget(createWidgetUnderTest([]));
    await tester.pumpAndSettle();

    final monthYear =
        DateFormat('MMMM yyyy').format(DateTime.now()).toUpperCase();
    expect(find.text(monthYear), findsOneWidget);
    expect(find.text('TOTAL DUE'), findsOneWidget);
    expect(find.text('₹0'), findsNWidgets(2)); // Total Due and Paid
  });

  testWidgets('PaymentCalendar shows bill events and opens details',
      (tester) async {
    final now = DateTime.now();
    final today = DateFormat('dd-MM-yyyy').format(now);

    final bills = [
      {
        'id': '1',
        'title': 'Rent',
        'amount': 5000.0,
        'due': today,
        'type': 'LOAN EMI',
        'isRecurring': false,
      }
    ];

    await tester.pumpWidget(createWidgetUnderTest(bills));
    await tester.pumpAndSettle();

    // Verify day has an event (dot or circle)
    expect(find.text('${now.day}'), findsOneWidget);

    // Tap on the day to open details
    await tester.tap(find.text('${now.day}'));
    await tester.pumpAndSettle();

    expect(find.text('Rent'), findsOneWidget);
    expect(find.text('₹5,000'), findsOneWidget);
    expect(find.text('MARK PAID'), findsOneWidget);
  });

  testWidgets('PaymentCalendar handles marking as paid', (tester) async {
    final now = DateTime.now();
    final today = DateFormat('dd-MM-yyyy').format(now);

    final bills = [
      {
        'id': '1',
        'title': 'Gym',
        'amount': 1000.0,
        'due': today,
        'type': 'SUBSCRIPTION',
        'isRecurring': false,
      }
    ];

    when(() => mockRepo.addEntry(any(), any(), any(), any(), any(),
        tags: any(named: 'tags'))).thenAnswer((_) async => {});

    await tester.pumpWidget(createWidgetUnderTest(bills));
    await tester.pumpAndSettle();

    await tester.tap(find.text('${now.day}'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('MARK PAID'));
    await tester.pumpAndSettle(); // Close sheet
    await tester.pump(); // For snackbar

    verify(() => mockRepo.addEntry(
          'Variable',
          1000.0,
          'Subscription',
          any(),
          any(),
          tags: any(named: 'tags'),
        )).called(1);

    expect(find.text('Gym marked as paid'), findsOneWidget);
  });

  testWidgets('PaymentCalendar navigation changes month', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest([]));
    await tester.pumpAndSettle();

    final now = DateTime.now();
    final currentMonth = DateFormat('MMMM yyyy').format(now).toUpperCase();
    expect(find.text(currentMonth), findsOneWidget);

    // Go to previous month
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    final prevMonthDate = DateTime(now.year, now.month - 1);
    final prevMonth =
        DateFormat('MMMM yyyy').format(prevMonthDate).toUpperCase();
    expect(find.text(prevMonth), findsOneWidget);
  });
}
