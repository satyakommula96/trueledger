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

    // 2. Trigger Daily Bill Digest (Aggregated)
    if (startupResult.billsDueToday.isNotEmpty) {
      // Foreground suppression: Only notify if not actively in the app
      final state = WidgetsBinding.instance.lifecycleState;
      if (state != AppLifecycleState.resumed) {
        await notificationService
            .showDailyBillDigest(startupResult.billsDueToday);

        // 3. Persist State (Side Effect) - Only after successful dispatch
        final prefs = ref.read(sharedPreferencesProvider);
        final now = DateTime.now();
        final todayStr = DateFormat('yyyy-MM-dd').format(now);
        final count = startupResult.billsDueToday.length;
        final total =
            startupResult.billsDueToday.fold(0, (sum, b) => sum + b.amount);

        await prefs.setString('last_bill_digest_date', todayStr);
        await prefs.setInt('last_bill_digest_count', count);
        await prefs.setInt('last_bill_digest_total', total);
      }
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
