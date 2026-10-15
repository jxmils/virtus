import Foundation

/// The user's profile: pinned quotes, the one featured on the widget, and the days the app was opened.
struct Profile: Codable, Equatable {
    var name = ""
    /// Quote ids, newest pin first.
    var pinned: [String] = []
    /// The pinned quote the widget shows first (and the Profile shows on top).
    var featured: String?
    /// Day numbers (see DailyQuote.dayNumber) on which the app was opened.
    var openedDays: [Int] = []
    var reminderOn = false
    var reminderHour = 7
    var reminderMinute = 0
    var createdAt: Date?

    func isPinned(_ id: String) -> Bool { pinned.contains(id) }

    var pinnedQuotes: [Quote] {
        var ids = pinned
        if let featured, let i = ids.firstIndex(of: featured) {
            ids.remove(at: i); ids.insert(featured, at: 0)
        }
        return ids.compactMap { QuoteLibrary.quote(id: $0) }
    }

    /// Consecutive opened days ending today or yesterday.
    func streak(today: Int) -> Int {
        let days = Set(openedDays)
        var day = days.contains(today) ? today : today - 1
        var n = 0
        while days.contains(day) { n += 1; day -= 1 }
        return n
    }
}

/// The App Group folder shared with the widget. One JSON file, written atomically.
struct SharedStore {
    let root: URL

    static var live: SharedStore {
        if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: VirtusConfig.appGroup) {
            return SharedStore(root: url)
        }
        let fallback = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("VirtusShared", isDirectory: true)
        return SharedStore(root: fallback)
    }

    var profileURL: URL { root.appendingPathComponent("profile.json") }

    func load() -> Profile {
        guard let data = try? Data(contentsOf: profileURL),
              let profile = try? JSONDecoder().decode(Profile.self, from: data) else { return Profile() }
        return profile
    }

    func save(_ profile: Profile) {
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        if let data = try? encoder.encode(profile) {
            try? data.write(to: profileURL, options: .atomic)
        }
    }
}
