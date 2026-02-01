# Windows Platform

TrueLedger for Windows is a native Win32 application optimized for the Windows 10/11 ecosystem.

## 🛠️ Technical Implementation

### 1. Persistence & Encryption
- **Database**: Uses `sqflite_common_ffi` with SQLCipher.
- **Key Management**: Encryption keys are stored using the **Data Protection API (DPAPI)** via `flutter_secure_storage`.

### 2. Dependencies
- **Visual Studio**: 2022 with "Desktop development with C++" workload.
- **MSIX**: Packaging for Windows Store is supported via the `msix` package.

## 🚀 Development & Build

### Run in Debug Mode
```bash
flutter run -d windows
```

### Build for Production (MSIX)
```bash
flutter build windows --release
flutter pub run msix:create
```

## 📋 Requirements
- **OS**: Windows 10 or later (versions prior to 10 are not officially supported).

## ⚠️ Known Implementation Details
- **Installation Directory**: For encryption to work reliably, ensure the application is installed in a directory where it has read/write access to its internal storage (usually handled by `path_provider`).
- **Dependencies**: The `sqlcipher.dll` must be present in the same directory as the executable for encryption support.
