import SwiftData
import SwiftUI

/// A view that displays the timecard for a given week.
///
/// The `Timecard` view presents a list of daily entries for the week, allowing users to
/// see their total hours worked for each day and the week to date. It includes a button to
/// clear all time entries for the week.
///
/// - Note: This view requires a `Bindable` week object that holds the time entries.
struct Timecard: View {
    @Bindable var week: Week
    
    var body: some View {
        NavigationStack {
            List {
                weekToDate
                
                DayView(day: week.sunday)
                
                DayView(day: week.monday)
                
                DayView(day: week.tuesday)
                
                DayView(day: week.wednesday)
                
                DayView(day: week.thursday)
                
                DayView(day: week.friday)
                
                DayView(day: week.saturday)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    clearButton
                }
            }
            .navigationTitle("Timecard")
        }
    }
    
    private var weekToDate: some View {
        HStack {
            Text("Week to Date:")
            
            Spacer()
            
            Text(week.weekToDate.toString())
        }
    }
    
    private var clearButton: some View {
        Button("Clear") {
            week.clear()
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Week.self, configurations: config)
    
    Timecard(week: Week.mockWeek)
        .modelContainer(container)
}
