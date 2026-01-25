# Configuration Guide

Customize TrueCash to fit your needs.

## App Settings

All settings are accessible from the **Settings** screen (gear icon in the app bar).

### Theme Configuration

**Location**: Settings → Theme

Choose your preferred visual theme:

- **System Default**: Follows your device's theme setting
- **Light Mode**: Always use light theme
- **Dark Mode**: Always use dark theme

```dart
// Programmatically set theme
SharedPreferences prefs = await SharedPreferences.getInstance();
await prefs.setString('theme_mode', 'dark'); // 'light', 'dark', or 'system'
```

### Currency Settings

**Location**: Settings → Currency

Select your currency symbol from the dropdown:

- USD ($)
- EUR (€)
- GBP (£)
- INR (₹)
- JPY (¥)
- And many more...

```dart
// Programmatically set currency
SharedPreferences prefs = await SharedPreferences.getInstance();
await prefs.setString('currency', '\$');
```

### Privacy Mode

**Location**: Dashboard Header (Eye Icon)

Toggle the global privacy mask to hide sensitive financial numbers in public.

- **Enabled**: All monetary values are masked (e.g., `****`)
- **Disabled**: Values are shown normally
- **Persistence**: Setting is remembered across app restarts
- **Policy**: For full details, see the [Privacy Policy](../privacy.md).

## Security Settings

### PIN Lock

**Location**: Settings → Security → PIN Lock

1. Toggle **Enable PIN Lock**
2. Enter a 4-digit PIN
3. Confirm the PIN

The app will now require the PIN on every launch.

```dart
// Check if PIN is enabled
SharedPreferences prefs = await SharedPreferences.getInstance();
bool pinEnabled = prefs.getBool('pin_enabled') ?? false;
```

### Account Recovery

**Location**: Settings → Security → View Recovery Key

Never lose access to your data. When setting a PIN, TrueCash generates a unique 14-character **Recovery Key** (e.g., `ABCD-1234-WX99`).

- **Setup**: You must save this key when creating a PIN.
- **Usage**: If you forget your PIN, tap "Forgot PIN?" on the lock screen and enter your key to reset security without data loss.
- **View Key**: Authenticated users can view their key in Settings to save it again.

### Biometric Authentication

**Location**: Settings → Security → Biometric Lock

Enable fingerprint or face recognition (if supported by your device):

1. Toggle **Enable Biometric Lock**
2. Authenticate with your biometric

!!! note
    Biometric authentication requires PIN lock to be enabled as a fallback.

### Data Encryption

**Mobile Platforms (Android/iOS)**:
- Data is automatically encrypted using **SQLCipher** with AES-256
- Encryption key is stored in platform secure storage (Keychain/Keyring)

**Desktop Platforms (Linux/macOS/Windows)**:
- Data is stored unencrypted in SQLite
- Relies on file system permissions for security

## Notification Settings

**Location**: Settings → Notifications

Configure reminders and alerts:

- **Budget Alerts**: Get notified when approaching budget limits
- **Bill Reminders**: Reminders for upcoming bills and subscriptions
- **Daily Summary**: Daily financial summary notification

```dart
// Enable notifications
await NotificationService().requestPermissions();
```

## Data Management

### Export Data

**Location**: Settings → Data Management → Export Data

Export all your financial data to a JSON file:

1. Tap **Export Data**
2. Choose save location
3. File is saved as `truecash_backup_YYYY-MM-DD.json`

**Export Format**:
```json
{
  "version": "1.0.0",
  "exported_at": "2026-01-24T17:00:00Z",
  "income_sources": [...],
  "fixed_expenses": [...],
  "variable_expenses": [...],
  "budgets": [...],
  "saving_goals": [...]
}
```

### Import Data

**Location**: Settings → Data Management → Import Data

Restore data from a backup file:

1. Tap **Import Data**
2. Select your backup JSON file
3. Confirm the import

!!! danger "Warning"
    Importing will **replace all existing data**. Export current data first!

### Clear All Data

**Location**: Settings → Data Management → Clear All Data

Permanently delete all financial data:

1. Tap **Clear All Data**
2. Confirm the action

!!! danger "Irreversible"
    This action cannot be undone. Export your data before clearing!

## Advanced Configuration

### Database Location

**Default Paths**:

- **Android**: `/data/data/com.truecash.app/databases/truecash.db`
- **iOS**: `~/Library/Application Support/truecash.db`
- **Linux**: `~/.local/share/truecash/truecash.db`
- **macOS**: `~/Library/Application Support/truecash/truecash.db`
- **Windows**: `%APPDATA%\truecash\truecash.db`
- **Web**: IndexedDB (browser storage)

### Shared Preferences

**Location**: Platform-specific

- **Android**: `/data/data/com.truecash.app/shared_prefs/`
- **iOS**: `~/Library/Preferences/`
- **Desktop**: Platform-specific preferences directory

**Stored Settings**:
```dart
{
  "intro_seen": true,
  "theme_mode": "dark",
  "currency": "$",
  "pin_enabled": false,
  "biometric_enabled": false,
  "notifications_enabled": true
}
```

### Environment Variables

For development and testing:

```bash
# Enable debug logging
export TRUECASH_DEBUG=true

# Use custom database path
export TRUECASH_DB_PATH=/path/to/custom/db

# Disable encryption (testing only)
export TRUECASH_DISABLE_ENCRYPTION=true
```

## Performance Tuning

### Database Optimization

The app automatically optimizes database performance:

- **Indexes**: Created on frequently queried columns
- **Batch Operations**: Bulk inserts use transactions
- **Query Caching**: Common queries are cached

### UI Performance

- **Lazy Loading**: Large lists use `ListView.builder`
- **Const Widgets**: Static widgets use `const` constructors
- **Provider Granularity**: Minimized rebuilds with scoped providers

## Troubleshooting

### Reset to Defaults

To reset all settings to default values:

1. Go to **Settings** → **Advanced**
2. Tap **Reset to Defaults**
3. Confirm the action

Or manually:

```dart
SharedPreferences prefs = await SharedPreferences.getInstance();
await prefs.clear();
```

### Clear Cache

If experiencing performance issues:

1. Go to **Settings** → **Advanced**
2. Tap **Clear Cache**

### Rebuild Database

If database corruption is suspected:

1. Export your data first!
2. Go to **Settings** → **Advanced** → **Rebuild Database**
3. Import your data back

## Next Steps

- [Features Overview](../features/dashboard.md) - Explore all features
- [Architecture](../architecture/overview.md) - Understand the codebase
- [Development Guide](../development/adding-features.md) - Contribute to TrueCash
