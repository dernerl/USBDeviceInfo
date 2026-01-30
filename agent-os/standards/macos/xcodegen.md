# XcodeGen for macOS Apps

Use `project.yml` instead of committing `.xcodeproj`.

```yaml
name: AppName
options:
  bundleIdPrefix: com.company
  deploymentTarget:
    macOS: "15.0"

settings:
  base:
    SWIFT_VERSION: "6.0"
    ENABLE_APP_SANDBOX: NO      # Required for IOKit access
    ENABLE_HARDENED_RUNTIME: YES

targets:
  AppName:
    type: application
    platform: macOS
    sources:
      - path: AppName
    dependencies:
      - sdk: IOKit.framework
```

- Run `xcodegen generate` after changes
- Commit `project.yml`, gitignore `.xcodeproj/xcuserdata/`
- Benefits: Readable diffs, no merge conflicts
