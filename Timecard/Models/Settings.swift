import SwiftUI

class Settings: ObservableObject {
    @AppStorage("Default Total Hours") var defaultTotalHours = 40.0
    @AppStorage("Default Hours") var defaultHours = 8.0
    @AppStorage("Default Break") var defaultBreak = 60
    @AppStorage("Work Days") var defaultWorkDays = "2,3,4,5,6,"
    
    var workDays: [Days] {
        var days: [Days] = []
        let defaultWorkDays = defaultWorkDays.split(separator: ",")
        for workDay in defaultWorkDays {
            let day = Days.allCases.filter { day in day.rawValue == Int(workDay) }.first
            if let day {
                days.append(day)
            }
        }
        days.sort { $0.rawValue < $1.rawValue }
        return days
    }
        
    var daysOff: [Days] {
        return Days.allCases.filter { day in !workDays.contains(day) }
    }
}
