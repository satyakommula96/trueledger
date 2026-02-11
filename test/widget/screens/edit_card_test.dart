import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/core/services/notification_service.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/providers/notification_provider.dart';
import 'package:trueledger/presentation/screens/cards/edit_card.dart';
import 'package:trueledger/core/theme/theme.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late MockFinancialRepository mockRepo;
  late MockNotificationService mockNotification;

  setUp(() {
    mockRepo = MockFinancialRepository();
    mockNotification = MockNotificationService();

    registerFallbackValue(TransactionTag.transfer);
    when(() => mockNotification.init()).thenAnswer((_) async => {});
    when(() => mockRepo.getTransactionsForRange(any(), any()))
        .thenAnswer((_) async => []);
  });

  final tCard = CreditCard(
    id: 1,
    bank: 'Test Bank',
    creditLimit: 5000,
    statementBalance: 1000,
    minDue: 50,
    dueDate: '25th of month',
    statementDate: '10th of month',
  );

  Widget createEditCardScreen() {
    return ProviderScope(
      overrides: [
        financialRepositoryProvider.overrideWithValue(mockRepo),
        notificationServiceProvider.overrideWithValue(mockNotification),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: EditCreditCardScreen(card: tCard),
      ),
    );
  }

  testWidgets('Should display card details correctly', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createEditCardScreen());
    await tester.pumpAndSettle();

    expect(find.text('Edit Credit Card'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Test Bank'), findsOneWidget);
    expect(find.text('10th of month'), findsOneWidget);
  });

  testWidgets('Should call update when Update button is pressed',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    when(() => mockRepo.updateCreditCard(
            any(), any(), any(), any(), any(), any(), any(), any()))
        .thenAnswer((_) async => {});
    when(() => mockNotification.scheduleCreditCardReminder(any(), any()))
        .thenAnswer((_) async => {});

    await tester.pumpWidget(createEditCardScreen());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('UPDATE CARD'));
    await tester.tap(find.text('UPDATE CARD'));
    await tester.pumpAndSettle();

    verify(() => mockRepo.updateCreditCard(1, 'Test Bank', 5000, 1000, 50,
        '25th of month', '10th of month', 0.0)).called(1);
  });

  testWidgets('Should call delete when Delete icon is pressed and confirmed',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    when(() => mockRepo.deleteItem(any(), any())).thenAnswer((_) async => {});

    await tester.pumpWidget(createEditCardScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('Delete Card?'), findsOneWidget);

    await tester.tap(find.text('DELETE'));
    await tester.pumpAndSettle();

    verify(() => mockRepo.deleteItem('credit_cards', 1)).called(1);
  });
}
