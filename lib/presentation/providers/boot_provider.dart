import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trueledger/domain/usecases/usecase_base.dart';
import 'package:trueledger/presentation/providers/usecase_providers.dart';
import 'package:trueledger/presentation/providers/notification_provider.dart';
import 'package:trueledger/core/services/notification_service.dart';
import 'package:trueledger/presentation/providers/backup_provider.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:trueledger/domain/usecases/startup_usecase.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/core/config/app_config.dart';
import 'package:trueledger/core/providers/secure_storage_provider.dart';

final bootProvider = FutureProvider<String?>((ref) async {
  final startupUseCase = ref.watch(startupUseCaseProvider);
  final result = await startupUseCase(NoParams(), onBackupSuccess: () {
    ref.read(lastBackupTimeProvider.notifier).updateLastBackupTime();
  });

  if (result.isFailure) {
    throw Exception(result.failureOrThrow.message);
  }

  final startupResult = (result as Success<StartupResult>).value;

  // 1. Initialize and perform side-effects (Infrastructure/Presentation level)
  final notificationService = ref.read(notificationServiceProvider);
  await notificationService.init();
  final granted = await notificationService.requestPermissions();

  if (granted) {
    if (startupResult.shouldScheduleReminder) {
      await notificationService.scheduleDailyReminder();
    } else if (startupResult.shouldCancelReminder) {
      await notificationService
          .cancelNotification(NotificationService.dailyReminderId);
    }

    // 2. Daily Bill Digest Logic (Aggregated)
    // NOTE: This is currently tied to the app lifecycle (boot/resume).
    // It triggers a notification immediately if the digest content has changed.
    // Real "morning scheduling" without opening the app requires a background worker
    // or platform-specific alarm manager which is intentionally deferred for now.
    // We check this regardless of whether list is empty, because we might need to CANCEL existing notifications.
    final prefs = ref.read(sharedPreferencesProvider);
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    final lastDigestDate =
        prefs.getString(NotificationService.keyLastDigestDate);
    final lastCount = prefs.getInt(NotificationService.keyLastDigestCount);
    final lastTotal = prefs.getInt(NotificationService.keyLastDigestTotal);

    final currentCount = startupResult.billsDueToday.length;
    final currentTotal =
        startupResult.billsDueToday.fold(0, (sum, b) => sum + b.amount);

    final bool contentChanged = (lastCount != currentCount) ||
        (lastTotal != currentTotal) ||
        (lastDigestDate != todayStr);

    if (contentChanged) {
      // Logic:
      // 1. If currently 0 bills (all paid), cancel any stale notification.
      // 2. If app is RESUMED (user looking at it), cancel notification (don't need it in tray).
      // 3. Otherwise (background/inactive), show/update the notification.

      final state = WidgetsBinding.instance.lifecycleState;
      final bool shouldCancel =
          currentCount == 0 || state == AppLifecycleState.resumed;

      if (shouldCancel) {
        await notificationService
            .cancelNotification(NotificationService.dailyBillDigestId);
      } else {
        await notificationService
            .showDailyBillDigest(startupResult.billsDueToday);
      }

      // 3. Persist State
      await prefs.setString(NotificationService.keyLastDigestDate, todayStr);
      await prefs.setInt(NotificationService.keyLastDigestCount, currentCount);
      await prefs.setInt(NotificationService.keyLastDigestTotal, currentTotal);
    }
  }

  // Bypass Secure Storage during tests to avoid UI blocking hangs
  if (AppConfig.isIntegrationTest) {
    return null;
  }

  final storage = ref.read(secureStorageProvider);
  try {
    return await storage.read(key: 'app_pin');
  } catch (e, stack) {
    // If secure storage fails (e.g. simulator/tests), return null
    debugPrint(
        "App PIN secure storage retrieval failed (possibly non-critical): $e");
    if (kDebugMode) {
      debugPrint(stack.toString());
      throw Exception("App PIN retrieval failed in Debug Mode: $e\n$stack");
    }
    return null;
  }
});
