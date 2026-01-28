#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
APP_NAME="USBDeviceInfo"

# Extract version from project.yml MARKETING_VERSION
VERSION=$(grep 'MARKETING_VERSION:' "$PROJECT_DIR/project.yml" | sed 's/.*MARKETING_VERSION: *"\([^"]*\)".*/\1/')

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/payload"

cd "$PROJECT_DIR"
xcodebuild -project USBDeviceInfo.xcodeproj -scheme USBDeviceInfo -configuration Release \
    -derivedDataPath "$BUILD_DIR/DerivedData" CONFIGURATION_BUILD_DIR="$BUILD_DIR/Release" \
    CODE_SIGN_IDENTITY="-" build 2>&1 | grep -E "(error:|BUILD)"

# Copy ONLY the .app bundle to payload directory
cp -R "$BUILD_DIR/Release/$APP_NAME.app" "$BUILD_DIR/payload/"

pkgbuild --root "$BUILD_DIR/payload" --identifier "com.company.USBDeviceInfo" \
    --version "$VERSION" --install-location "/Applications" "$BUILD_DIR/$APP_NAME-$VERSION.pkg"

echo "Package: $BUILD_DIR/$APP_NAME-$VERSION.pkg"
