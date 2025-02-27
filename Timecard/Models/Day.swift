import Foundation
import SwiftData

@Model class Day: Identifiable {
    @Attribute(.unique) var id = UUID()
    var day: Days
    var punches: [Date]
    
    init(day: Days) {
        self.day = day
        self.punches = []
    }
    
    func addPunch(_ date: Date) {
        let newPunch = date.setWeekday(weekday: self.day)
        if !self.punches.contains(where: { date in date.formatted(.dateTime.hour().minute()) == newPunch.formatted(.dateTime.hour().minute()) }) {
            var punchArray = self.punches
            punchArray.append(newPunch)
            punchArray.sort { $0 < $1 }
            self.punches.insert(newPunch, at: punchArray.firstIndex(of: newPunch)!)
        }
    }
    
    var totalHours: Double {
        var totalHours = 0.0
        let array = self.punches.sorted { $0 < $1 }
        for (index, punch) in Array(array.enumerated()) {
            if (index + 1).isMultiple(of: 2) && index != 0 {
                let previousPunch = self.punches[index - 1]
                totalHours += previousPunch.timeBetween(punch)
            }
        }
        return totalHours
    }
    
    var lastPunch: (punch: Date, isIn: Bool)? {
        if let punch = punches.last {
            (punch, !punches.count.isMultiple(of: 2) && !punches.isEmpty)
        } else {
            nil
        }
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
