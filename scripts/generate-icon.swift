#!/usr/bin/env swift
import Cocoa

let sizes: [(Int, String)] = [
    (16, "icon_16x16.png"),
    (32, "icon_16x16@2x.png"),
    (32, "icon_32x32.png"),
    (64, "icon_32x32@2x.png"),
    (128, "icon_128x128.png"),
    (256, "icon_128x128@2x.png"),
    (256, "icon_256x256.png"),
    (512, "icon_256x256@2x.png"),
    (512, "icon_512x512.png"),
    (1024, "icon_512x512@2x.png")
]

let scriptPath = CommandLine.arguments[0]
let scriptDir = (scriptPath as NSString).deletingLastPathComponent
let projectDir = (scriptDir as NSString).deletingLastPathComponent
let iconDir = "\(projectDir)/USBDeviceInfo/Assets.xcassets/AppIcon.appiconset"

func createIcon(size: Int) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    let rect = NSRect(x: 0, y: 0, width: size, height: size)

    // Background gradient (blue)
    let gradient = NSGradient(colors: [
        NSColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1.0),
        NSColor(red: 0.1, green: 0.3, blue: 0.7, alpha: 1.0)
    ])!

    let path = NSBezierPath(roundedRect: rect.insetBy(dx: CGFloat(size) * 0.05, dy: CGFloat(size) * 0.05),
                            xRadius: CGFloat(size) * 0.2, yRadius: CGFloat(size) * 0.2)
    gradient.draw(in: path, angle: -45)

    // USB symbol using SF Symbol
    if let symbol = NSImage(systemSymbolName: "externaldrive.connected.to.line.below", accessibilityDescription: nil) {
        let config = NSImage.SymbolConfiguration(pointSize: CGFloat(size) * 0.45, weight: .medium)
        let configuredSymbol = symbol.withSymbolConfiguration(config)!

        let symbolSize = configuredSymbol.size
        let x = (CGFloat(size) - symbolSize.width) / 2
        let y = (CGFloat(size) - symbolSize.height) / 2

        NSColor.white.setFill()
        configuredSymbol.draw(at: NSPoint(x: x, y: y), from: .zero, operation: .sourceOver, fraction: 1.0)
    }

    image.unlockFocus()
    return image
}

for (size, filename) in sizes {
    let image = createIcon(size: size)
    let tiffData = image.tiffRepresentation!
    let bitmap = NSBitmapImageRep(data: tiffData)!
    let pngData = bitmap.representation(using: .png, properties: [:])!
    let path = "\(iconDir)/\(filename)"
    try! pngData.write(to: URL(fileURLWithPath: path))
    print("Created: \(filename)")
}

print("Icons generated in: \(iconDir)")
