#!/bin/bash

# TrueLedger Version Update Script
# Usage: ./scripts/release.sh <version> <build_number>
# Example: ./scripts/release.sh 1.4.2 13

set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 <version> <build_number>"
    echo "Example: $0 1.4.2 13"
    exit 1
fi

VERSION=$1
BUILD=$2
FULL_VERSION="$VERSION+$BUILD"
MSIX_VERSION="$VERSION.0"

echo "🚀 Updating version to v$FULL_VERSION..."

# 1. Update lib/core/config/version.dart
sed -i "s/static const String current = '.*';/static const String current = '$VERSION';/" lib/core/config/version.dart

# 2. Update pubspec.yaml
sed -i "s/^version: .*/version: $FULL_VERSION/" pubspec.yaml
sed -i "s/msix_version: .*/msix_version: $MSIX_VERSION/" pubspec.yaml

echo "✅ Versions updated successfully!"
