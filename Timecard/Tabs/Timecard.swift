import SwiftUI
import SwiftData

struct Timecard: View {
    @EnvironmentObject private var settings: Settings
    
    @Bindable var week: Week
    
    var body: some View {
        NavigationStack {
            List {
                HStack {
                    Text("Week to Date:")
                    
                    Spacer()
                    
                    Text(week.weekToDate.toString())
                }
                
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
                    Button("Clear") {
                        week.clear()
                    }
                }
            }
            .navigationTitle("Timecard")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Week.self, configurations: config)
    
    Timecard(week: Week.mockWeek)
        .modelContainer(container)
}
