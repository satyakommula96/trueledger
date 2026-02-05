import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/core/error/failure.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:trueledger/domain/usecases/startup_usecase.dart';
import 'package:trueledger/domain/usecases/auto_backup_usecase.dart';
import 'package:trueledger/domain/usecases/usecase_base.dart';
import 'package:trueledger/presentation/providers/boot_provider.dart';
import 'package:trueledger/presentation/providers/usecase_providers.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trueledger/domain/models/models.dart';

import 'package:trueledger/core/services/notification_service.dart';
import 'package:trueledger/presentation/providers/notification_provider.dart';

import 'package:trueledger/core/providers/secure_storage_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MockRepo extends Mock implements IFinancialRepository {}

class MockNotificationService extends Mock implements NotificationService {}

class MockAutoBackupUseCase extends Mock implements AutoBackupUseCase {}

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

class MockPrefs extends Mock implements SharedPreferences {}

class SuccessStartupUseCase extends StartupUseCase {
  SuccessStartupUseCase() : super(MockRepo(), MockAutoBackupUseCase());
  @override
  Future<Result<StartupResult>> call(NoParams params,
          {void Function()? onBackupSuccess}) async =>
      Success(StartupResult(shouldScheduleReminder: true));
}

class FailureStartupUseCase extends StartupUseCase {
  FailureStartupUseCase() : super(MockRepo(), MockAutoBackupUseCase());
  @override
  Future<Result<StartupResult>> call(NoParams params,
          {void Function()? onBackupSuccess}) async =>
      Failure(DatabaseFailure("Fail"));
}

void main() {
  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(NoParams());
    registerFallbackValue(<BillSummary>[]);
    registerFallbackValue(0);
  });

  test('bootProvider success', () async {
    final mockNotification = MockNotificationService();
    when(() => mockNotification.init()).thenAnswer((_) async {});
    when(() => mockNotification.requestPermissions())
        .thenAnswer((_) async => true);
    when(() => mockNotification.scheduleDailyReminder())
        .thenAnswer((_) async {});
    when(() => mockNotification.cancelNotification(any()))
        .thenAnswer((_) async {});
    when(() => mockNotification.showDailyBillDigest(any()))
        .thenAnswer((_) async {});

    final mockStorage = MockSecureStorage();
    when(() => mockStorage.read(key: 'app_pin')).thenAnswer((_) async => null);

    final mockPrefs = MockPrefs();
    when(() => mockPrefs.getInt(any())).thenReturn(null);
    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.setInt(any(), any())).thenAnswer((_) async => true);

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        startupUseCaseProvider.overrideWith((ref) => SuccessStartupUseCase()),
        notificationServiceProvider.overrideWithValue(mockNotification),
        secureStorageProvider.overrideWithValue(mockStorage),
      ],
    );
    addTearDown(container.dispose);
    await container.read(bootProvider.future);
    expect(container.read(bootProvider).hasValue, true);
  });

  test('bootProvider failure', () async {
    final container = ProviderContainer(
      overrides: [
        startupUseCaseProvider.overrideWith((ref) => FailureStartupUseCase()),
        // notificationServiceProvider not strictly needed for failure if it fails early
      ],
    );
    addTearDown(container.dispose);

    // Instead of awaiting future which might hang on early error in some environments,
    // let's wait for it to settle.
    container.read(bootProvider); // trigger

    // Wait for the next microtask or a bit of time
    await Future.delayed(const Duration(milliseconds: 100));

    expect(container.read(bootProvider).hasError, true);
  });
}
