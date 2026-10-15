import Foundation
import UserNotifications

/// A morning notification with the day's quote, scheduled a week ahead so it works offline.
enum Reminders {
    static let prefix = "virtus.day."

    struct Planned: Equatable {
        var id: String
        var fire: DateComponents
        var quote: Quote
    }

    /// The next 7 reminders from `now` (today's included if the time has not passed yet).
    static func plan(profile: Profile, now: Date, calendar: Calendar = .autoupdatingCurrent) -> [Planned] {
        guard profile.reminderOn else { return [] }
        var result: [Planned] = []
        var day = calendar.startOfDay(for: now)
        while result.count < 7 {
            if let fire = calendar.date(bySettingHour: profile.reminderHour, minute: profile.reminderMinute, second: 0, of: day), fire > now {
                let parts = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fire)
                result.append(Planned(id: prefix + String(DailyQuote.dayNumber(for: day, calendar: calendar)),
                                      fire: parts, quote: DailyQuote.quote(for: day, calendar: calendar)))
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }
        return result
    }

    static func schedule(profile: Profile, now: Date) {
        let center = UNUserNotificationCenter.current()
        let planned = plan(profile: profile, now: now)
        Task {
            let pending = await center.pendingNotificationRequests().map(\.identifier).filter { $0.hasPrefix(prefix) }
            center.removePendingNotificationRequests(withIdentifiers: pending)
            guard !planned.isEmpty else { return }
            let granted = (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
            guard granted else { return }
            for item in planned {
                let content = UNMutableNotificationContent()
                content.title = item.quote.author
                content.body = "\u{201C}\(item.quote.text)\u{201D}"
                content.sound = .default
                let trigger = UNCalendarNotificationTrigger(dateMatching: item.fire, repeats: false)
                try? await center.add(UNNotificationRequest(identifier: item.id, content: content, trigger: trigger))
            }
        }
    }
}
