import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  /// This flag is manually toggled during Integration/E2E tests.
  /// It helps bypass native dependencies (like Secure Storage or KeyChain)
  /// that may require user interaction or hang in headless CI environments.
  static bool isIntegrationTest = false;

  /// Detects if we are running in any test environment (Unit, Widget, or Integration).
  static bool get isTest {
    if (isIntegrationTest) return true;
    try {
      return !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  /// The directory name for local backups.
  static const String backupFolderName = 'TrueLedgerSafeVault';
}
