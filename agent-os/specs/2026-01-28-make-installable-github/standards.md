# Applied Standards

## macos/intune-pkg

The existing `scripts/build-pkg.sh` already implements the `macos/intune-pkg` standard:

### Requirements Met

1. **Flat .pkg format**: Uses `pkgbuild` to create a flat package
2. **Install location**: `/Applications` (standard location)
3. **Bundle identifier**: `com.company.USBDeviceInfo`
4. **Version in filename**: `USBDeviceInfo-{version}.pkg`
5. **No preinstall/postinstall scripts**: Simple payload-only package

### Build Process

```bash
# Build the app
xcodebuild -project USBDeviceInfo.xcodeproj -scheme USBDeviceInfo \
    -configuration Release build

# Create the .pkg
pkgbuild --root "$BUILD_DIR/payload" \
    --identifier "com.company.USBDeviceInfo" \
    --version "$VERSION" \
    --install-location "/Applications" \
    "$BUILD_DIR/$APP_NAME-$VERSION.pkg"
```

### Intune Deployment

The .pkg can be deployed via Intune as a macOS LOB app:
- Upload the .pkg to Intune
- Assign to device groups
- MDM handles installation approval for ad-hoc signed apps
