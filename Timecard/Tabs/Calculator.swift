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
                    HStack {
                        Text("Week to Date:")
                        
                        Spacer()
                        
                        TextField("", value: $weekToDate, format: .number)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .frame(width: 50)
                    }
                    DatePicker("Last Punch Time", selection: $lastPunch, displayedComponents: .hourAndMinute)
                    
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
                    
                    HStack {
                        Text("You will hit \(settings.defaultTotalHours.toString()) hours at:")
                        
                        Spacer()
                        
                        Text(getTimeOut().formatted(date: .omitted, time: .shortened))
                    }
                }
                .navigationTitle("Calculator")
            }
        }
        .onAppear {
            onAppear()
        }
    }
    
    /// A method to handle initial setup when the view appears.
    private func onAppear() {
        if isFirstLoad {
            isFirstLoad = false
            weekToDate = settings.defaultTotalHours
            breakMinutes = settings.defaultBreak
            addBreak = settings.defaultBreak != 0
        }
        
        if !(currentDayLastPunch?.isIn ?? true) {
            lastPunch = currentDayLastPunch?.punch ?? Date.now
        }
    }
    
    /// Calculates the estimated punch-out time based on the last punch, total hours worked, and break time.
    ///
    /// - Returns: A `Date` representing the estimated punch-out time.
    private func getTimeOut() -> Date {
        lastPunch.addingTimeInterval(((settings.defaultTotalHours - weekToDate) * 60 * 60) + (addBreak ? Double(breakMinutes * 60) : 0))
    }
}

#Preview {
    Calculator(currentDayLastPunch: nil)
        .environmentObject(Settings())
}
