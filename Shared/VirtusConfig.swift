import Foundation

/// Identifiers shared by the app and the widget. They come from the VIRTUS_ID_PREFIX build setting
/// (via Info.plist), so changing the prefix in Xcode is the only edit needed.
enum VirtusConfig {
    static let appGroup = Bundle.main.object(forInfoDictionaryKey: "VirtusAppGroup") as? String ?? "group.com.jasonmiller.Virtus"
    static let urlScheme = "virtus"
    static let widgetKind = "VirtusQuoteWidget"
    static let maxName = 24
    /// How many past days the Archive shows.
    static let archiveDays = 90
}

/// Deep links used by the widgets.
enum VirtusLink {
    static let today = URL(string: "virtus://today")!
    static let pinned = URL(string: "virtus://pinned")!

    static func quote(_ id: String) -> URL {
        URL(string: "virtus://quote/\(id)")!
    }

    /// The quote id in a `virtus://quote/<id>` link, if any.
    static func quoteID(in url: URL) -> String? {
        guard url.scheme == VirtusConfig.urlScheme, url.host == "quote" else { return nil }
        let id = url.lastPathComponent
        return id.isEmpty || id == "/" ? nil : id
    }
}
