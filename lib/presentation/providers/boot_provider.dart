import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truecash/domain/usecases/usecase_base.dart';
import 'package:truecash/presentation/providers/usecase_providers.dart';

final bootProvider = FutureProvider<void>((ref) async {
  final startupUseCase = ref.watch(startupUseCaseProvider);
  final result = await startupUseCase(NoParams());

  if (result.isFailure) {
    // We could rethrow to let FutureProvider handle it,
    // or log specifically.
    throw Exception(result.failureOrThrow.message);
  }
});
