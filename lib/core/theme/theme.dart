import 'package:flutter/material.dart';

class AppTheme {
  // New Design System 2.0 - Premium Slate & Indigo Palette
  static AppColors darkColors = AppColors(
    income: const Color(0xFF10B981), // Emerald 500
    expense: const Color(0xFFE2E8F0), // Slate 200 (for general text)
    overspent: const Color(0xFFF43F5E), // Rose 500
    warning: const Color(0xFFF59E0B), // Amber 500
    divider: const Color(0xFF1E293B), // Slate 800
    secondaryText: const Color(0xFF94A3B8), // Slate 400
    surfaceCombined: const Color(0xFF0F172A), // Slate 900
    shimmer: Colors.white10,
    text: const Color(0xFFF8FAFC), // Slate 50
    success: const Color(0xFF10B981), // Emerald 500
    primary: const Color(0xFF6366F1), // Indigo 500
  );

  static AppColors lightColors = AppColors(
    income: const Color(0xFF059669), // Emerald 600
    expense: const Color(0xFF1E293B), // Slate 800
    overspent: const Color(0xFFE11D48), // Rose 600
    warning: const Color(0xFFD97706), // Amber 600
    divider: const Color(0xFFE2E8F0), // Slate 200
    secondaryText: const Color(0xFF475569), // Slate 600 (Improved contrast)
    surfaceCombined: const Color(0xFFF1F5F9), // Slate 100
    shimmer: Colors.black12,
    text: const Color(0xFF0F172A), // Slate 900
    success: const Color(0xFF059669),
    primary: const Color(0xFF4F46E5), // Indigo 600
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
        scaffoldBackgroundColor: const Color(0xFF020617), // Slate 950
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: darkColors.text,
            letterSpacing: -1,
          ),
          iconTheme: IconThemeData(color: darkColors.text),
        ),
        fontFamily: 'Outfit',
        cardTheme: CardThemeData(
          color: darkColors.surfaceCombined,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: darkColors.divider, width: 1.5),
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
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Slate 50
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: lightColors.text,
            letterSpacing: -1,
          ),
          iconTheme: IconThemeData(color: lightColors.text),
        ),
        fontFamily: 'Outfit',
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: lightColors.divider.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: lightColors.divider, width: 1),
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
