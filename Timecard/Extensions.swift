import Foundation

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
        var components = Calendar.current.dateComponents([.hour, .minute, .weekday, .year, .month, .day], from: self)
        components.weekday = weekday.rawValue
        return calendar.date(from: components) ?? Date.now
    }
    
    func timeBetween(_ date: Date) -> Double {
        let inCalendar = Calendar.current.dateComponents([.hour, .minute], from: self)
        let outCalendar = Calendar.current.dateComponents([.hour, .minute], from: date)
        let hours = Double(outCalendar.hour ?? 0) - Double(inCalendar.hour ?? 0)
        let minutes = Double(outCalendar.minute ?? 0) - Double(inCalendar.minute ?? 0)
        return hours + (minutes / 60.0)
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
