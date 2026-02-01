# Database Migrations

TrueLedger handles schema updates gracefully through a custom migration framework, ensuring that user data is preserved across application updates.

## 🏗️ Migration Framework

The migration logic is abstracted into the `Migration` class (`lib/data/datasources/database_migrations.dart`). 

### Key Features:
- **Versioning**: Each migration is assigned a strictly increasing integer version.
- **Up/Down paths**: Support for rolling forward (required) and rolling back (optional/best effort).
- **Safety**: Includes `addColumnSafe` utility to prevent accidental "duplicate column" errors.

## 📜 Migration History

### Version 1
- Initial schema rollout with core tables: `variable_expenses`, `income_sources`, `investments`, etc.

### Version 2
- Added `statement_date` column to the `credit_cards` table.

### Version 3
- Maintenance migration to ensure `statement_date` exists across all platforms.

## 🛠️ Adding a New Migration

1. Create a new class inheriting from `Migration`:
   ```dart
   class MigrationV4 extends Migration {
     MigrationV4() : super(4);
     @override
     Future<void> up(common.Database db) async {
       await addColumnSafe(db, 'table_name', 'new_column', 'TEXT');
     }
     @override
     Future<void> down(common.Database db) async {}
   }
   ```
2. Register it in the `appMigrations` list at the bottom of the file.
3. Update `AppVersion.databaseVersion` in `lib/core/config/version.dart`.
