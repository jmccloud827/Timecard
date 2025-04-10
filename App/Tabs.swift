import SwiftData
import SwiftUI
import WidgetKit

/// A view that represents a tabbed interface for managing time-related data.
///
/// The `Tabs` view displays different child views in a `TabView`, allowing users to navigate between
/// a Dashboard, a Timecard, and a Calculator. It also handles the scene phase changes to reload
/// widget timelines when the app goes to the background.
///
/// - Note: This view requires a `ModelContext` and a query for `Week` data.
struct Tabs: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var modelContext
    
    @Query private var weeks: [Week]

    var body: some View {
        Group {
            if let week = weeks.first {
                TabView {
                    Dashboard(currentDay: week.currentDay, lastPunch: week.lastPunch, weekToDate: week.weekToDate)
                        .tabItem {
                            Label("Dashboard", systemImage: "house")
                        }
                    
                    Timecard(week: week)
                        .tabItem {
                            Label("Timecard", systemImage: "clock")
                        }
                    
                    Calculator(currentDayLastPunch: week.currentDay.lastPunch)
                        .tabItem {
                            Label("Calculator", systemImage: "minus.slash.plus")
                        }
                }
            } else {
                getStartedButton
                    .padding()
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .onChange(of: scenePhase) {
            onChangeOfScenePhase()
        }
    }
    
    private var getStartedButton: some View {
        Button("Get started") {
            let week = Week()
            modelContext.insert(week)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }
    
    private func onChangeOfScenePhase() {
        if scenePhase == .background {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Week.self, configurations: config)
    
    container.mainContext.insert(Week.mockWeek)
    
    return Tabs()
        .modelContainer(container)
        .environmentObject(Settings())
}
