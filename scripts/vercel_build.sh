#!/bin/bash

# Exit on error
set -e

# Clone Flutter if it doesn't exist
if [ ! -d "flutter" ]; then
    echo "Cloning Flutter stable branch..."
    git clone --depth 1 https://github.com/flutter/flutter.git -b stable
fi

# Add Flutter to path
export PATH="$PATH:$(pwd)/flutter/bin"

# Build Setup
echo "Initializing Flutter..."
flutter doctor
flutter config --enable-web

echo "Getting dependencies..."
flutter pub get

echo "Building web application..."
flutter build web --debug --no-pub
