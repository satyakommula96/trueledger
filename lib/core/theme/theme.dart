import 'package:flutter/material.dart';

class AppTheme {
  // Ultra-Premium "Neo-Glass" Design System
  static AppColors darkColors = AppColors(
    income: const Color(0xFF00E676), // Neon Spring Green
    expense: const Color(0xFFE2E8F0), // Frost White
    overspent: const Color(0xFFFF2A5F), // Radiant Crimson
    warning: const Color(0xFFFFAB00), // Electric Amber
    divider: const Color(0xFF1A1D2D), // Deep Midnight Border
    secondaryText: const Color(0xFF8B95A5), // Muted Steel
    surfaceCombined: const Color(0xFF0A0D14), // Ultra Deep Space
    shimmer: Colors.white10,
    text: const Color(0xFFFFFFFF), // Pure White
    success: const Color(0xFF00E676),
    primary: const Color(0xFF00F0FF), // Electric Cyan
  );

  static AppColors lightColors = AppColors(
    income: const Color(0xFF00C853), // Deep Emerald
    expense: const Color(0xFF1E293B), // Slate 800
    overspent: const Color(0xFFE53935), // Ruby Red
    warning: const Color(0xFFFF8F00), // Rich Amber
    divider: const Color(0xFFEDF1F5), // Soft Frost
    secondaryText: const Color(0xFF64748B), // Slate 500
    surfaceCombined: const Color(0xFFFFFFFF), // Pure White
    shimmer: Colors.black12,
    text: const Color(0xFF0F172A), // Slate 900
    success: const Color(0xFF00C853),
    primary: const Color(0xFF2962FF), // Royal Ultramarine
  );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        extensions: [darkColors],
        colorScheme: ColorScheme.dark(
          primary: darkColors.primary,
          onPrimary: Colors.black,
          surface: darkColors.surfaceCombined,
          onSurface: darkColors.text,
          outline: darkColors.divider,
          error: darkColors.overspent,
        ),
        scaffoldBackgroundColor: const Color(0xFF040508), // Pitch OLED Black
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: darkColors.text,
            letterSpacing: -1.2,
          ),
          iconTheme: IconThemeData(color: darkColors.text),
        ),
        fontFamily: 'Outfit',
        cardTheme: CardThemeData(
          color: darkColors.surfaceCombined,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32), // Ultra rounded corners
            side: BorderSide(color: darkColors.divider, width: 2.0),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: darkColors.primary,
          foregroundColor: Colors.black,
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: ZoomPageTransitionsBuilder(),
            TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
            TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          },
        ),
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        extensions: [lightColors],
        colorScheme: ColorScheme.light(
          primary: lightColors.primary,
          onPrimary: Colors.white,
          surface: lightColors.surfaceCombined,
          onSurface: lightColors.text,
          outline: lightColors.divider,
          error: lightColors.overspent,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7FB), // Premium Cool Grey
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: lightColors.text,
            letterSpacing: -1.2,
          ),
          iconTheme: IconThemeData(color: lightColors.text),
        ),
        fontFamily: 'Outfit',
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 4,
          shadowColor: lightColors.primary.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32), // Ultra rounded corners
            side: BorderSide(
                color: lightColors.divider.withValues(alpha: 0.5), width: 1.5),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: lightColors.primary,
          foregroundColor: Colors.white,
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: ZoomPageTransitionsBuilder(),
            TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
            TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          },
        ),
      );
}

class AppColors extends ThemeExtension<AppColors> {
  final Color income;
  final Color expense;
  final Color overspent;
  final Color warning;
  final Color divider;
  final Color secondaryText;
  final Color surfaceCombined;
  final Color shimmer;
  final Color text;
  final Color success;
  final Color primary;

  AppColors({
    required this.income,
    required this.expense,
    required this.overspent,
    required this.warning,
    required this.divider,
    required this.secondaryText,
    required this.surfaceCombined,
    required this.shimmer,
    required this.text,
    required this.success,
    required this.primary,
  });

  @override
  ThemeExtension<AppColors> copyWith({
    Color? income,
    Color? expense,
    Color? overspent,
    Color? warning,
    Color? divider,
    Color? secondaryText,
    Color? surfaceCombined,
    Color? shimmer,
    Color? text,
    Color? success,
    Color? primary,
  }) {
    return AppColors(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      overspent: overspent ?? this.overspent,
      warning: warning ?? this.warning,
      divider: divider ?? this.divider,
      secondaryText: secondaryText ?? this.secondaryText,
      surfaceCombined: surfaceCombined ?? this.surfaceCombined,
      shimmer: shimmer ?? this.shimmer,
      text: text ?? this.text,
      success: success ?? this.success,
      primary: primary ?? this.primary,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      overspent: Color.lerp(overspent, other.overspent, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      surfaceCombined: Color.lerp(surfaceCombined, other.surfaceCombined, t)!,
      shimmer: Color.lerp(shimmer, other.shimmer, t)!,
      text: Color.lerp(text, other.text, t)!,
      success: Color.lerp(success, other.success, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
    );
  }
}
