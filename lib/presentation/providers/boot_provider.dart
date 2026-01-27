import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/domain/usecases/usecase_base.dart';
import 'package:trueledger/presentation/providers/usecase_providers.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:trueledger/core/config/app_config.dart';

final bootProvider = FutureProvider<String?>((ref) async {
  final startupUseCase = ref.watch(startupUseCaseProvider);
  final result = await startupUseCase(NoParams());

  if (result.isFailure) {
    throw Exception(result.failureOrThrow.message);
  }

  // Bypass Secure Storage during tests to avoid UI blocking hangs
  if (AppConfig.isIntegrationTest) {
    return null;
  }

  const storage = FlutterSecureStorage();
  try {
    return await storage.read(key: 'app_pin');
  } catch (e) {
    // If secure storage fails (e.g. simulator/tests), return null
    return null;
  }
});
