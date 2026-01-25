# Installation Guide

Get TrueCash up and running on your platform of choice.

## Prerequisites

- **Flutter SDK**: Version 3.0 or higher
- **Dart SDK**: Version 3.0 or higher
- **Platform-specific tools**:
  - **Android**: Android Studio with Android SDK
  - **iOS**: Xcode (macOS only)
  - **Linux**: `libsecret-1-dev`, `libjsoncpp-dev`
  - **macOS**: Xcode Command Line Tools
  - **Windows**: Visual Studio 2022 with C++ tools
  - **Web**: Chrome or Edge browser

## Quick Install

### 1. Clone the Repository

```bash
git clone https://github.com/satyakommula96/truecash.git
cd truecash
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Platform-Specific Setup

=== "Android"

    ```bash
    # No additional setup required
    flutter run -d android
    ```

=== "iOS"

    ```bash
    cd ios
    pod install
    cd ..
    flutter run -d ios
    ```

=== "Linux"

    ```bash
    # Install dependencies
    sudo apt-get update
    sudo apt-get install -y \
      libsecret-1-dev \
      libjsoncpp-dev \
      libsqlite3-dev \
      libsqlcipher-dev \
      libssl-dev
    
    flutter run -d linux
    ```

=== "macOS"

    ```bash
    # Ensure Xcode Command Line Tools are installed
    xcode-select --install
    
    # Install SQLCipher for database encryption
    brew install sqlcipher
    
    flutter run -d macos
    ```

=== "Windows"

    ```bash
    # Ensure Visual Studio 2022 with C++ tools is installed
    # Note: For encryption, provide sqlcipher.dll (e.g., from Zetetic or vcpkg) in the application directory
    flutter run -d windows
    ```

=== "Web"

    ```bash
    flutter run -d chrome
    ```

## Verify Installation

Run the test suite to ensure everything is working:

```bash
flutter test
```

All 21 tests should pass:
- ✅ 19 Unit tests
- ✅ 1 Widget test
- ✅ 1 Integration test

## Build for Production

### Android APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### iOS IPA

```bash
flutter build ios --release
```

Then use Xcode to create an archive and export the IPA.

### Linux

```bash
flutter build linux --release
```

Output: `build/linux/x64/release/bundle/`

### macOS

```bash
flutter build macos --release
```

Output: `build/macos/Build/Products/Release/truecash.app`

### Windows

```bash
flutter build windows --release
```

Output: `build/windows/runner/Release/`

### Web

```bash
flutter build web --release
```

Output: `build/web/`

## Troubleshooting

### Common Issues

#### "Flutter SDK not found"
```bash
# Add Flutter to PATH
export PATH="$PATH:/path/to/flutter/bin"
```

#### "Android licenses not accepted"
```bash
flutter doctor --android-licenses
```

#### "CocoaPods not installed" (iOS/macOS)
```bash
sudo gem install cocoapods
```

#### "libsecret not found" (Linux)
```bash
sudo apt-get install libsecret-1-dev
```

### Still Having Issues?

1. Run `flutter doctor` to diagnose problems
2. Check the [GitHub Issues](https://github.com/satyakommula96/truecash/issues)
3. Review platform-specific guides in the [Platforms](../platforms/android.md) section

## Next Steps

- [Quick Start Guide](quick-start.md) - Learn the basics
- [Configuration](configuration.md) - Customize your setup
- [Architecture Overview](../architecture/overview.md) - Understand the codebase
