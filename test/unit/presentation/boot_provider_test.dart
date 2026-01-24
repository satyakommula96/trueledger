import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truecash/core/error/failure.dart';
import 'package:truecash/core/utils/result.dart';
import 'package:truecash/domain/usecases/startup_usecase.dart';
import 'package:truecash/domain/usecases/usecase_base.dart';
import 'package:truecash/presentation/providers/boot_provider.dart';
import 'package:truecash/presentation/providers/usecase_providers.dart';
import 'package:truecash/domain/repositories/i_financial_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockRepo extends Mock implements IFinancialRepository {}

class SuccessStartupUseCase extends StartupUseCase {
  SuccessStartupUseCase() : super(MockRepo());
  @override
  Future<Result<void>> call(NoParams params) async => const Success(null);
}

class FailureStartupUseCase extends StartupUseCase {
  FailureStartupUseCase() : super(MockRepo());
  @override
  Future<Result<void>> call(NoParams params) async =>
      Failure(DatabaseFailure("Fail"));
}

void main() {
  test('bootProvider success', () async {
    final container = ProviderContainer(
      overrides: [
        startupUseCaseProvider.overrideWith((ref) => SuccessStartupUseCase()),
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
