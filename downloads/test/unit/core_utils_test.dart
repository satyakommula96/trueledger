import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:trueledger/core/error/failure.dart';

void main() {
  group('Result', () {
    test('Success should work correctly', () {
      const result = Success<int>(10);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.getOrThrow, 10);
      expect(() => result.failureOrThrow, throwsException);
    });

    test('Failure should work correctly', () {
      final failure = ValidationFailure('Error');
      final result = Failure<int>(failure);
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.failureOrThrow, failure);
      expect(() => result.getOrThrow, throwsException);
    });
  });

  group('Failure', () {
    test('DatabaseFailure should have correct message', () {
      final f = DatabaseFailure('db error');
      expect(f.message, 'db error');
    });

    test('ValidationFailure should have correct message', () {
      final f = ValidationFailure('val error');
      expect(f.message, 'val error');
    });

    test('MigrationFailure should have correct message', () {
      final f = MigrationFailure('mig error');
      expect(f.message, 'mig error');
    });

    test('UnexpectedFailure should have correct message', () {
      final f = UnexpectedFailure('unexp error');
      expect(f.message, 'unexp error');
    });
  });
}
