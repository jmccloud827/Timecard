import SwiftData
import SwiftUI

@main
struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            Tabs()
                .environmentObject(Settings())
        }
        .modelContainer(for: [
            Week.self,
            Day.self
        ])
    }
    
    static var previewContainer: ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        
        return try! ModelContainer(for: Week.self,
                                   Day.self,
                                   configurations: config)
    }
}
