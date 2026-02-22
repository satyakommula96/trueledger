import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/core/providers/lifecycle_provider.dart';
import 'package:trueledger/core/services/notification_service.dart';
import 'package:trueledger/domain/usecases/manage_daily_digest_usecase.dart';
import 'package:trueledger/presentation/providers/dashboard_provider.dart';
import 'package:trueledger/presentation/providers/notification_provider.dart';
import 'package:trueledger/presentation/providers/usecase_providers.dart';

/// Reactive orchestrator for the Daily Bill Digest.
/// It watches data changes and lifecycle events to automatically
/// show, update, or cancel notifications.
final dailyDigestCoordinatorProvider = Provider.autoDispose<void>((ref) {
  // 1. Listen to data changes (bills due today)
  final dashboardAsync = ref.watch(dashboardProvider);

  // 2. Listen to lifecycle changes (resume/background)
  final lifecycle = ref.watch(appLifecycleProvider);

  // We only run logic when data is available
  dashboardAsync.whenData((data) async {
    final useCase = ref.read(manageDailyDigestUseCaseProvider);
    final notificationService = ref.read(notificationServiceProvider);

    // Map Lifecycle to Domain Context
    final runContext = switch (lifecycle) {
      AppLifecycleState.resumed => AppRunContext.resume,
      AppLifecycleState.detached => AppRunContext.coldStart,
      _ => AppRunContext.background,
    };

    final actions = await useCase.execute(
        data.billsDueToday, data.billsDueTomorrow, runContext);

    if (actions.todayAction is ShowDigestAction) {
      await notificationService
          .showDailyBillDigest((actions.todayAction as ShowDigestAction).bills);
    } else if (actions.todayAction is CancelDigestAction) {
      await notificationService
          .cancelNotification(NotificationService.dailyBillDigestId);
    }

    if (actions.tomorrowAction is ShowDigestAction) {
      await notificationService.showTomorrowBillDigest(
          (actions.tomorrowAction as ShowDigestAction).bills);
    } else if (actions.tomorrowAction is CancelDigestAction) {
      await notificationService
          .cancelNotification(NotificationService.tomorrowBillDigestId);
    }
  });
});
