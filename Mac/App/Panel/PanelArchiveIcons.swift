// Original native archive document artwork. The format mapping remains FileTypes' table
// (03 §3.1); assets are generated from vector paths by make-native-icons.swift, under CC0.
// NSImage selects the appropriate Retina representation instead of enlarging Windows bitmaps.

import AppKit
import ImageIO

enum PanelArchiveIcons {

    private static var cache: [String: NSImage] = [:]

    /// The 7-Zip icon for `name`'s extension, or nil when 7-Zip does not register the extension
    /// (FileTypes, 7z.dll string resource 100).
    static func icon(forName name: String, large: Bool) -> NSImage? {
        let ext = (name as NSString).pathExtension.lowercased()
        guard !ext.isEmpty, let type = FileTypes.type(forExtension: ext) else { return nil }
        return icon(named: type.iconFileName, large: large)
    }

    /// Original `doc-<iconName>` asset at 20 or 32 pt.
    static func icon(named iconName: String, large: Bool) -> NSImage? {
        let key = (large ? "L" : "S") + iconName
        if let cached = cache[key] { return cached }
        guard let asset = NSImage(named: "doc-" + iconName), let image = asset.copy() as? NSImage else { return nil }
        let points: CGFloat = large ? 32 : 20
        image.size = NSSize(width: points, height: points)
        cache[key] = image
        return image
    }

    /// `frame` enlarged to `width` x `height` by whole pixels with no interpolation: every source
    /// pixel becomes an exact block. (The .ico frames are 8-bit indexed with an 8-bit alpha;
    /// Core Graphics decodes them when it draws, NSBitmapImageRep.colorAt cannot read them.)
    static func nearestNeighbour(_ frame: CGImage, width: Int, height: Int) -> NSBitmapImageRep? {
        guard let ctx = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
                                  space: CGColorSpace(name: CGColorSpace.sRGB)!,
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        ctx.interpolationQuality = .none
        ctx.setShouldAntialias(false)
        ctx.draw(frame, in: CGRect(x: 0, y: 0, width: width, height: height))
        return ctx.makeImage().map(NSBitmapImageRep.init(cgImage:))
    }
}
