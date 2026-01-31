class AppVersion {
  // App Version (Semantic Versioning) - Displayed in Settings
  static const String current = '1.1.0';

  // Database Version (Integer) - Used for SQLite Migrations
  // Increment this ONLY when you modify the database schema (db/schema.dart)
  static const int databaseVersion = 3;
}
