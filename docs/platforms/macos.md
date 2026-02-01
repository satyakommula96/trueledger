# macOS Platform

The macOS version of TrueLedger is a native AppKit application sharing the same core logic as mobile and desktop.

## 🛠️ Technical Implementation

### 1. Persistence & Encryption
- **Database**: Uses `sqflite_common_ffi` with SQLCipher.
- **Key Management**: Encryption keys are managed via the **macOS Keychain**.

### 2. Dependencies
- **Homebrew**: It is recommended to have `sqlcipher` installed via brew for local development.
```bash
brew install sqlcipher
```

## 🚀 Development & Build

### Run in Debug Mode
```bash
flutter run -d macos
```

### Build for Production
```bash
flutter build macos --release
```

## 📋 Requirements
- **macOS Version**: 10.14+
- **Xcode**: 14.0+

## ⚠️ Known Implementation Details
- **Sandboxing**: The app uses the macOS Sandbox. Ensure the `network.client` and `file.read/write` entitlements are enabled if you plan to use auto-backups to external folders.
- **Icon**: High-resolution (1024x1024) icons are bundled in the `.app` bundle.
