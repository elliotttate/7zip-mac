// Original, resolution-independent toolbar artwork. CC0; see Resources/Icons/LICENSE.md.
import AppKit

enum MacSymbols {
    static func image(_ name: String, size: CGFloat = 20) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size), flipped: true) { rect in
            NSGraphicsContext.saveGraphicsState()
            defer { NSGraphicsContext.restoreGraphicsState() }
            let transform = NSAffineTransform()
            transform.scale(by: rect.width / 24)
            transform.concat()
            NSColor.black.setStroke()
            func line(_ points: [NSPoint]) {
                let path = NSBezierPath()
                path.lineWidth = 1.6
                path.lineCapStyle = .round
                path.lineJoinStyle = .round
                if let first = points.first { path.move(to: first) }
                for p in points.dropFirst() { path.line(to: p) }
                path.stroke()
            }
            func p(_ x: CGFloat, _ y: CGFloat) -> NSPoint { NSPoint(x: x, y: y) }
            func box(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, radius: CGFloat = 2) {
                let path = NSBezierPath(roundedRect: NSRect(x: x, y: y, width: w, height: h),
                                        xRadius: radius, yRadius: radius)
                path.lineWidth = 1.6
                path.stroke()
            }
            switch name {
            case "add":
                box(3, 8, 18, 13)
                line([p(3, 8), p(6, 3), p(18, 3), p(21, 8)])
                line([p(8, 14), p(16, 14)])
                line([p(12, 10), p(12, 18)])
            case "extract":
                line([p(3, 14), p(3, 20), p(21, 20), p(21, 14)])
                line([p(12, 3), p(12, 14)])
                line([p(7.5, 10), p(12, 14.5), p(16.5, 10)])
            case "test":
                line([p(12, 2.5), p(20, 6), p(20, 12), p(18, 17), p(12, 21.5),
                      p(6, 17), p(4, 12), p(4, 6), p(12, 2.5)])
                line([p(8, 11.5), p(11, 14.5), p(16, 9)])
            case "copy":
                box(8, 8, 13, 13)
                line([p(16, 5), p(16, 3), p(3, 3), p(3, 16), p(5, 16)])
            case "move":
                line([p(12, 6), p(12, 3), p(3, 3), p(3, 21), p(12, 21), p(12, 18)])
                line([p(9, 12), p(22, 12)])
                line([p(17, 7), p(22, 12), p(17, 17)])
            case "delete":
                line([p(3, 6), p(21, 6)])
                line([p(8, 6), p(8, 3), p(16, 3), p(16, 6)])
                line([p(5, 6), p(6, 21), p(18, 21), p(19, 6)])
                line([p(10, 10), p(10, 17)])
                line([p(14, 10), p(14, 17)])
            case "info":
                let ring = NSBezierPath(ovalIn: NSRect(x: 3, y: 3, width: 18, height: 18))
                ring.lineWidth = 1.6
                ring.stroke()
                line([p(11, 11), p(12.5, 11), p(12.5, 17)])
                NSColor.black.setFill()
                NSBezierPath(ovalIn: NSRect(x: 11.5, y: 6.5, width: 2, height: 2)).fill()
            case "up":
                line([p(6, 12), p(12, 6), p(18, 12)])
                line([p(12, 6), p(12, 20)])
            default: break
            }
            return true
        }
        image.isTemplate = true
        image.accessibilityDescription = name.capitalized
        return image
    }
}
