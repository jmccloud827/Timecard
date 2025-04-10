import Foundation

extension Date {
    /// Sets the weekday for the date based on the provided `WeekDay`.
    ///
    /// This method modifies the weekday component of the date while preserving
    /// the hour and minute components.
    ///
    /// - Parameter weekday: The `WeekDay` to set for the date.
    /// - Returns: A new `Date` instance with the specified weekday.
    func setWeekday(weekday: WeekDay) -> Date {
        let calendar = Calendar.current
        var components = Calendar.current.dateComponents([.hour, .minute, .weekday, .year, .month, .day], from: self)
        components.weekday = weekday.rawValue
        return calendar.date(from: components) ?? Date.now
    }
    
    /// Calculates the time difference in hours between the current date and another date.
    ///
    /// - Parameter date: The date to compare against.
    /// - Returns: A `Double` representing the time difference in hours.
    func timeBetween(_ date: Date) -> Double {
        let inCalendar = Calendar.current.dateComponents([.hour, .minute], from: self)
        let outCalendar = Calendar.current.dateComponents([.hour, .minute], from: date)
        let hours = Double(outCalendar.hour ?? 0) - Double(inCalendar.hour ?? 0)
        let minutes = Double(outCalendar.minute ?? 0) - Double(inCalendar.minute ?? 0)
        return hours + (minutes / 60.0)
    }
}

extension Double {
    /// Converts the double value to a formatted string.
    ///
    /// The string will have a minimum of one integer digit and a maximum of two,
    /// with a minimum of two decimal places and a maximum of one decimal place.
    ///
    /// - Returns: A `String` representation of the double value.
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
