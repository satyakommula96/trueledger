#!/bin/bash

# Exit on error
set -e

APP_NAME="trueledger"
# Extract version from pubspec.yaml (e.g., 1.0.0 from 1.0.0+1)
VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //; s/+.*//')
ARCH="amd64"
MAINTAINER="Satya Kommula"
DESCRIPTION="TrueLedger: Premium Financial Management Application"

echo "Building Flutter application..."
flutter build linux --release

# Define build directory
BUILD_DIR="build/linux/x64/release/bundle"
DEB_DIR="build/deb"
APP_DIR="$DEB_DIR/usr/lib/$APP_NAME"
BIN_DIR="$DEB_DIR/usr/bin"
ICON_DIR="$DEB_DIR/usr/share/icons/hicolor/512x512/apps"
DESKTOP_DIR="$DEB_DIR/usr/share/applications"

# Clean previous build
rm -rf "$DEB_DIR"
mkdir -p "$APP_DIR"
mkdir -p "$BIN_DIR"
mkdir -p "$ICON_DIR"
mkdir -p "$DESKTOP_DIR"
mkdir -p "$DEB_DIR/DEBIAN"

echo "Copying application files..."
cp -r "$BUILD_DIR/"* "$APP_DIR/"

echo "Creating launcher script..."
cat > "$BIN_DIR/$APP_NAME" << EOF
#!/bin/bash
/usr/lib/$APP_NAME/$APP_NAME "\$@"
EOF
chmod +x "$BIN_DIR/$APP_NAME"

echo "Copying icon..."
# Assuming we have a logo.png. If not, this step might fail or need adjustment.
# Based on pubspec, it's at assets/images/logo.png
if [ -f "assets/icon/trueledger_icon.png" ]; then
    cp "assets/icon/trueledger_icon.png" "$ICON_DIR/$APP_NAME.png"
else
    echo "Warning: Icon not found at assets/icon/trueledger_icon.png"
fi

echo "Creating desktop entry..."
cat > "$DESKTOP_DIR/$APP_NAME.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=TrueLedger
Comment=$DESCRIPTION
Exec=$APP_NAME
Icon=$APP_NAME
Categories=Office;Finance;
Terminal=false
StartupNotify=true
EOF

echo "Creating control file..."
cat > "$DEB_DIR/DEBIAN/control" << EOF
Package: $APP_NAME
Version: $VERSION
Architecture: $ARCH
Maintainer: $MAINTAINER
Description: $DESCRIPTION
Depends: libgtk-3-0, libblkid1, liblzma5
EOF

echo "Building .deb package..."
dpkg-deb --build "$DEB_DIR" "TrueLedger.deb"

echo "Done! Package saved as TrueLedger.deb"
