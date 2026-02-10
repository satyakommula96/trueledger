#!/bin/bash

# Pre-commit hook to ensure code quality
echo "--- Running Pre-Commit Checks ---"

# Detect if any source code or dependency files have changed
# We check: .dart files, pubspec.yaml, pubspec.lock, and analysis_options.yaml
CHANGED_CODE_FILES=$(git diff --cached --name-only | grep -E '\.dart$|pubspec\.yaml$|pubspec\.lock$|analysis_options\.yaml$')

if [ -z "$CHANGED_CODE_FILES" ]; then
    echo "⏭️  No source code changes detected. Skipping code quality checks."
    exit 0
fi

# 1. Format Check
echo "Step 1: Checking formatting..."
dart format --set-exit-if-changed .
if [ $? -ne 0 ]; then
    echo "❌ Formatting failed. Run 'dart format .' to fix."
    exit 1
fi

# 2. Analysis Check
echo "Step 2: Running static analysis..."
flutter analyze
if [ $? -ne 0 ]; then
    echo "❌ Analysis failed. Fix the issues before committing."
    exit 1
fi

# 3. Test Check
echo "Step 3: Running widget and unit tests..."
flutter test
if [ $? -ne 0 ]; then
    echo "❌ Tests failed. Ensure all tests pass before committing."
    exit 1
fi

echo "✅ All checks passed! Proceeding with commit..."
exit 0

