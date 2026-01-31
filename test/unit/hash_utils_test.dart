import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/core/utils/hash_utils.dart';

void main() {
  group('hash_utils', () {
    test('generateStableHash should return same hash for same input', () {
      const input = 'test_string';
      final hash1 = generateStableHash(input);
      final hash2 = generateStableHash(input);
      expect(hash1, equals(hash2));
    });

    test('generateStableHash should return different hash for different input',
        () {
      final hash1 = generateStableHash('string1');
      final hash2 = generateStableHash('string2');
      expect(hash1, isNot(equals(hash2)));
    });

    test('generateStableHash should return positive 31-bit integer', () {
      final hash = generateStableHash(
          'a very long string that might overflow 32 bits if not handled correctly');
      expect(hash, isNonNegative);
      expect(hash, lessThanOrEqualTo(0x7FFFFFFF));
    });

    test('generateStableHash should handle empty string', () {
      final hash = generateStableHash('');
      expect(hash, equals(5381 & 0x7FFFFFFF));
    });
  });
}
