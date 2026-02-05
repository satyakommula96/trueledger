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
