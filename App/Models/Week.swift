import Foundation
import SwiftData
import SwiftUI
#if canImport(Vision)
    import Vision
#endif

/// A model representing a week of work days, containing daily punch data.
///
/// The `Week` class encapsulates the data for each day of the week, provides functionality to
/// add and clear punches, and computes total hours worked for the week. It is modeled as a
/// SwiftData entity for use with data persistence.
///
/// - Note: This class conforms to the `Identifiable` protocol, allowing it to be uniquely identified.
@Model class Week: Identifiable, Hashable {
    @Attribute(.unique) var id = UUID()
    
    var sunday = Day(weekDay: .sunday)
    
    var monday = Day(weekDay: .monday)
    
    var tuesday = Day(weekDay: .tuesday)
    
    var wednesday = Day(weekDay: .wednesday)
    
    var thursday = Day(weekDay: .thursday)
    
    var friday = Day(weekDay: .friday)
    
    var saturday = Day(weekDay: .saturday)
    
    /// Initializes a new `Week` instance with default days.
    init() {}
    
    /// The current day of the week based on the system's current weekday.
    var currentDay: Day {
        switch WeekDay.currentWeekday {
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
    
    /// Calculates the total hours worked for the week.
    ///
    /// - Returns: A `Double` representing the total hours worked across all days.
    var weekToDate: Double {
        let days = [sunday, monday, tuesday, wednesday, thursday, friday, saturday]
        return days.map { day in day.totalHours }.reduce(0, +)
    }
    
    /// Gets the last punch time from the week.
    ///
    /// - Returns: An optional `Date` representing the last punch time, or `nil` if no punches exist.
    var lastPunch: Date? {
        let days = [sunday, monday, tuesday, wednesday, thursday, friday, saturday].reversed()
        for day in days {
            if let lastPunch = day.punches.last {
                return lastPunch
            }
        }
        
        return nil
    }
    
    /// Sets the weekday for each punch in the week.
    func setWeekdays() {
        let days = [sunday, monday, tuesday, wednesday, thursday, friday, saturday]
        for day in days {
            day.punches = day.punches.map { punch in punch.setWeekday(weekday: day.weekDay) }
        }
    }
    
    /// Clears all punches for the week, resetting each day to its initial state.
    func clear() {
        sunday = Day(weekDay: .sunday)
        monday = Day(weekDay: .monday)
        tuesday = Day(weekDay: .tuesday)
        wednesday = Day(weekDay: .wednesday)
        thursday = Day(weekDay: .thursday)
        friday = Day(weekDay: .friday)
        saturday = Day(weekDay: .saturday)
    }
    
    #if canImport(Vision)
        /// Gets the punches from an image
        func getPunchesFromImage(image: UIImage) {
            guard let cgImage = image.cgImage else {
                return
            }
        
            let recognizeRequest = VNRecognizeTextRequest { request, _ in
                guard let result = request.results as? [VNRecognizedTextObservation] else {
                    return
                }
            
                let stringArray = result.compactMap { result in
                    result.topCandidates(1).first?.string
                }
            
                self.clear()
            
                let formatter = DateFormatter()
                formatter.dateFormat = "h:mm a"
                let formatter2 = DateFormatter()
                formatter2.dateFormat = "h•mm a"
            
                var currentDay = 0
                for index in stringArray {
                    if let date = (formatter.date(from: index) ?? formatter2.date(from: index)) {
                        switch currentDay {
                        case 0:
                            self.monday.addPunch(date)
                        case 1:
                            self.tuesday.addPunch(date)
                        case 2:
                            self.wednesday.addPunch(date)
                        case 3:
                            self.thursday.addPunch(date)
                        case 4:
                            self.friday.addPunch(date)
                        case 5:
                            self.saturday.addPunch(date)
                        case 6:
                            self.sunday.addPunch(date)
                        default:
                            print("Not a day")
                        }
                        
                        currentDay += 1
                    } else {
                        currentDay = 0
                    }
                }
            }
        
            recognizeRequest.recognitionLevel = .accurate
           
            let handler = VNImageRequestHandler(cgImage: cgImage)
            try? handler.perform([recognizeRequest])
        }
    #endif
    
    /// A mock `Week` instance with sample data for testing and previewing.
    static var sample: Week {
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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
