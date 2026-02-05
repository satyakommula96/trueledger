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

/// Use Case to manage the logic of the Daily Bill Digest.
class ManageDailyDigestUseCase {
  final DailyDigestStore _store;

  ManageDailyDigestUseCase(this._store);

  /// Decides whether to show, update, or cancel a notification.
  ///
  /// CRITICAL WARNING: If background task scheduling or platform-specific alarms
  /// are added in the future to support "guaranteed morning delivery" without opening the app,
  /// this logic MUST be shared or coordinated with that worker to
  /// prevent double-notifications or conflicting tray updates.
  Future<DailyDigestAction> execute(
    List<BillSummary> billsDueToday,
    AppRunContext runContext,
  ) async {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    final lastDigestDate = _store.getLastDigestDate();
    final lastCount = _store.getLastDigestCount();
    final lastTotal = _store.getLastDigestTotal();

    final currentCount = billsDueToday.length;
    final currentTotal = billsDueToday.fold(0, (sum, b) => sum + b.amount);

    final bool contentChanged = (lastCount != currentCount) ||
        (lastTotal != currentTotal) ||
        (lastDigestDate != todayStr);

    if (!contentChanged) {
      return const NoAction();
    }

    // Logic for deciding Show vs Cancel:
    // 1. If currently 0 bills (all paid), cancel any stale notification.
    // 2. If app is RESUMED (user looking at it), cancel notification (don't need it in tray).
    // 3. Otherwise (background/coldStart), show/update the notification.

    final bool shouldCancel =
        currentCount == 0 || runContext == AppRunContext.resume;

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
}
