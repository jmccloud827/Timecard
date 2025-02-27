import SwiftData
import SwiftUI

@main
struct TimecardWatch_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            Dashboard()
        }
        .modelContainer(for: Week.self)
    }
}
