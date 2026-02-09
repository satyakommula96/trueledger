import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/domain/usecases/usecase_base.dart';
import 'package:trueledger/presentation/providers/usecase_providers.dart';
import 'package:trueledger/presentation/providers/notification_provider.dart';
import 'package:trueledger/core/services/notification_service.dart';
import 'package:trueledger/presentation/providers/backup_provider.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:trueledger/domain/usecases/startup_usecase.dart';
import 'package:trueledger/core/config/app_config.dart';
import 'package:trueledger/core/providers/secure_storage_provider.dart';
import 'dart:math' as math;
import 'package:trueledger/domain/services/personalization_service.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';

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
  }

  // 2. The Daily Bill Digest logic is now handled reactively by
  // dailyDigestOrchestratorProvider to support resume and real-time updates.

  // 3. Pay Day Logic (Personalization)
  try {
    final settings = ref.read(personalizationServiceProvider).getSettings();
    if (settings.payDay != null) {
      final now = DateTime.now();
      // Handle end of month (e.g. payDay is 31, but Feb has 28)
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
      final targetDay = math.min(settings.payDay!, lastDayOfMonth);

      if (now.day == targetDay) {
        final prefs = ref.read(sharedPreferencesProvider);
        final key =
            'salary_notification_shown_${now.year}_${now.month}_${now.day}';

        // Ensure we only show once per day
        if (prefs.getString(key) == null) {
          await notificationService.showNotification(
            id: NotificationService.salaryDayId,
            title: "Salary Day!",
            body:
                "It's your usual pay day. Time to review your budget and investments?",
            payload: NotificationService.routeDashboard,
          );
          await prefs.setString(key, 'true');
        }
      }
    }
  } catch (e) {
    debugPrint("Pay Day check failed: $e");
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
