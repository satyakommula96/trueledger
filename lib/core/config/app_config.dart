class AppConfig {
  /// This flag is manually toggled during Integration/E2E tests.
  /// It helps bypass native dependencies (like Secure Storage or KeyChain)
  /// that may require user interaction or hang in headless CI environments.
  static bool isIntegrationTest = false;

  /// Note: Unit and Widget tests are automatically detected via
  /// Platform.environment.containsKey('FLUTTER_TEST') in service implementations.
  /// The directory name for local backups.
  static const String backupFolderName = 'TrueLedgerSafeVault';
}
