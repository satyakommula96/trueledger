#!/bin/bash
set -e

APP_NAME="TrueCash"
VERSION="1.1.0"
DMG_NAME="${APP_NAME}_${VERSION}_macos.dmg"

echo "Building macOS app..."
flutter build macos --release

APP_PATH="build/macos/Build/Products/Release/TrueCash.app"

if [ ! -d "$APP_PATH" ]; then
  echo "Error: App bundle not found at $APP_PATH"
  exit 1
fi

echo "Creating DMG..."
# Check if create-dmg is installed, if not try to install it (brew is available on macos runners)
if ! command -v create-dmg &> /dev/null; then
    echo "create-dmg could not be found, attempting to install..."
    if command -v brew &> /dev/null; then
        brew install create-dmg
    else
        echo "Error: brew not found. Cannot install create-dmg."
        # Fallback to simple hdiutil if create-dmg is missing is complex, 
        # so for now we fail if we can't make a nice one, or we could do a simple read-only image using hdiutil.
        echo "Falling back to basic hdiutil..."
        hdiutil create -volname "$APP_NAME" -srcfolder "$APP_PATH" -ov -format UDZO "$DMG_NAME"
        echo "DMG created at $DMG_NAME"
        exit 0
    fi
fi

# Create a nice DMG with create-dmg
create-dmg \
  --volname "$APP_NAME" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --icon "TrueCash.app" 200 190 \
  --hide-extension "TrueCash.app" \
  --app-drop-link 600 185 \
  "$DMG_NAME" \
  "$APP_PATH"

echo "Done! DMG saved as $DMG_NAME"
