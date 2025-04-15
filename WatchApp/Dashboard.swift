import SwiftData
import SwiftUI

/// A view that displays the user's dashboard for tracking punches and estimates.
///
/// The `Dashboard` provides an overview of the last punch time, estimation of hours worked,
/// and functionality to add a new punch. It retrieves data from the `Week` model and displays
/// relevant information based on user settings.
struct Dashboard: View {
    @Environment(\.modelContext) private var modelContext
    
    @StateObject private var settings = Settings()
    
    @Query private var weeks: [Week]
    
    var body: some View {
        Group {
            if let week = weeks.first {
                VStack(spacing: 0) {
                    ScrollView {
                        Text("Last Punch:")
                        
                        Text(week.lastPunch?.formatted(date: .abbreviated, time: .shortened) ?? "N/A")
                        
                        VStack {
                            EstimationView(lastPunch: week.currentDay.lastPunch, currentTotalHours: week.currentDay.totalHours, expectedTotalHours: settings.defaultHours)
                                .padding()
                                .background {
                                    RoundedRectangle(cornerSize: .init(width: 15, height: 15), style: .continuous)
                                        .foregroundStyle(.accent.opacity(0.2))
                                }
                            
                            if week.currentDay.weekDay == settings.workDays.last {
                                EstimationView(lastPunch: week.currentDay.lastPunch, currentTotalHours: week.currentDay.totalHours, expectedTotalHours: settings.defaultHours)
                                    .padding()
                                    .background {
                                        RoundedRectangle(cornerSize: .init(width: 15, height: 10), style: .continuous)
                                            .foregroundStyle(.accent.opacity(0.2))
                                    }
                            }
                        }
                    }
                    .padding(.top, 20)
                    
                    Button("Punch") {
                        week.currentDay.addPunch(Date.now)
                    }
                    .disabled(week.currentDay.isPunchButtonDisabled)
                    .padding(.bottom)
                    .padding(.top, 5)
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity)
                    .background(Color(white: 0.1))
                }
                .ignoresSafeArea()
                .environmentObject(settings)
            } else {
                Button("Get started") {
                    let week = Week()
                    modelContext.insert(week)
                }
                .padding()
            }
        }
        .tint(.accent)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Week.self, Day.self, configurations: config)
    
    container.mainContext.insert(Week.sample)
    
    return Dashboard()
        .modelContainer(container)
}
