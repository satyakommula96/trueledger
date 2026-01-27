class AppConfig {
  /// Set to true during integration tests to bypass secure storage
  /// and other native dependencies that might hang in CI environments.
  static bool isIntegrationTest = false;
}
