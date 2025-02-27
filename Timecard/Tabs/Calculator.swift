import SwiftUI

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
    
    private func getTimeOut() -> Date {
        lastPunch.addingTimeInterval(((settings.defaultTotalHours - weekToDate) * 60 * 60) + Double((breakMinutes * 60)))
    }
}

#Preview {
    Calculator(currentDayLastPunch: nil)
        .environmentObject(Settings())
}
