import 'package:flutter/material.dart';

class AppTheme {
  // Semantic Colors mapped from the USER's HTML sample tokens
  static AppColors darkColors = AppColors(
    income: const Color(0xFF34D399), // --green (Dark)
    expense: const Color(0xFFE5E7EB), // --text-primary (Dark)
    overspent: const Color(0xFFF87171), // --danger (Dark)
    warning: const Color(0xFFFBBF24), // --warning (Dark)
    divider: const Color(0xFF334155), // --border (Dark)
    secondaryText: const Color(0xFF9CA3AF), // --text-secondary (Dark)
    surfaceCombined: const Color(0xFF1E293B),
    shimmer: Colors.white12,
  );

  static AppColors lightColors = AppColors(
    income: const Color(0xFF2ECC71), // --green (Light)
    expense: const Color(0xFF1F2933), // --text-primary (Light)
    overspent: const Color(0xFFE74C3C), // --danger (Light)
    warning: const Color(0xFFF39C12), // --warning (Light)
    divider: const Color(0xFFE5E7EB), // --border (Light)
    secondaryText: const Color(0xFF6B7280), // --text-secondary (Light)
    surfaceCombined: const Color(0xFFEFF6FF),
    shimmer: Colors.black12,
  );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        extensions: [darkColors],
        colorScheme: const ColorScheme.dark(
          primary:
              Color(0xFF34D399), // Primary action color (Green from sample)
          onPrimary: Colors.white,
          surface: Color(0xFF1E293B), // --bg (Dark)
          onSurface: Color(0xFFE5E7EB),
          outline: Color(0xFF334155), // --border (Dark)
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFFE5E7EB)),
          iconTheme: IconThemeData(color: Color(0xFFE5E7EB)),
        ),
        fontFamily: 'Outfit',
        cardTheme: CardThemeData(
          color: const Color(0xFF1E293B),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF334155), width: 1),
          ),
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
        colorScheme: const ColorScheme.light(
          primary:
              Color(0xFF2ECC71), // Primary action color (Green from sample)
          onPrimary: Colors.white,
          surface: Color(0xFFF6F7F9), // --bg (Light)
          onSurface: Color(0xFF1F2933),
          outline: Color(0xFFE5E7EB), // --border (Light)
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2933)),
          iconTheme: IconThemeData(color: Color(0xFF1F2933)),
        ),
        fontFamily: 'Outfit',
        cardTheme: CardThemeData(
          color: const Color(0xFFF6F7F9),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
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

  AppColors({
    required this.income,
    required this.expense,
    required this.overspent,
    required this.warning,
    required this.divider,
    required this.secondaryText,
    required this.surfaceCombined,
    required this.shimmer,
  });

  @override
  ThemeExtension<AppColors> copyWith(
      {Color? income,
      Color? expense,
      Color? overspent,
      Color? warning,
      Color? divider,
      Color? secondaryText,
      Color? surfaceCombined,
      Color? shimmer}) {
    return AppColors(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      overspent: overspent ?? this.overspent,
      warning: warning ?? this.warning,
      divider: divider ?? this.divider,
      secondaryText: secondaryText ?? this.secondaryText,
      surfaceCombined: surfaceCombined ?? this.surfaceCombined,
      shimmer: shimmer ?? this.shimmer,
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
    );
  }
}
