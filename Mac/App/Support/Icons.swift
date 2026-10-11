// Icons.swift -- 16 px system icons by extension (g_Ext_to_Icon_Map equivalent).

import AppKit
import UniformTypeIdentifiers

enum Icons {

    private static var cache: [String: NSImage] = [:]
    private static let iconSize = NSSize(width: 16, height: 16)

    static let folder: NSImage = {
        NSImage(size: iconSize, flipped: false) { rect in
            let scale = NSAffineTransform()
            scale.scaleX(by: rect.width / 32, yBy: rect.height / 32)
            NSGraphicsContext.saveGraphicsState()
            scale.concat()
            defer { NSGraphicsContext.restoreGraphicsState() }
            let back = NSBezierPath()
            back.move(to: NSPoint(x: 2, y: 6))
            back.line(to: NSPoint(x: 2, y: 25))
            back.curve(to: NSPoint(x: 5, y: 28), controlPoint1: NSPoint(x: 2, y: 27), controlPoint2: NSPoint(x: 3, y: 28))
            back.line(to: NSPoint(x: 12, y: 28))
            back.line(to: NSPoint(x: 16, y: 24))
            back.line(to: NSPoint(x: 27, y: 24))
            back.curve(to: NSPoint(x: 30, y: 21), controlPoint1: NSPoint(x: 29, y: 24), controlPoint2: NSPoint(x: 30, y: 23))
            back.line(to: NSPoint(x: 30, y: 6))
            back.close()
            NSColor(srgbRed: 0.18, green: 0.61, blue: 0.83, alpha: 1).setFill()
            back.fill()
            let front = NSBezierPath(roundedRect: NSRect(x: 2, y: 4, width: 28, height: 18), xRadius: 3, yRadius: 3)
            NSGradient(starting: NSColor(srgbRed: 0.22, green: 0.68, blue: 0.92, alpha: 1),
                       ending: NSColor(srgbRed: 0.48, green: 0.85, blue: 1, alpha: 1))?.draw(in: front, angle: 90)
            return true
        }
    }()

    /// Icon for a file name (by extension) or a folder.
    static func icon(forName name: String, isDirectory: Bool) -> NSImage {
        if isDirectory { return folder }
        let ext = (name as NSString).pathExtension.lowercased()
        if let cached = cache[ext] { return cached }
        let type = ext.isEmpty ? UTType.data : (UTType(filenameExtension: ext) ?? .data)
        let image = NSWorkspace.shared.icon(for: type)
        image.size = iconSize
        cache[ext] = image
        return image
    }
}
