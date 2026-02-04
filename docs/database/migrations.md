# Database Migrations

TrueLedger handles schema updates gracefully through a custom migration framework, ensuring that user data is preserved across application updates while maintaining a stable and durable storage structure.

## 🏗️ Storage Strategy

From version 1.3.18+, TrueLedger uses a **stable filename strategy** for the database:
- **Filename**: `trueledger_secure.db`
- **Location**: Application Documents directory (platform-specific).
- **Legacy Migration**: On startup, if the stable database is not found, the app automatically checks for legacy versioned files (e.g., `tracker_enc_v6.db`) and migrates data to the new stable file.

## 🛠️ Migration Framework

The migration logic is managed via the `Migration` class (`lib/data/datasources/database_migrations.dart`).

### Key Features:
- **Versioning**: Each migration is assigned a strictly increasing integer version.
- **Tracking Table**: A special `_migrations` table records every applied migration with a timestamp for auditability.
- **Graceful Up/Down**: Support for rolling forward and rolling back schema changes.
- **Performance**: Designed to keep startup time under 1 second by using optimized SQLite operations.

## 📜 Migration History

### Version 1
- Initial schema rollout with core tables: `variable_expenses`, `income_sources`, `investments`, etc.

### Version 2
- Added `statement_date` column to the `credit_cards` table.

### Version 3
- Maintenance migration to ensure `statement_date` exists across all platforms.

### Version 4
- Implemented `custom_categories` support for personalized tracking.

### Version 5
- Core table verification for `credit_cards` and `loans` to ensure schema consistency.

### Version 6
- Added `last_reviewed_at` to the `budgets` table to track budget health.

## 🛠️ Adding a New Migration

1. Create a new class inheriting from `Migration`:
   ```dart
   class MigrationV7 extends Migration {
     MigrationV7() : super(7);
     @override
     Future<void> up(common.Database db) async {
       await addColumnSafe(db, 'table_name', 'new_column', 'TEXT');
     }
     @override
     Future<void> down(common.Database db) async {}
   }
   ```
2. Register it in the `appMigrations` list in `lib/data/datasources/database_migrations.dart`.
3. Update `AppVersion.databaseVersion` in `lib/core/config/version.dart`.
