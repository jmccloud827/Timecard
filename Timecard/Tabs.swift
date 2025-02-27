import SwiftData
import SwiftUI
import WidgetKit

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
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: scenePhase) {
                    if scenePhase == .background {
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
            } else {
                Button("Get started") {
                    let week = Week()
                    modelContext.insert(week)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding()
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .onChange(of: scenePhase) {
            if scenePhase == .background {
                WidgetCenter.shared.reloadAllTimelines()
            }
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
