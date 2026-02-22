import 'package:intl/intl.dart';
import 'package:trueledger/data/repositories/daily_digest_store.dart';
import 'package:trueledger/domain/models/models.dart';

/// Represents the context in which the digest logic is being evaluated.
/// Decouples domain logic from Flutter's AppLifecycleState.
enum AppRunContext {
  coldStart,
  resume,
  background,
}

/// Represents the intended action for the Daily Bill Digest.
sealed class DailyDigestAction {
  const DailyDigestAction();
}

class ShowDigestAction extends DailyDigestAction {
  final List<BillSummary> bills;
  const ShowDigestAction(this.bills);
}

class CancelDigestAction extends DailyDigestAction {
  const CancelDigestAction();
}

class NoAction extends DailyDigestAction {
  const NoAction();
}

class DigestActions {
  final DailyDigestAction todayAction;
  final DailyDigestAction tomorrowAction;
  const DigestActions({
    required this.todayAction,
    required this.tomorrowAction,
  });
}

/// Use Case to manage the logic of the Daily Bill Digest.
///
/// IMPORTANT:
/// This use case is safe to be invoked from:
/// - foreground reactive providers
/// - background workers (future)
///
/// Do NOT schedule notifications outside this logic,
/// or duplicate notifications will occur.
class ManageDailyDigestUseCase {
  final DailyDigestStore _store;

  ManageDailyDigestUseCase(this._store);

  /// Decides whether to show, update, or cancel a notification.
  ///
  /// CRITICAL WARNING: If background task scheduling or platform-specific alarms
  /// are added in the future to support "guaranteed morning delivery" without opening the app,
  /// this logic MUST be shared or coordinated with that worker to
  /// prevent double-notifications or conflicting tray updates.
  Future<DigestActions> execute(
    List<BillSummary> billsDueToday,
    List<BillSummary> billsDueTomorrow,
    AppRunContext runContext,
  ) async {
    final todayAction = await _evaluateToday(billsDueToday, runContext);
    final tomorrowAction =
        await _evaluateTomorrow(billsDueTomorrow, runContext);

    return DigestActions(
      todayAction: todayAction,
      tomorrowAction: tomorrowAction,
    );
  }

  Future<DailyDigestAction> _evaluateToday(
    List<BillSummary> billsDueToday,
    AppRunContext runContext,
  ) async {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    final lastDigestDate = _store.getLastDigestDate();
    final lastCount = _store.getLastDigestCount();
    final lastTotal = _store.getLastDigestTotal();

    final currentCount = billsDueToday.length;
    final currentTotal = billsDueToday.fold(0.0, (sum, b) => sum + b.amount);

    final bool contentChanged = (lastCount != currentCount) ||
        (lastTotal != currentTotal) ||
        (lastDigestDate != todayStr);

    if (!contentChanged) {
      return const NoAction();
    }

    final bool shouldCancel = currentCount == 0 ||
        runContext == AppRunContext.resume ||
        runContext == AppRunContext.coldStart;

    if (shouldCancel) {
      await _store.saveState(
        date: todayStr,
        count: currentCount,
        total: currentTotal,
      );
      return const CancelDigestAction();
    }

    if (currentCount > 0) {
      await _store.saveState(
        date: todayStr,
        count: currentCount,
        total: currentTotal,
      );
      return ShowDigestAction(billsDueToday);
    }

    return const NoAction();
  }

  Future<DailyDigestAction> _evaluateTomorrow(
    List<BillSummary> billsDueTomorrow,
    AppRunContext runContext,
  ) async {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    final lastDigestDate = _store.getTomorrowLastDigestDate();
    final lastCount = _store.getTomorrowLastDigestCount();
    final lastTotal = _store.getTomorrowLastDigestTotal();

    final currentCount = billsDueTomorrow.length;
    final currentTotal = billsDueTomorrow.fold(0.0, (sum, b) => sum + b.amount);

    final bool contentChanged = (lastCount != currentCount) ||
        (lastTotal != currentTotal) ||
        (lastDigestDate != todayStr);

    if (!contentChanged) {
      return const NoAction();
    }

    // Like today's logic, we cancel if empty or if user is engaged with app
    final bool shouldCancel = currentCount == 0 ||
        runContext == AppRunContext.resume ||
        runContext == AppRunContext.coldStart;

    if (shouldCancel) {
      await _store.saveTomorrowState(
        date: todayStr,
        count: currentCount,
        total: currentTotal,
      );
      return const CancelDigestAction();
    }

    if (currentCount > 0) {
      await _store.saveTomorrowState(
        date: todayStr,
        count: currentCount,
        total: currentTotal,
      );
      return ShowDigestAction(billsDueTomorrow);
    }

    return const NoAction();
  }
}
