#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
APP_NAME="USBDeviceInfo"

# Extract version from Git tag (v1.0.2 → 1.0.2), fallback to project.yml
VERSION=$(git describe --tags --exact-match 2>/dev/null | sed 's/^v//' || \
          grep 'MARKETING_VERSION:' "$PROJECT_DIR/project.yml" | sed 's/.*MARKETING_VERSION: *"\([^"]*\)".*/\1/')
echo "Building version: $VERSION"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/payload"

cd "$PROJECT_DIR"
xcodebuild -project USBDeviceInfo.xcodeproj -scheme USBDeviceInfo -configuration Release \
    -derivedDataPath "$BUILD_DIR/DerivedData" CONFIGURATION_BUILD_DIR="$BUILD_DIR/Release" \
    CODE_SIGN_IDENTITY="-" MARKETING_VERSION="$VERSION" build 2>&1 | grep -E "(error:|BUILD)"

# Copy ONLY the .app bundle to payload directory
cp -R "$BUILD_DIR/Release/$APP_NAME.app" "$BUILD_DIR/payload/"

# Create component plist to disable relocation
cat > "$BUILD_DIR/component.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
    <dict>
        <key>BundleHasStrictIdentifier</key>
        <true/>
        <key>BundleIsRelocatable</key>
        <false/>
        <key>BundleIsVersionChecked</key>
        <false/>
        <key>BundleOverwriteAction</key>
        <string>upgrade</string>
        <key>RootRelativeBundlePath</key>
        <string>USBDeviceInfo.app</string>
    </dict>
</array>
</plist>
PLIST

pkgbuild --root "$BUILD_DIR/payload" --identifier "com.company.USBDeviceInfo" \
    --version "$VERSION" --install-location "/Applications" \
    --component-plist "$BUILD_DIR/component.plist" \
    "$BUILD_DIR/$APP_NAME-$VERSION.pkg"

echo "Package: $BUILD_DIR/$APP_NAME-$VERSION.pkg"
