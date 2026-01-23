import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'screens/dashboard.dart';
import 'theme/theme.dart';
import 'services/notification_service.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'screens/intro_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize Notifications
  try {
    await NotificationService().init();
  } catch (e) {
    debugPrint('Error initializing notifications: $e');
  }

  // Schedule daily reminder (fire and forget to not block startup provided init didn't hang)
  // We don't await this to ensure app starts even if scheduling fails
  NotificationService().scheduleDailyReminder().catchError((e) {
    debugPrint('Error scheduling reminder: $e');
  });

  bool showIntro = false;
  try {
    final prefs = await SharedPreferences.getInstance();
    final bool seen = prefs.getBool('intro_seen') ?? false;
    debugPrint('Check Intro: seen=$seen');
    showIntro = !seen;

    // Load Theme Preference
    final String? themePref = prefs.getString('theme_mode');
    if (themePref == 'light') {
      themeNotifier.value = ThemeMode.light;
    } else if (themePref == 'dark') {
      themeNotifier.value = ThemeMode.dark;
    } else {
      themeNotifier.value = ThemeMode.system;
    }

  } catch (e) {
    debugPrint('Error accessing shared preferences: $e');
    // Default to handling it gracefully, maybe show intro if unsure or dashboard
    showIntro = true;
  }

  runApp(TrueCashApp(showIntro: showIntro));
}

// Global theme notifier
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

class TrueCashApp extends StatelessWidget {
  final bool showIntro;
  const TrueCashApp({super.key, required this.showIntro});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          title: 'TrueCash',
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
          home: showIntro ? const IntroScreen() : const Dashboard(),
        );
      },
    );
  }
}
