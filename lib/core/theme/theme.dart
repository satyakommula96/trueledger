import 'package:flutter/material.dart';

class AppTheme {
  // Apple-Inspired "Financial Clarity" Design System
  static AppColors darkColors = AppColors(
    income: const Color(0xFF30D158), // System Green (Dark)
    expense: const Color(0xFFE5E5EA), // System Gray 6 (Light)
    overspent: const Color(0xFFFF453A), // System Red (Dark)
    warning: const Color(0xFFFF9F0A), // System Orange (Dark)
    divider: const Color(0xFF38383A), // System Gray 4 (Dark)
    secondaryText: const Color(0xFF8E8E93), // System Gray
    surfaceCombined: const Color(0xFF1C1C1E), // System Gray 6 (Dark)
    shimmer: Colors.white10,
    text: const Color(0xFFFFFFFF), // Label
    success: const Color(0xFF30D158),
    primary: const Color(0xFF0A84FF), // System Blue (Dark)
  );

  static AppColors lightColors = AppColors(
    income: const Color(0xFF34C759), // System Green (Light)
    expense: const Color(0xFF1C1C1E), // System Gray 6 (Dark)
    overspent: const Color(0xFFFF3B30), // System Red (Light)
    warning: const Color(0xFFFF9500), // System Orange (Light)
    divider: const Color(0xFFC6C6C8), // System Gray 4 (Light)
    secondaryText: const Color(0xFF8E8E93), // System Gray
    surfaceCombined: const Color(0xFFFFFFFF), // Secondary Background
    shimmer: Colors.black12,
    text: const Color(0xFF000000), // Label
    success: const Color(0xFF34C759),
    primary: const Color(0xFF007AFF), // System Blue (Light)
  );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        extensions: [darkColors],
        colorScheme: ColorScheme.dark(
          primary: darkColors.primary,
          onPrimary: Colors.white,
          surface: darkColors.surfaceCombined,
          onSurface: darkColors.text,
          outline: darkColors.divider,
          error: darkColors.overspent,
        ),
        scaffoldBackgroundColor: const Color(0xFF000000), // Pure OLED Black
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: darkColors.text,
            letterSpacing: -0.5,
            fontFamily: 'Outfit',
          ),
          iconTheme: IconThemeData(color: darkColors.text),
        ),
        fontFamily: 'Outfit',
        cardTheme: CardThemeData(
          color: darkColors.surfaceCombined,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Apple Standard
            side: BorderSide(color: darkColors.divider, width: 0.5),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: darkColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        scaffoldBackgroundColor: const Color(0xFFF2F2F7), // Apple System Gray 6
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: lightColors.text,
            letterSpacing: -0.5,
            fontFamily: 'Outfit',
          ),
          iconTheme: IconThemeData(color: lightColors.text),
        ),
        fontFamily: 'Outfit',
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Apple Standard
            side: BorderSide(
                color: lightColors.divider.withValues(alpha: 0.5), width: 0.5),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: lightColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
