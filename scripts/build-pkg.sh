#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
APP_NAME="USBDeviceInfo"
VERSION="1.0"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

cd "$PROJECT_DIR"
xcodebuild -project USBDeviceInfo.xcodeproj -scheme USBDeviceInfo -configuration Release \
    -derivedDataPath "$BUILD_DIR/DerivedData" CONFIGURATION_BUILD_DIR="$BUILD_DIR/Release" \
    CODE_SIGN_IDENTITY="-" build 2>&1 | grep -E "(error:|BUILD)"

pkgbuild --root "$BUILD_DIR/Release" --identifier "com.company.USBDeviceInfo" \
    --version "$VERSION" --install-location "/Applications" "$BUILD_DIR/$APP_NAME-$VERSION.pkg"

echo "Package: $BUILD_DIR/$APP_NAME-$VERSION.pkg"
