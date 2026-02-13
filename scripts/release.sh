#!/bin/bash

# TrueLedger Release Script
# Usage: ./scripts/release.sh <version> <build_number>
# Example: ./scripts/release.sh 1.4.2 13

set -euo pipefail

if [ $# -ne 2 ]; then
    echo "Usage: $0 <version> <build_number>"
    echo "Example: $0 1.4.2 13"
    exit 1
fi

VERSION=$1
BUILD=$2
FULL_VERSION="$VERSION+$BUILD"
MSIX_VERSION="$VERSION.0"
TAG="v$FULL_VERSION"

echo "Updating version to $FULL_VERSION"

# Ensure working tree is clean
if [ -n "$(git status --porcelain)" ]; then
    echo "Working tree is not clean. Commit or stash changes first."
    exit 1
fi

# Fail if tag already exists
if git rev-parse "$TAG" >/dev/null 2>&1; then
    echo "Tag $TAG already exists."
    exit 1
fi

# 1. Update Dart version file
sed -i "s/static const String current = '.*';/static const String current = '$VERSION';/" lib/core/config/version.dart

# 2. Update pubspec.yaml
sed -i "s/^version: .*/version: $FULL_VERSION/" pubspec.yaml
sed -i "s/msix_version: .*/msix_version: $MSIX_VERSION/" pubspec.yaml

echo "Version files updated"

# Commit changes
git add lib/core/config/version.dart pubspec.yaml
git commit -m "release: $TAG"

# Create annotated tag
git tag -a "$TAG" -m "Release $TAG"

echo "Release commit and tag created:"
echo "  Commit: $(git rev-parse --short HEAD)"
echo "  Tag:    $TAG"

echo "To push:"
echo "  git push origin main"
echo "  git push origin $TAG"
