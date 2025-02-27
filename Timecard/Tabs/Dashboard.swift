import SwiftData
import SwiftUI

/// A view that displays the dashboard for tracking time-related data.
///
/// The `Dashboard` view shows the last punch time, total hours worked for the week to date,
/// and allows users to 'punch in' for their current work session. It also provides an estimation
/// of hours based on settings and displays a settings button to modify user preferences.
///
/// - Note: This view requires a `Settings` environment object and a `Bindable` current day.
struct Dashboard: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @EnvironmentObject private var settings: Settings
    
    @Bindable var currentDay: Day
    var lastPunch: Date?
    var weekToDate: Double
    
    @State private var showSheet = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    HStack {
                        Text("Last Punch:")
                            
                        Spacer()
                            
                        Text("\(lastPunch?.formatted(date: .abbreviated, time: .shortened) ?? "N/A")")
                    }
                        
                    HStack {
                        Text("Week to Date:")
                            
                        Spacer()
                            
                        Text("\(weekToDate.toString())")
                    }
                        
                    EstimationView(lastPunch: currentDay.lastPunch, currentTotalHours: currentDay.totalHours, expectedTotalHours: settings.defaultHours)
                        
                    if currentDay.weekDay == settings.workDays.last {
                        EstimationView(lastPunch: currentDay.lastPunch, currentTotalHours: weekToDate, expectedTotalHours: settings.defaultTotalHours)
                    }
                }
                    
                Button {
                    currentDay.addPunch(Date.now)
                } label: {
                    Text("Punch")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(currentDay.isPunchButtonDisabled)
                .padding()
            }
            .background(colorScheme == .light ? Color.white : Color(.secondarySystemGroupedBackground))
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showSheet = true
                    } label: {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                }
            }
            .sheet(isPresented: $showSheet) {
                SettingsView()
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Week.self, configurations: config)
    
    Dashboard(currentDay: Week.mockWeek.monday, lastPunch: Week.mockWeek.monday.lastPunch?.punch, weekToDate: 10)
        .environmentObject(Settings())
        .modelContainer(container)
}
