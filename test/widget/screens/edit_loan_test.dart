import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/screens/loans/edit_loan.dart';
import 'package:trueledger/domain/usecases/usecase_base.dart';
import '../../helpers/test_wrapper.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  late MockFinancialRepository mockRepo;

  setUp(() {
    mockRepo = MockFinancialRepository();
    registerFallbackValue(NoParams());
    when(() => mockRepo.getTransactionsForRange(any(), any()))
        .thenAnswer((_) async => []);
  });

  final tLoan = Loan(
    id: 1,
    name: 'Home Loan',
    loanType: 'Home',
    totalAmount: 1000000,
    remainingAmount: 900000,
    emi: 10000,
    interestRate: 8.5,
    dueDate: '2024-12-05',
    date: '2024-01-01',
  );

  Widget createEditLoanScreen() {
    return wrapWidget(
      EditLoanScreen(loan: tLoan),
      overrides: [
        financialRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  }

  testWidgets('Should display loan details correctly', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createEditLoanScreen());
    await tester.pumpAndSettle();

    expect(find.text('UPDATE LOAN'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Home Loan'), findsOneWidget);
    expect(find.text('8.5'), findsOneWidget);
  });

  testWidgets('Should call delete when Delete icon is pressed', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    when(() => mockRepo.deleteItem(any(), any())).thenAnswer((_) async => {});

    await tester.pumpWidget(createEditLoanScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('DELETE'));
    await tester.pumpAndSettle();

    verify(() => mockRepo.deleteItem('loans', 1)).called(1);
  });
}
