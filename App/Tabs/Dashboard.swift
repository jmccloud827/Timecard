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
                    lastPunchLabel
                        
                    weekToDateLabel
                        
                    // Estimates for current day to default hours
                    EstimationView(lastPunch: currentDay.lastPunch, currentTotalHours: currentDay.totalHours, expectedTotalHours: settings.defaultHours)
                        
                    // Estimates for last day to default total hours
                    if currentDay.weekDay == settings.workDays.last {
                        EstimationView(lastPunch: currentDay.lastPunch, currentTotalHours: weekToDate, expectedTotalHours: settings.defaultTotalHours)
                    }
                }
                    
                punchButton
                .padding()
            }
            .background(backgroundColor)
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    showSettingsButton
                }
            }
            .sheet(isPresented: $showSheet) {
                SettingsView()
            }
        }
    }
    
    private var lastPunchLabel: some View {
        HStack {
            Text("Last Punch:")
                
            Spacer()
                
            Text("\(lastPunch?.formatted(date: .abbreviated, time: .shortened) ?? "N/A")")
        }
    }
    
    private var weekToDateLabel: some View {
        HStack {
            Text("Week to Date:")
                
            Spacer()
                
            Text("\(weekToDate.toString())")
        }
    }
    
    private var punchButton: some View {
        Button {
            currentDay.addPunch(Date.now)
        } label: {
            Text("Punch")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(currentDay.isPunchButtonDisabled)
    }
    
    private var backgroundColor: Color {
        if colorScheme == .light {
            Color.white
        } else {
            Color(.secondarySystemGroupedBackground)
        }
    }
    
    private var showSettingsButton: some View {
        Button {
            showSheet = true
        } label: {
            Label("Settings", systemImage: "gearshape.fill")
        }
    }
}

#Preview {
    let container = App.previewContainer
    
    Dashboard(currentDay: Week.sample.monday, lastPunch: Week.sample.monday.lastPunch?.punch, weekToDate: 10)
        .environmentObject(Settings())
        .modelContainer(container)
}
