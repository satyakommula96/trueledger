import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/core/theme/theme.dart';

void main() {
  group('AppColors', () {
    test('darkColors should have correct income color', () {
      expect(AppTheme.darkColors.income, const Color(0xFF10B981));
    });

    test('lightColors should have correct income color', () {
      expect(AppTheme.lightColors.income, const Color(0xFF059669));
    });

    test('darkColors should have correct overspent color', () {
      expect(AppTheme.darkColors.overspent, const Color(0xFFF43F5E));
    });

    test('lightColors should have correct overspent color', () {
      expect(AppTheme.lightColors.overspent, const Color(0xFFE11D48));
    });

    test('copyWith should work correctly', () {
      final original = AppTheme.darkColors;
      final modified = original.copyWith(income: Colors.red);

      expect(modified, isA<AppColors>());
      expect((modified as AppColors).income, Colors.red);
      expect(modified.expense, original.expense);
    });

    test('lerp should interpolate colors', () {
      final dark = AppTheme.darkColors;
      final light = AppTheme.lightColors;
      final lerped = dark.lerp(light, 0.5);

      expect(lerped, isA<AppColors>());
    });

    test('lerp should return this if other is not AppColors', () {
      final dark = AppTheme.darkColors;
      final result = dark.lerp(null, 0.5);

      expect(result, dark);
    });

    test('copyWith preserves values when not overridden', () {
      final colors = AppTheme.darkColors;
      final copy = colors.copyWith() as AppColors;

      expect(copy.income, colors.income);
      expect(copy.expense, colors.expense);
      expect(copy.overspent, colors.overspent);
      expect(copy.warning, colors.warning);
      expect(copy.divider, colors.divider);
      expect(copy.secondaryText, colors.secondaryText);
      expect(copy.surfaceCombined, colors.surfaceCombined);
      expect(copy.shimmer, colors.shimmer);
    });
  });
}
