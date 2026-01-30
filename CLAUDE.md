# Arbeitsweise

Immer die Agent-OS Aktionen empfehlen wenn sinnvoll!


# USBDeviceInfo

## Projekt-Übersicht
- **Typ**: macOS App (Swift/SwiftUI)
- **Xcode Projekt**: `USBDeviceInfo.xcodeproj`
- **Ziel**: Anzeige von Informationen über angeschlossene USB-Geräte

## Git & GitHub
- **Repository**: https://github.com/dernerl/USBDeviceInfo
- **Branch**: main
- **Releases**: Über GitHub Actions Pipeline
- **Versionierung**: Semantic Versioning (vX.Y.Z Tags triggern die Pipeline)

## Build & Release
- Pipeline wird durch Git Tags getriggert (z.B. `v1.0.1`)
- Erzeugt signierte PKG-Datei als GitHub Release
- App ist nicht mit Apple Developer Zertifikat signiert

## Projektstruktur
```
USBDeviceInfo/
├── USBDeviceInfo.xcodeproj/
├── USBDeviceInfo/
│   ├── Assets.xcassets/
│   │   └── AppIcon.appiconset/
│   └── *.swift
└── README.md
```
