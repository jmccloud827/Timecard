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
            ForEach(Array($day.punches.enumerated()), id: \.offset) { index, $punch in
                makePunchRow($punch, index: index)
            }
            .onDelete { offsets in
                withAnimation {
                    day.punches.remove(atOffsets: offsets)
                }
            }
        } header: {
            header
        }
    }
    
    private func makePunchRow(_ punch: Binding<Date>, index: Int) -> some View {
        HStack {
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
            
            DatePicker("\(index.isMultiple(of: 2) ? "In" : "Out"): ",
                       selection: punch,
                       in: (previousPunch ?? Date.distantPast) ... (nextPunch ?? Date.distantFuture),
                       displayedComponents: displayedComponents)
            
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
    
    private var header: some View {
        HStack {
            Text(day.weekDay.displayValue)
            
            Spacer()
            
            Text("Total Hours: \(day.totalHours.toString())")
            
            AddPunchButton { day.addPunch($0) }
        }
    }
}

/// A view for adding a new punch time.
///
/// The `AddPunchButton` presents a sheet for users to select a new punch time
/// using a date picker, and it passes the selected time back to the parent view.
private struct AddPunchButton: View {
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
            addPunchSheet
                .interactiveDismissDisabled()
                .presentationDetents([.height(200)])
        }
        .textCase(nil)
    }
    
    private var addPunchSheet: some View {
        NavigationStack {
            DatePicker("New Time", selection: $newPunch, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .datePickerStyle(.wheel)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        doneButton
                    }
                    
                    ToolbarItem(placement: .topBarLeading) {
                        cancelButton
                    }
                }
        }
    }
    
    private var doneButton: some View {
        Button("Done") {
            addPunch(newPunch)
            showSheet = false
        }
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            showSheet = false
        }
    }
}

#Preview {
    let container = App.previewContainer
    List {
        DayView(day: Week.sample.monday)
    }
    .modelContainer(container)
}
