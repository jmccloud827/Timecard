import SwiftData
import SwiftUI

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
