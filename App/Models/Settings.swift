import SwiftUI

/// A class that manages application settings related to work hours and days.
///
/// The `Settings` class uses `@AppStorage` to persist user preferences for default total hours,
/// default hours per day, default break duration, and workdays. It also provides computed properties
/// to determine the user's workdays and days off.
class Settings: ObservableObject {
    @AppStorage("Default Total Hours") var defaultTotalHours = 40.0
    @AppStorage("Default Hours") var defaultHours = 8.0
    @AppStorage("Default Break") var defaultBreak = 60
    @AppStorage("Work Days") var defaultWorkDays = "2,3,4,5,6,"
    
    /// A computed property that returns an array of `WeekDay` representing the user's workdays.
    ///
    /// The workdays are obtained from the `defaultWorkDays` string, which is split into individual
    /// day values. The days are then filtered and converted into `WeekDay` instances, sorted by their
    /// raw values.
    var workDays: [WeekDay] {
        var days: [WeekDay] = []
        let defaultWorkDays = defaultWorkDays.split(separator: ",")
        for workDay in defaultWorkDays {
            let day = WeekDay.allCases.filter { day in day.rawValue == Int(workDay) }.first
            if let day {
                days.append(day)
            }
        }
        days.sort { $0.rawValue < $1.rawValue }
        return days
    }
       
    /// A computed property that returns an array of `WeekDay` representing the user's days off.
    ///
    /// This property filters all days of the week to return those that are not included in the
    /// `workDays` array.
    var daysOff: [WeekDay] {
        return WeekDay.allCases.filter { day in !workDays.contains(day) }
    }
}
