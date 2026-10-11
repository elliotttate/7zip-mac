// Original macOS archive artwork, drawn from vector paths at every output size. CC0.
// Usage: swift make-native-icons.swift <icons-manifest.json> <png-directory>
import AppKit
import ImageIO

struct NativeManifest: Decodable {
    struct Icon: Decodable { let name: String; let extensions: [String] }
    let icons: [Icon]
}

func color(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> NSColor {
    NSColor(srgbRed: r, green: g, blue: b, alpha: a)
}

func rounded(_ rect: NSRect, _ radius: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
}

func gradient(_ path: NSBezierPath, _ top: NSColor, _ bottom: NSColor) {
    NSGradient(starting: bottom, ending: top)!.draw(in: path, angle: 90)
}

func archive(in rect: NSRect, tint: NSColor, app: Bool, detailed: Bool) {
    let x = rect.minX, y = rect.minY, w = rect.width, h = rect.height
    let body = rounded(NSRect(x: x + w * 0.035, y: y, width: w * 0.93, height: h * 0.83), w * 0.075)
    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = color(0.02, 0.12, 0.25, app ? 0.27 : 0.16)
    shadow.shadowBlurRadius = w * 0.045
    shadow.shadowOffset = NSSize(width: 0, height: -h * 0.035)
    shadow.set()
    gradient(body, app ? color(0.96, 0.99, 1) : tint.blended(withFraction: 0.20, of: .white)!,
             app ? color(0.74, 0.88, 0.98) : tint)
    NSGraphicsContext.restoreGraphicsState()
    let lid = rounded(NSRect(x: x, y: y + h * 0.76, width: w, height: h * 0.24), w * 0.055)
    gradient(lid, app ? .white : tint.blended(withFraction: 0.4, of: .white)!,
             app ? color(0.85, 0.94, 1) : tint.blended(withFraction: 0.12, of: .white)!)
    color(1, 1, 1, 0.65).setStroke()
    lid.lineWidth = w * 0.004
    lid.stroke()
    let band = NSRect(x: x + w * 0.44, y: y, width: w * 0.12, height: h)
    gradient(rounded(band, w * 0.012), app ? color(0.26, 0.57, 0.79) : tint.blended(withFraction: 0.25, of: .black)!,
             app ? color(0.15, 0.37, 0.58) : tint.blended(withFraction: 0.40, of: .black)!)
    if detailed {
        for i in 0..<11 {
            let tooth = NSRect(x: band.minX + (i % 2 == 0 ? w * 0.018 : w * 0.06),
                               y: y + h * 0.06 + CGFloat(i) * h * 0.058, width: w * 0.044, height: h * 0.024)
            color(0.88, 0.96, 1).setFill()
            rounded(tooth, w * 0.005).fill()
        }
        let pull = rounded(NSRect(x: x + w * 0.452, y: y + h * 0.67, width: w * 0.096, height: h * 0.18), w * 0.024)
        gradient(pull, color(0.99, 1, 1), color(0.63, 0.79, 0.88))
        color(0.20, 0.42, 0.56).setFill()
        rounded(NSRect(x: x + w * 0.475, y: y + h * 0.71, width: w * 0.05, height: h * 0.045), w * 0.014).fill()
    }
}

func render(size: Int, label: String?, to url: URL) throws {
    let ctx = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: size * 4,
                        space: CGColorSpace(name: CGColorSpace.sRGB)!,
                        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.scaleBy(x: CGFloat(size) / 1024, y: CGFloat(size) / 1024)
    let previous = NSGraphicsContext.current
    NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: false)
    defer { NSGraphicsContext.current = previous }
    let isApp = label == nil
    if isApp {
        let tile = rounded(NSRect(x: 85, y: 85, width: 854, height: 854), 190)
        let shadow = NSShadow()
        shadow.shadowColor = color(0.02, 0.12, 0.22, 0.25)
        shadow.shadowBlurRadius = 24
        shadow.shadowOffset = NSSize(width: 0, height: -10)
        NSGraphicsContext.saveGraphicsState()
        shadow.set()
        gradient(tile, color(0.31, 0.80, 0.98), color(0.03, 0.34, 0.72))
        NSGraphicsContext.restoreGraphicsState()
        tile.addClip()
        let glow = NSBezierPath(ovalIn: NSRect(x: -180, y: 440, width: 1150, height: 790))
        gradient(glow, color(0.66, 0.96, 1, 0.42), color(0.29, 0.69, 1, 0))
        color(1, 1, 1, 0.28).setStroke()
        tile.lineWidth = 3
        tile.stroke()
        archive(in: NSRect(x: 236, y: 278, width: 552, height: 452),
                tint: color(0.14, 0.56, 0.83), app: true, detailed: size >= 32)
    } else {
        let paper = NSBezierPath()
        paper.move(to: NSPoint(x: 245, y: 106))
        paper.curve(to: NSPoint(x: 196, y: 155), controlPoint1: NSPoint(x: 213, y: 106), controlPoint2: NSPoint(x: 196, y: 124))
        paper.line(to: NSPoint(x: 196, y: 865))
        paper.curve(to: NSPoint(x: 245, y: 914), controlPoint1: NSPoint(x: 196, y: 896), controlPoint2: NSPoint(x: 213, y: 914))
        paper.line(to: NSPoint(x: 657, y: 914))
        paper.line(to: NSPoint(x: 828, y: 743))
        paper.line(to: NSPoint(x: 828, y: 155))
        paper.curve(to: NSPoint(x: 779, y: 106), controlPoint1: NSPoint(x: 828, y: 124), controlPoint2: NSPoint(x: 810, y: 106))
        paper.close()
        let shadow = NSShadow()
        shadow.shadowColor = color(0.12, 0.20, 0.31, 0.2)
        shadow.shadowBlurRadius = 20
        shadow.shadowOffset = NSSize(width: 0, height: -6)
        NSGraphicsContext.saveGraphicsState()
        shadow.set()
        gradient(paper, .white, color(0.91, 0.94, 0.97))
        NSGraphicsContext.restoreGraphicsState()
        color(0.62, 0.69, 0.76, 0.5).setStroke()
        paper.lineWidth = 4
        paper.stroke()
        let fold = NSBezierPath()
        fold.move(to: NSPoint(x: 657, y: 914))
        fold.line(to: NSPoint(x: 657, y: 775))
        fold.curve(to: NSPoint(x: 689, y: 743), controlPoint1: NSPoint(x: 657, y: 753), controlPoint2: NSPoint(x: 667, y: 743))
        fold.line(to: NSPoint(x: 828, y: 743))
        fold.close()
        gradient(fold, color(0.90, 0.94, 0.97), color(0.78, 0.85, 0.92))
        let ext = label!.uppercased()
        let tint: NSColor
        switch ext {
        case "ZIP": tint = color(0.17, 0.61, 0.69)
        case "RAR": tint = color(0.50, 0.41, 0.77)
        case "TAR", "GZ", "BZ2", "XZ": tint = color(0.79, 0.53, 0.25)
        case "DMG", "ISO", "WIM": tint = color(0.36, 0.50, 0.63)
        default: tint = color(0.16, 0.51, 0.81)
        }
        archive(in: NSRect(x: 322, y: size >= 64 ? 338 : 245, width: 380, height: 320),
                tint: tint, app: false, detailed: size >= 64)
        if size >= 64 {
            let font = NSFont.systemFont(ofSize: ext.count > 4 ? 76 : 92, weight: .semibold)
            let text = NSAttributedString(string: ext, attributes: [.font: font, .foregroundColor: color(0.30, 0.39, 0.48), .kern: 3])
            text.draw(at: NSPoint(x: 512 - text.size().width / 2, y: 175))
        }
    }
    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    let destination = CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil)!
    CGImageDestinationAddImage(destination, ctx.makeImage()!, nil)
    guard CGImageDestinationFinalize(destination) else { fatalError("PNG write failed") }
}

let args = Array(CommandLine.arguments.dropFirst())
guard args.count == 2 else { fatalError("expected manifest and PNG directory") }
let manifest = try JSONDecoder().decode(NativeManifest.self, from: Data(contentsOf: URL(fileURLWithPath: args[0])))
for size in [16, 32, 64, 128, 256, 512, 1024] {
    try render(size: size, label: nil, to: URL(fileURLWithPath: args[1] + "/app/\(size).png"))
    for entry in manifest.icons {
        try render(size: size, label: entry.extensions.first ?? entry.name,
                   to: URL(fileURLWithPath: args[1] + "/doc/\(entry.name)/\(size).png"))
    }
    try render(size: size, label: "7z", to: URL(fileURLWithPath: args[1] + "/doc/fm/\(size).png"))
}
print("Rendered original app and archive icons at 16–1024 pixels")
