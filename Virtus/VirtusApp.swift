import SwiftUI
import WidgetKit

@main
struct VirtusApp: App {
    @State private var model = AppModel(env: .live)
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model)
                .preferredColorScheme(.dark)
                .onOpenURL { model.open(url: $0) }
                .onChange(of: scenePhase, initial: true) { _, phase in
                    if phase == .active { model.start() }
                }
        }
    }
}

extension VirtusEnvironment {
    static var live: VirtusEnvironment {
        VirtusEnvironment(shared: .live,
                          reloadWidgets: { WidgetCenter.shared.reloadAllTimelines() },
                          scheduleReminders: { Reminders.schedule(profile: $0, now: $1) })
    }
}
