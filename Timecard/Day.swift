import Foundation
import SwiftData

@Model
final class Day {
    let id: Days
    var punches: [Date]
    
    init(id: Days) {
        self.id = id
        self.punches = []
    }
}

enum Days: Int, Codable, CaseIterable {
    case monday = 2,
         tuesday = 3,
         wednesday = 4,
         thursday = 5,
         friday = 6,
         saturday = 7,
         sunday = 1
    
    var displayValue: String {
        switch self {
        case .monday:
            "Monday"
        case .tuesday:
            "Tuesday"
        case .wednesday:
            "Wednesday"
        case .thursday:
            "Thursday"
        case .friday:
            "Friday"
        case .saturday:
            "Saturday"
        case .sunday:
            "Sunday"
        }
    }
    
    static var currentWeekday: Days {
        let weekday = Calendar.current.component(.weekday, from: Date.now)
        return Days.allCases.first { day in day.rawValue == weekday } ?? .monday
    }
}

extension Date {
    func getDay() -> Days {
        let weekday = Calendar.current.component(.weekday, from: self)
        for day in Days.allCases {
            if weekday == day.rawValue {
                return day
            }
        }
        return .monday
    }
    
    func setWeekday(weekday: Days) -> Date {
        let calendar = Calendar.current
        var componenets = Calendar.current.dateComponents([.hour, .minute, .weekday, .year, .month, .day], from: self)
        componenets.weekday = weekday.rawValue
        return calendar.date(from: componenets) ?? Date.now
    }
    
    func timeBetween(_ date: Date) -> Double {
        let inCalender = Calendar.current.dateComponents([.hour, .minute], from: self)
        let outCalender = Calendar.current.dateComponents([.hour, .minute], from: date)
        let hours = Double(outCalender.hour ?? 0) - Double(inCalender.hour ?? 0)
        let minutes = Double(outCalender.minute ?? 0) - Double(inCalender.minute ?? 0)
        return hours + (minutes / 60.0)
    }
}

extension Day {
    var totalHours: Double {
        var totalHours = 0.0
        let array = self.punches.sorted { $0 < $1 }
        for (index, punch) in Array(array.enumerated()) {
            if index.isMultiple(of: 1) && index != 0 {
                let previousPunch = self.punches[index - 1]
                totalHours += previousPunch.timeBetween(punch)
            }
        }
        return totalHours
    }
}

extension Double {
    func toString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumIntegerDigits = 1
        formatter.maximumIntegerDigits = 2
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(floatLiteral: self)) ?? ""
    }
}
