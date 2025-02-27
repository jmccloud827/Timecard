import Foundation
import SwiftData

/// A model representing a single day within a week, containing punch data.
///
/// The `Day` class is responsible for storing punch times for a specific weekday,
/// calculating total hours worked, and managing punch-related logic. It is modeled as a
/// SwiftData entity for use with data persistence.
///
/// - Note: This class conforms to the `Identifiable` protocol, allowing it to be uniquely identified.
@Model class Day: Identifiable {
    @Attribute(.unique) var id = UUID()
    var weekDay: WeekDay
    var punches: [Date]
    
    /// Initializes a new `Day` instance for the specified weekday.
    ///
    /// - Parameter weekDay: The day of the week this instance represents.
    init(weekDay: WeekDay) {
        self.weekDay = weekDay
        self.punches = []
    }
    
    /// Adds a punch time to the day, ensuring no duplicate times exist.
    ///
    /// - Parameter date: The date and time of the punch to add.
    func addPunch(_ date: Date) {
        let newPunch = date.setWeekday(weekday: self.weekDay)
        if !self.punches.contains(where: { date in date.formatted(.dateTime.hour().minute()) == newPunch.formatted(.dateTime.hour().minute()) }) {
            var punchArray = self.punches
            punchArray.append(newPunch)
            punchArray.sort { $0 < $1 }
            self.punches.insert(newPunch, at: punchArray.firstIndex(of: newPunch)!)
        }
    }
    
    /// Calculates the total hours worked based on the punch times.
    ///
    /// - Returns: A `Double` representing the total hours worked for the day.
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
    
    /// Gets the last punch time for the day and indicates whether the last punch was an "in" punch.
    ///
    /// - Returns: An optional tuple containing the last punch time and a boolean indicating if the punch was an "in" punch.
    var lastPunch: (punch: Date, isIn: Bool)? {
        if let punch = punches.last {
            (punch, !punches.count.isMultiple(of: 2) && !punches.isEmpty)
        } else {
            nil
        }
    }
    
    /// Indicates whether the punch button should be disabled based on the time since the last punch.
    ///
    /// - Returns: A boolean indicating if the punch button is disabled.
    var isPunchButtonDisabled: Bool {
        punches.last?.timeBetween(Date.now) ?? 1 < (1 / 60)
    }
}

/// An enumeration representing the days of the week.
///
/// The `WeekDay` enum provides a representation of the days of the week and includes functionality
/// to retrieve the current weekday and display names for each day.
enum WeekDay: Int, Codable, CaseIterable {
    case monday = 2,
         tuesday = 3,
         wednesday = 4,
         thursday = 5,
         friday = 6,
         saturday = 7,
         sunday = 1
    
    /// The display name for the weekday.
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
    
    /// The current weekday based on the system's current date.
    ///
    /// - Returns: The current `WeekDay` instance corresponding to today.
    static var currentWeekday: Self {
        let weekday = Calendar.current.component(.weekday, from: Date.now)
        return Self.allCases.first { day in day.rawValue == weekday } ?? .monday
    }
}
