# Android Platform

TrueLedger provides a standard native experience on Android with a focus on security and performance.

## 🛠️ Technical Implementation

### 1. Persistence & Encryption
- **Database**: Uses `sqflite_sqlcipher` for a fully encrypted SQLite database.
- **Key Management**: The encryption key is generated locally and stored in **Android Keystore** using the `flutter_secure_storage` plugin (using AES/RSA encryption).

### 2. Notifications
- **Plugin**: `flutter_local_notifications`.
- **Customization**: Uses a custom notification icon and supports daily reminders even when the app is in the background.

## 🚀 Development & Build

### Run in Debug Mode
```bash
flutter run -d <android-device-id>
```

### Build for Production (APK)
```bash
flutter build apk --release
```

### Build for Production (App Bundle)
```bash
flutter build appbundle --release
```

## 📋 Requirements
- **Min SDK**: 21 (Android 5.0)
- **Target SDK**: 34+
- **Architectures**: supports armeabi-v7a, arm64-v8a, and x86_64.

## ⚠️ Known Implementation Details
- **ProGuard/R8**: Ensure SQLCipher classes are not obfuscated (handled automatically by the plugin's default rules).
- **Permissions**: Requires standard `POST_NOTIFICATIONS` permission on Android 13+.
