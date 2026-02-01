# iOS Platform

TrueLedger on iOS leverages native system capabilities for security and smooth animations.

## 🛠️ Technical Implementation

### 1. Persistence & Encryption
- **Database**: Uses `sqflite_sqlcipher` for a fully encrypted SQLite database.
- **Key Management**: The encryption key is stored in the **iOS Keychain**.

### 2. Notifications
- **Requesting Permission**: Triggered via the `notificationServiceProvider`.
- **Handling Click**: Deep-linking from notifications to specific screens (Dashboard/Cards) is supported.

## 🚀 Development & Build

### Run in Debug Mode
```bash
flutter run -d <ios-device-id>
```

### Build for Production (IPA)
```bash
flutter build ios --release
```

## 📋 Requirements
- **Min iOS Version**: 13.0
- **CocoaPods**: Ensure you run `pod install` in the `ios` directory before building.

## ⚠️ Known Implementation Details
- **Architecture**: Supports both physical devices (arm64) and simulators (x86_64/arm64).
- **Entitlements**: Uses standard keychain sharing if needed (current config is default).
