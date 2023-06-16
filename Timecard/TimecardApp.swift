import GoogleMobileAds
import SwiftUI

@main
struct TimecardApp: App {
    @AppStorage("AppState") var storage = ""
    
    var body: some Scene {
        WindowGroup {
            ContentView(storage: storage)
        }
    }
}
