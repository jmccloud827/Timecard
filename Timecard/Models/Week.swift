import Foundation
import SwiftData

@Model class Week: Identifiable {
    @Attribute(.unique) var id = UUID()
    
    var sunday = Day(day: .sunday)
    
    var monday = Day(day: .monday)
    
    var tuesday = Day(day: .tuesday)
    
    var wednesday = Day(day: .wednesday)
    
    var thursday = Day(day: .thursday)
    
    var friday = Day(day: .friday)
    
    var saturday = Day(day: .saturday)
    
    var defaultTotalHours = 40.0
    var defaultHours = 8.0
    var defaultBreak = 60
    
    init() {}
    
    var currentDay: Day {
        switch Days.currentWeekday {
        case .sunday:
            sunday
            
        case .monday:
            monday
            
        case .tuesday:
            tuesday
            
        case .wednesday:
            wednesday
            
        case .thursday:
            thursday
            
        case .friday:
            friday
            
        case .saturday:
            saturday
        }
    }
    
    var weekToDate: Double {
        let days = [sunday, monday, tuesday, wednesday, thursday, friday, saturday]
        return days.map { day in day.totalHours }.reduce(0, +)
    }
    
    var lastPunch: Date? {
        let days = [sunday, monday, tuesday, wednesday, thursday, friday, saturday].reversed()
        for day in days {
            if let lastPunch = day.punches.last {
                return lastPunch
            }
        }
        
        return nil
    }
    
    func setWeekdays() {
        let days = [sunday, monday, tuesday, wednesday, thursday, friday, saturday]
        for day in days {
            day.punches = day.punches.map { punch in punch.setWeekday(weekday: day.day) }
        }
    }
    
    func clear() {
        sunday = Day(day: .sunday)
        monday = Day(day: .monday)
        tuesday = Day(day: .tuesday)
        wednesday = Day(day: .wednesday)
        thursday = Day(day: .thursday)
        friday = Day(day: .friday)
        saturday = Day(day: .saturday)
    }
    
    static var mockWeek: Week {
        let week = Week()
        
        week.sunday.addPunch(Date.now.addingTimeInterval(-10_000))
        week.sunday.addPunch(Date.now.addingTimeInterval(-100))
        
        week.monday.addPunch(Date.now.addingTimeInterval(-10_000))
        week.monday.addPunch(Date.now.addingTimeInterval(-100))
        
        week.tuesday.addPunch(Date.now.addingTimeInterval(-10_000))
        week.tuesday.addPunch(Date.now.addingTimeInterval(-100))
        
        week.wednesday.addPunch(Date.now.addingTimeInterval(-10_000))
        week.wednesday.addPunch(Date.now.addingTimeInterval(-100))
        
        week.thursday.addPunch(Date.now.addingTimeInterval(-10_000))
        week.thursday.addPunch(Date.now.addingTimeInterval(-100))
        
        week.friday.addPunch(Date.now.addingTimeInterval(-10_000))
        week.friday.addPunch(Date.now.addingTimeInterval(-100))
        
        week.saturday.addPunch(Date.now.addingTimeInterval(-10_000))
        week.saturday.addPunch(Date.now.addingTimeInterval(-100))
        
        return week
    }
}
