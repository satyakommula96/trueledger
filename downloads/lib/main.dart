import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:ui';

import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/presentation/screens/startup/startup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initial Desktop Setup (Linux, Windows, & macOS)
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    // Note: For Windows, we assume sqlcipher.dll is in the same directory or path
    // If you want to force it, use:
    // open.overrideFor(OperatingSystem.windows, () => DynamicLibrary.open('sqlcipher.dll'));

    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 2. Load basic config (Shared Prefs)
  final prefs = await SharedPreferences.getInstance();

  // 3. Set global theme from prefs
  final String? themePref = prefs.getString('theme_mode');
  if (themePref == 'light') {
    themeNotifier.value = ThemeMode.light;
  } else if (themePref == 'dark') {
    themeNotifier.value = ThemeMode.dark;
  }

  // 4. Configure fonts to work offline
  AppTheme.initializeFonts();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const TrueLedgerApp(),
    ),
  );
}

// Global theme notifier (Keeping for now to avoid breaking existing toggle logic)
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

class TrueLedgerApp extends StatelessWidget {
  const TrueLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          title: 'TrueLedger',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.mouse,
              PointerDeviceKind.touch,
              PointerDeviceKind.stylus,
              PointerDeviceKind.trackpad
            },
          ),
          home: const StartupScreen(),
        );
      },
    );
  }
}
