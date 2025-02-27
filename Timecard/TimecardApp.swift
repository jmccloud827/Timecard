import SwiftUI
import SwiftData

@main
struct TimecardApp: App {
    var body: some Scene {
        WindowGroup {
            Tabs()
                .environmentObject(Settings())
        }
        .modelContainer(for: Week.self)
    }
}
