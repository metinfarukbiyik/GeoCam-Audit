#!/usr/bin/env swift
import AppKit
import Foundation

/// GeoCam uygulama ikonu ve açılış logosu üretir.
/// Motif: kamera gövdesi + konum iğnesi, petrol yeşili zemin.

let assetsRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    .appendingPathComponent("GeoCam/Resources/Assets.xcassets")

struct Palette {
    let top: NSColor
    let bottom: NSColor
    let accent: NSColor
    let lens: NSColor
}

let lightPalette = Palette(
    top: NSColor(calibratedRed: 0.07, green: 0.30, blue: 0.32, alpha: 1),
    bottom: NSColor(calibratedRed: 0.02, green: 0.13, blue: 0.17, alpha: 1),
    accent: NSColor(calibratedRed: 0.35, green: 0.90, blue: 0.78, alpha: 1),
    lens: NSColor(calibratedRed: 0.10, green: 0.42, blue: 0.46, alpha: 1)
)

let darkPalette = Palette(
    top: NSColor(calibratedRed: 0.04, green: 0.16, blue: 0.18, alpha: 1),
    bottom: NSColor(calibratedRed: 0.01, green: 0.07, blue: 0.09, alpha: 1),
    accent: NSColor(calibratedRed: 0.42, green: 0.93, blue: 0.82, alpha: 1),
    lens: NSColor(calibratedRed: 0.12, green: 0.38, blue: 0.42, alpha: 1)
)

func makeBitmap(size: Int) -> NSBitmapImageRep {
    NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size,
        pixelsHigh: size,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
}

func drawIcon(size: Int, palette: Palette, opaqueBackground: Bool) -> NSBitmapImageRep {
    let rep = makeBitmap(size: size)
    NSGraphicsContext.saveGraphicsState()
    let graphics = NSGraphicsContext(bitmapImageRep: rep)!
    graphics.imageInterpolation = .high
    NSGraphicsContext.current = graphics

    let context = graphics.cgContext
    let s = CGFloat(size)

    // Bitmap sol-üst orijinli; y aşağı artar. Tüm çizim bu sistemde yapılır.
    if opaqueBackground {
        let colors = [palette.top.cgColor, palette.bottom.cgColor]
        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: colors as CFArray,
            locations: [0, 1]
        )!
        context.drawLinearGradient(
            gradient,
            start: .zero,
            end: CGPoint(x: s, y: s),
            options: []
        )

        context.setFillColor(NSColor.white.withAlphaComponent(0.06).cgColor)
        context.fillEllipse(in: CGRect(x: -s * 0.1, y: s * 0.55, width: s * 0.9, height: s * 0.7))
    } else {
        context.clear(CGRect(x: 0, y: 0, width: s, height: s))
    }

    // Kamera gövdesi
    let cameraRect = CGRect(x: s * 0.17, y: s * 0.34, width: s * 0.52, height: s * 0.34)
    context.setFillColor(NSColor.white.withAlphaComponent(0.96).cgColor)
    context.addPath(CGPath(
        roundedRect: cameraRect,
        cornerWidth: s * 0.08,
        cornerHeight: s * 0.08,
        transform: nil
    ))
    context.fillPath()

    // Üst vizör
    let bump = CGRect(x: s * 0.28, y: s * 0.27, width: s * 0.18, height: s * 0.10)
    context.addPath(CGPath(
        roundedRect: bump,
        cornerWidth: s * 0.03,
        cornerHeight: s * 0.03,
        transform: nil
    ))
    context.fillPath()

    let lensCenter = CGPoint(x: s * 0.43, y: s * 0.51)
    fillCircle(context, center: lensCenter, radius: s * 0.105, color: palette.lens)
    fillCircle(context, center: lensCenter, radius: s * 0.068, color: palette.accent)
    fillCircle(context, center: lensCenter, radius: s * 0.032, color: palette.bottom)

    // Konum iğnesi: uç aşağı bakar.
    drawPin(
        in: context,
        tip: CGPoint(x: s * 0.72, y: s * 0.78),
        headCenter: CGPoint(x: s * 0.72, y: s * 0.48),
        headRadius: s * 0.095,
        color: palette.accent
    )

    NSGraphicsContext.restoreGraphicsState()
    return rep
}

func fillCircle(_ context: CGContext, center: CGPoint, radius: CGFloat, color: NSColor) {
    context.setFillColor(color.cgColor)
    context.fillEllipse(in: CGRect(
        x: center.x - radius,
        y: center.y - radius,
        width: radius * 2,
        height: radius * 2
    ))
}

func drawPin(
    in context: CGContext,
    tip: CGPoint,
    headCenter: CGPoint,
    headRadius: CGFloat,
    color: NSColor
) {
    context.setFillColor(color.cgColor)

    let path = CGMutablePath()
    path.move(to: tip)
    path.addLine(to: CGPoint(x: headCenter.x - headRadius * 0.78, y: headCenter.y + headRadius * 0.2))
    path.addArc(
        center: headCenter,
        radius: headRadius,
        startAngle: .pi * 0.85,
        endAngle: .pi * 0.15,
        clockwise: true
    )
    path.closeSubpath()
    context.addPath(path)
    context.fillPath()

    fillCircle(context, center: headCenter, radius: headRadius, color: color)
    fillCircle(context, center: headCenter, radius: headRadius * 0.45, color: .white)
    fillCircle(context, center: headCenter, radius: headRadius * 0.24, color: color)
}

func writePNG(_ rep: NSBitmapImageRep, to url: URL) throws {
    // NSBitmapImageRep satırları ters yazabildiği için CGImage üzerinden
    // dikey ekseni düzeltilmiş bir kopya kaydedilir.
    guard let source = rep.cgImage else {
        throw NSError(domain: "GenerateAppIcon", code: 1)
    }

    let width = source.width
    let height = source.height
    let colorSpace = source.colorSpace ?? CGColorSpaceCreateDeviceRGB()
    guard let context = CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: source.bitsPerComponent,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        throw NSError(domain: "GenerateAppIcon", code: 2)
    }

    context.translateBy(x: 0, y: CGFloat(height))
    context.scaleBy(x: 1, y: -1)
    context.draw(source, in: CGRect(x: 0, y: 0, width: width, height: height))

    guard let flipped = context.makeImage() else {
        throw NSError(domain: "GenerateAppIcon", code: 3)
    }

    let finalRep = NSBitmapImageRep(cgImage: flipped)
    guard let data = finalRep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "GenerateAppIcon", code: 4)
    }

    try FileManager.default.createDirectory(
        at: url.deletingLastPathComponent(),
        withIntermediateDirectories: true
    )
    try data.write(to: url)
    FileHandle.standardError.write(Data("Wrote \(url.path)\n".utf8))
}

let iconSet = assetsRoot.appendingPathComponent("AppIcon.appiconset")
try writePNG(drawIcon(size: 1024, palette: lightPalette, opaqueBackground: true), to: iconSet.appendingPathComponent("AppIcon.png"))
try writePNG(drawIcon(size: 1024, palette: darkPalette, opaqueBackground: true), to: iconSet.appendingPathComponent("AppIcon-Dark.png"))
try writePNG(drawIcon(size: 1024, palette: lightPalette, opaqueBackground: true), to: iconSet.appendingPathComponent("AppIcon-Tinted.png"))

let launchSet = assetsRoot.appendingPathComponent("LaunchLogo.imageset")
try writePNG(drawIcon(size: 512, palette: lightPalette, opaqueBackground: false), to: launchSet.appendingPathComponent("LaunchLogo.png"))

print("OK")
