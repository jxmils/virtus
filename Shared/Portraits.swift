import Foundation
import CoreGraphics
import ImageIO

/// Optional portraits: `Portraits/<author-slug>.jpg` (or .png) in the app bundle. A quote whose author has
/// one is shown beside it, fading into black; the rest stay text-only.
enum Portraits {
    /// Where to look besides the bundle (the self-test and the screen renders point this at a folder).
    nonisolated(unsafe) static var directory: URL?

    private static let cache = NSCache<NSString, CGImage>()

    /// "Niccolò Machiavelli" -> "niccolo-machiavelli", "T. E. Lawrence" -> "t-e-lawrence".
    static func slug(for author: String) -> String {
        let folded = author.folding(options: [.diacriticInsensitive, .caseInsensitive, .widthInsensitive], locale: Locale(identifier: "en"))
            .replacingOccurrences(of: "ø", with: "o").replacingOccurrences(of: "æ", with: "ae")
            .replacingOccurrences(of: "ß", with: "ss").replacingOccurrences(of: "ł", with: "l")
        var out = ""
        var dash = false
        for ch in folded.lowercased() {
            if ch.isLetter || ch.isNumber {
                out.append(ch); dash = false
            } else if !dash, !out.isEmpty {
                out.append("-"); dash = true
            }
        }
        while out.hasSuffix("-") { out.removeLast() }
        return out
    }

    static func url(for author: String) -> URL? {
        let slug = slug(for: author)
        guard !slug.isEmpty else { return nil }
        for ext in ["jpg", "jpeg", "png"] {
            if let dir = directory {
                let file = dir.appendingPathComponent("\(slug).\(ext)")
                if FileManager.default.fileExists(atPath: file.path) { return file }
            }
            if let file = Bundle.main.url(forResource: slug, withExtension: ext) { return file }
        }
        return nil
    }

    static func has(_ quote: Quote) -> Bool { url(for: quote.author) != nil }

    /// The portrait decoded no larger than `maxPixel` on its long side (keeps widgets within their memory).
    static func image(for quote: Quote, maxPixel: Int) -> CGImage? {
        guard let url = url(for: quote.author) else { return nil }
        let key = "\(url.path)@\(maxPixel)" as NSString
        if let hit = cache.object(forKey: key) { return hit }
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        let options: [CFString: Any] = [kCGImageSourceCreateThumbnailFromImageAlways: true,
                                        kCGImageSourceThumbnailMaxPixelSize: maxPixel,
                                        kCGImageSourceCreateThumbnailWithTransform: true,
                                        kCGImageSourceShouldCache: false]
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { return nil }
        cache.setObject(image, forKey: key, cost: image.bytesPerRow * image.height)
        return image
    }
}
