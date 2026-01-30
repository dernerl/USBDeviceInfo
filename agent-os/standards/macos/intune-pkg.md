# Intune .pkg Packaging

Create installer packages for Microsoft Intune deployment.

## Build Script (`scripts/build-pkg.sh`)

```bash
#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
APP_NAME="AppName"
VERSION="1.0"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/payload"

xcodebuild -project $APP_NAME.xcodeproj -scheme $APP_NAME -configuration Release \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    CONFIGURATION_BUILD_DIR="$BUILD_DIR/Release" \
    CODE_SIGN_IDENTITY="-" build

# Copy ONLY .app (not .dSYM or .swiftmodule)
cp -R "$BUILD_DIR/Release/$APP_NAME.app" "$BUILD_DIR/payload/"

pkgbuild --root "$BUILD_DIR/payload" \
    --identifier "com.company.$APP_NAME" \
    --version "$VERSION" \
    --install-location "/Applications" \
    "$BUILD_DIR/$APP_NAME-$VERSION.pkg"
```

## Key Points

- Use `payload/` dir with only `.app` — avoids installing debug symbols
- `CODE_SIGN_IDENTITY="-"` = ad-hoc signing (works for Intune without paid cert)
- Install location: `/Applications`
- Upload `.pkg` to Intune as macOS LOB app
