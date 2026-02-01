# Linux Platform

TrueLedger provides a native GTK-based experience for Linux users, optimized for desktop usage.

## 🛠️ Technical Implementation

### 1. Persistence & Encryption
- **Database**: Uses `sqflite_common_ffi` with SQLCipher libraries.
- **Key Management**: The encryption key is stored using `libsecret` (GNOME Keyring or equivalent).

### 2. Native Dependencies
To build and run on Linux, the following system libraries are required:
```bash
sudo apt-get install \
  libsecret-1-dev \
  libjsoncpp-dev \
  libsqlite3-dev \
  libsqlcipher-dev \
  libssl-dev
```

## 🚀 Development & Build

### Run in Debug Mode
```bash
flutter run -d linux
```

### Build for Production
```bash
flutter build linux --release
```

## 📋 Requirements
- **GTK**: Version 3.0+
- **CMAKE**: Version 3.10+

## ⚠️ Known Implementation Details
- **App Directory**: Data is stored in `~/.local/share/trueledger/` by default (via `path_provider`).
- **Encryption Fallback**: If `sqlcipher` is not found during compilation, the app may fall back to standard SQLite (a warning is printed in debug mode).
