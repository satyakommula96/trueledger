import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'dart:ui';

import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/presentation/screens/startup/startup_screen.dart';

Future<void> main() async {
  if (kIsWeb) {
    usePathUrlStrategy();
  }
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initial Desktop & Web Setup
  if (kIsWeb) {
    // Web support via sqlite3.wasm
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    // Desktop: Use sqlite3_flutter_libs (unencrypted)
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
