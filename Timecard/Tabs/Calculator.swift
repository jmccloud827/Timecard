import SwiftUI

/// A view that provides a calculator for estimating work hours and calculating punch-out times.
///
/// The `Calculator` view allows users to input their total hours worked for the week, the last punch time,
/// and any break time. It calculates the estimated punch-out time based on these inputs and displays the result.
/// The view is integrated with user settings to provide default values for hours and breaks.
///
/// - Note: This view requires a `Settings` environment object to retrieve user preferences.
struct Calculator: View {
    @EnvironmentObject private var settings: Settings
    
    var currentDayLastPunch: (punch: Date, isIn: Bool)?
    
    @State private var weekToDate = 40.0
    @State private var lastPunch = Date.now
    @State private var addBreak = true
    @State private var breakMinutes = 0
    @State private var isFirstLoad = true

    var body: some View {
        VStack(spacing: 0) {
            NavigationStack {
                Form {
                    weekToDateInput
                    
                    lasPunchTimeInput
                    
                    breakInput
                    
                    timeOutLabel
                }
                .navigationTitle("Calculator")
            }
        }
        .onAppear {
            onAppear()
        }
    }
    
    private var weekToDateInput: some View {
        HStack {
            Text("Week to Date:")
            
            Spacer()
            
            TextField("", value: $weekToDate, format: .number)
                .multilineTextAlignment(.trailing)
                .keyboardType(.decimalPad)
                .frame(width: 50)
        }
    }
    
    private var lasPunchTimeInput: some View {
        DatePicker("Last Punch Time", selection: $lastPunch, displayedComponents: .hourAndMinute)
    }
    
    @ViewBuilder private var breakInput: some View {
        Toggle("Add Break?", isOn: $addBreak)
        
        if addBreak {
            HStack {
                Text("Break Time (Minutes):")
                
                Spacer()
                
                TextField("", value: $breakMinutes, format: .number)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
                    .frame(width: 50)
            }
        }
    }
    
    private var timeOutLabel: some View {
        HStack {
            Text("You will hit \(settings.defaultTotalHours.toString()) hours at:")
            
            Spacer()
            
            Text(getTimeOut().formatted(date: .omitted, time: .shortened))
        }
    }
    
    private func getTimeOut() -> Date {
        let hoursLeftInSeconds = (settings.defaultTotalHours - weekToDate) * 60 * 60
        let breakInSeconds = addBreak ? Double(breakMinutes * 60) : 0
        return lastPunch.addingTimeInterval(hoursLeftInSeconds + breakInSeconds)
    }
    
    private func onAppear() {
        if isFirstLoad {
            isFirstLoad = false
            weekToDate = settings.defaultTotalHours
            breakMinutes = settings.defaultBreak
            addBreak = settings.defaultBreak != 0
        }
        
        lastPunch = currentDayLastPunch?.punch ?? Date.now
    }
}

#Preview {
    Calculator(currentDayLastPunch: nil)
        .environmentObject(Settings())
}
