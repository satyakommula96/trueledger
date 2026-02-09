import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/data/repositories/daily_digest_store.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/usecases/manage_daily_digest_usecase.dart';
import 'package:intl/intl.dart';

class MockDailyDigestStore extends Mock implements DailyDigestStore {}

void main() {
  late ManageDailyDigestUseCase useCase;
  late MockDailyDigestStore mockStore;

  setUp(() {
    mockStore = MockDailyDigestStore();
    useCase = ManageDailyDigestUseCase(mockStore);
  });

  group('ManageDailyDigestUseCase', () {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    test('should return ShowDigestAction when content changed (first time)',
        () async {
      when(() => mockStore.getLastDigestDate()).thenReturn(null);
      when(() => mockStore.getLastDigestCount()).thenReturn(null);
      when(() => mockStore.getLastDigestTotal()).thenReturn(null);
      when(() => mockStore.saveState(
            date: any(named: 'date'),
            count: any(named: 'count'),
            total: any(named: 'total'),
          )).thenAnswer((_) async {});

      final bills = [
        BillSummary(id: '1', name: 'Bill 1', amount: 100, type: 'BILL')
      ];

      final result = await useCase.execute(bills, AppRunContext.background);

      expect(result, isA<ShowDigestAction>());
      expect((result as ShowDigestAction).bills, bills);
      verify(() => mockStore.saveState(date: todayStr, count: 1, total: 100))
          .called(1);
    });

    test('should return NoAction when content has not changed', () async {
      when(() => mockStore.getLastDigestDate()).thenReturn(todayStr);
      when(() => mockStore.getLastDigestCount()).thenReturn(1);
      when(() => mockStore.getLastDigestTotal()).thenReturn(100);

      final bills = [
        BillSummary(id: '1', name: 'Bill 1', amount: 100, type: 'BILL')
      ];

      final result = await useCase.execute(bills, AppRunContext.coldStart);

      expect(result, isA<NoAction>());
      verifyNever(() => mockStore.saveState(
            date: any(named: 'date'),
            count: any(named: 'count'),
            total: any(named: 'total'),
          ));
    });

    test('should return CancelDigestAction when context is resume', () async {
      // Even if content changed, if we resume we should cancel
      when(() => mockStore.getLastDigestDate()).thenReturn('2026-01-01');
      when(() => mockStore.getLastDigestCount()).thenReturn(0);
      when(() => mockStore.getLastDigestTotal()).thenReturn(0);
      when(() => mockStore.saveState(
            date: any(named: 'date'),
            count: any(named: 'count'),
            total: any(named: 'total'),
          )).thenAnswer((_) async {});

      final bills = [
        BillSummary(id: '1', name: 'Bill 1', amount: 100, type: 'BILL')
      ];

      final result = await useCase.execute(bills, AppRunContext.resume);

      expect(result, isA<CancelDigestAction>());
      verify(() => mockStore.saveState(date: todayStr, count: 1, total: 100))
          .called(1);
    });

    test('should return CancelDigestAction when count becomes 0', () async {
      when(() => mockStore.getLastDigestDate()).thenReturn('2026-01-01');
      when(() => mockStore.getLastDigestCount()).thenReturn(5);
      when(() => mockStore.getLastDigestTotal()).thenReturn(500);
      when(() => mockStore.saveState(
            date: any(named: 'date'),
            count: any(named: 'count'),
            total: any(named: 'total'),
          )).thenAnswer((_) async {});

      final result = await useCase.execute([], AppRunContext.coldStart);

      expect(result, isA<CancelDigestAction>());
      verify(() => mockStore.saveState(date: todayStr, count: 0, total: 0))
          .called(1);
    });

    test(
        'should explicitly cancel and update date even if yesterday had 0 bills (date change)',
        () async {
      // Scenario: Yesterday had 0 bills (Cancel/NoAction stored). Today has 0 bills.
      // logic must still return CancelDigestAction (or act to save state)
      // so that the "lastDigestDate" is updated to today.
      // If we returned NoAction immediately without saving, the date would stay "yesterday",
      // causing "contentChanged=true" loop or stale date issues.

      when(() => mockStore.getLastDigestDate()).thenReturn('2026-01-01');
      when(() => mockStore.getLastDigestCount()).thenReturn(0);
      when(() => mockStore.getLastDigestTotal()).thenReturn(0);
      when(() => mockStore.saveState(
            date: any(named: 'date'),
            count: any(named: 'count'),
            total: any(named: 'total'),
          )).thenAnswer((_) async {});

      final result = await useCase.execute([], AppRunContext.coldStart);

      expect(result, isA<CancelDigestAction>());
      verify(() => mockStore.saveState(date: todayStr, count: 0, total: 0))
          .called(1);
    });
  });
}
