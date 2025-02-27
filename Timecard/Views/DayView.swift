import SwiftData
import SwiftUI

/// A view that displays the punch times for a specific day.
///
/// The `DayView` shows a list of punch entries for a given day, allowing users to view,
/// edit, and delete punch times. It also displays the total hours worked for the day
/// and provides an interface to add new punch times.
struct DayView: View {
    @Bindable var day: Day
    
    private let displayedComponents = DatePickerComponents.hourAndMinute
    
    var body: some View {
        Section {
            ForEach(Array($day.punches.enumerated()), id: \.offset) { index, punch in
                HStack {
                    let isIn = index.isMultiple(of: 2)
                    let label = "\(isIn ? "In" : "Out"): "
                    let previousPunch: Date? =
                        if index > 0 {
                            day.punches[index - 1]
                        } else {
                            nil
                        }
                    
                    let nextPunch: Date? =
                        if index < day.punches.count - 1 {
                            day.punches[index + 1]
                        } else {
                            nil
                        }
                    
                    if let previousPunch, let nextPunch {
                        DatePicker(label, selection: punch, in: previousPunch ... nextPunch, displayedComponents: displayedComponents)
                    } else if let previousPunch {
                        DatePicker(label, selection: punch, in: previousPunch..., displayedComponents: displayedComponents)
                    } else if let nextPunch {
                        DatePicker(label, selection: punch, in: ...nextPunch, displayedComponents: displayedComponents)
                    } else {
                        DatePicker(label, selection: punch, displayedComponents: displayedComponents)
                    }
                    
                    Button(role: .destructive) {
                        withAnimation {
                            _ = day.punches.remove(at: index)
                        }
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                }
            }
            .onDelete { offsets in
                withAnimation {
                    day.punches.remove(atOffsets: offsets)
                }
            }
        } header: {
            HStack {
                Text(day.weekDay.displayValue)
                
                Spacer()
                
                Text("Total Hours: \(day.totalHours.toString())")
                
                AddPunchButton { day.addPunch($0) }
            }
        }
    }
}

/// A view for adding a new punch time.
///
/// The `AddPunchButton` presents a sheet for users to select a new punch time
/// using a date picker, and it passes the selected time back to the parent view.
struct AddPunchButton: View {
    let addPunch: (Date) -> Void
    
    @State private var showSheet = false
    @State private var newPunch = Date.now
    
    var body: some View {
        Button {
            showSheet = true
        } label: {
            Label("Add", systemImage: "plus")
                .labelStyle(.iconOnly)
        }
        .sheet(isPresented: $showSheet) {
            NavigationStack {
                DatePicker("New Time", selection: $newPunch, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .datePickerStyle(.wheel)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") {
                                addPunch(newPunch)
                                showSheet = false
                            }
                        }
                        
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Cancel") {
                                showSheet = false
                            }
                        }
                    }
            }
            .interactiveDismissDisabled()
            .presentationDetents([.height(200)])
        }
        .textCase(nil)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Week.self, configurations: config)
    
    List {
        DayView(day: Week.mockWeek.monday)
    }
    .modelContainer(container)
}
