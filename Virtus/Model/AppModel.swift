import Foundation
import Observation

/// What the model needs from the outside world. The app passes the real things; the self-test passes fakes.
struct VirtusEnvironment {
    var shared: SharedStore
    var now: () -> Date = Date.init
    var calendar: Calendar = .autoupdatingCurrent
    var reloadWidgets: () -> Void = {}
    var scheduleReminders: (Profile, Date) -> Void = { _, _ in }
}

@MainActor
@Observable
final class AppModel {
    enum Route: Hashable, CaseIterable {
        case today, archive, profile

        var title: String {
            switch self {
            case .today: "Today"
            case .archive: "Archive"
            case .profile: "Profile"
            }
        }
    }

    private let env: VirtusEnvironment
    private(set) var profile: Profile
    var route: Route = .today
    /// A quote shown full screen (from the Archive, the Profile or a widget tap).
    var selected: Quote?
    /// One short line of feedback, e.g. "Pinned".
    var message: String?
    /// Bumped at local midnight so Today re-reads the day's quote while the app stays open.
    private(set) var dayTick = 0

    init(env: VirtusEnvironment) {
        self.env = env
        self.profile = env.shared.load()
    }

    var now: Date { env.now() }
    var calendar: Calendar { env.calendar }
    var todayNumber: Int { DailyQuote.dayNumber(for: now, calendar: calendar) }
    var today: Quote { DailyQuote.quote(for: now, calendar: calendar) }
    var streak: Int { profile.streak(today: todayNumber) }
    var daysOpened: Int { Set(profile.openedDays).count }
    var pinnedQuotes: [Quote] { profile.pinnedQuotes }
    var featured: Quote? { profile.featured.flatMap { QuoteLibrary.quote(id: $0) } }

    /// Call when the app comes to the front: counts the day and keeps the reminders a week ahead.
    func start() {
        var changed = false
        if profile.createdAt == nil { profile.createdAt = now; changed = true }
        if !profile.openedDays.contains(todayNumber) {
            profile.openedDays.append(todayNumber)
            profile.openedDays = Array(profile.openedDays.suffix(400))
            changed = true
        }
        if changed { save() }
        env.scheduleReminders(profile, now)
    }

    /// Called by the midnight timer: the day changed under an open app.
    func dayChanged() {
        dayTick += 1
        start()
    }

    /// Seconds until just after the next local midnight.
    var secondsToNextDay: TimeInterval {
        let next = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) ?? now.addingTimeInterval(86_400)
        return max(1, next.timeIntervalSince(now) + 1)
    }

    /// Past days, newest first, with the quote each one had.
    func archive(days: Int = VirtusConfig.archiveDays) -> [(date: Date, quote: Quote)] {
        (1...max(1, days)).compactMap { d in
            guard let date = calendar.date(byAdding: .day, value: -d, to: calendar.startOfDay(for: now)) else { return nil }
            return (date, DailyQuote.quote(for: date, calendar: calendar))
        }
    }

    func isPinned(_ quote: Quote) -> Bool { profile.isPinned(quote.id) }

    func togglePin(_ quote: Quote) {
        if isPinned(quote) { unpin(quote) } else { pin(quote) }
    }

    func pin(_ quote: Quote) {
        guard !profile.isPinned(quote.id) else { return }
        profile.pinned.insert(quote.id, at: 0)
        if profile.featured == nil { profile.featured = quote.id }
        message = "Pinned to your profile"
        save()
    }

    func unpin(_ quote: Quote) {
        profile.pinned.removeAll { $0 == quote.id }
        if profile.featured == quote.id { profile.featured = profile.pinned.first }
        message = "Unpinned"
        save()
    }

    /// The pinned quote the widget shows first.
    func feature(_ quote: Quote) {
        guard profile.isPinned(quote.id) else { return }
        profile.featured = quote.id
        message = "Featured on your widget"
        save()
    }

    func setName(_ name: String) {
        profile.name = String(name.trimmingCharacters(in: .whitespacesAndNewlines).prefix(VirtusConfig.maxName))
        save()
    }

    func setReminder(on: Bool, hour: Int, minute: Int) {
        profile.reminderOn = on
        profile.reminderHour = min(23, max(0, hour))
        profile.reminderMinute = min(59, max(0, minute))
        save()
        env.scheduleReminders(profile, now)
    }

    /// Handles virtus://quote/<id>, virtus://today and virtus://pinned.
    func open(url: URL) {
        if let id = VirtusLink.quoteID(in: url), let quote = QuoteLibrary.quote(id: id) {
            selected = quote
        } else if url.host == "pinned" {
            route = .profile
        } else if url.host == "today" {
            route = .today
        }
    }

    private func save() {
        env.shared.save(profile)
        env.reloadWidgets()
    }
}
