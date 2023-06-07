import Combine
import SwiftUI

class ViewModel: ObservableObject, Codable {
    @AppStorage("AppState") var storage = ""
    
    @Published var tabSelection = 1

    
    @Published var totalHours = 40.0
    @Published var defaultTimeIn = getDefaultDate(isIn: true) {
        willSet {
            workDays.forEach { day in
                if day.timeIn == defaultTimeIn {
                    day.timeIn = newValue
                }
            }
            daysOff.forEach { day in
                if day.timeIn == defaultTimeIn {
                    day.timeIn = newValue
                }
            }
        }
    }
    @Published var defaultTimeOut = getDefaultDate(isIn: false) {
        willSet {
            workDays.forEach { day in
                if day.timeOut == defaultTimeOut {
                    day.timeOut = newValue
                }
            }
            daysOff.forEach { day in
                if day.timeOut == defaultTimeOut {
                    day.timeOut = newValue
                }
            }
        }
    }
    @Published var defaultBreak = 0 {
        willSet {
            workDays.forEach { day in
                if day.breakTime == defaultBreak {
                    day.breakTime = newValue
                }
            }
            daysOff.forEach { day in
                if day.breakTime == defaultBreak {
                    day.breakTime = newValue
                }
            }
        }
    }
    @Published var disableAds = false
    @Published var workDays: [Day] = [
        .init(name: "Monday", index: 1),
        .init(name: "Tuesday", index: 2),
        .init(name: "Wednesday", index: 3),
        .init(name: "Thursday", index: 4),
        .init(name: "Friday", index: 5)
    ]
    @Published var daysOff: [Day] = [
        .init(name: "Saturday", index: 6),
        .init(name: "Sunday", index: 7)
    ]
    
    enum CodingKeys: CodingKey {
        case tabSelection,
             workDays,
             daysOff,
             totalHours,
             defaultTimeIn,
             defaultTimeOut,
             defaultBreak,
             disableAds
    }
    
    init() {}
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        tabSelection = try container.decode(Int.self, forKey: .tabSelection)
        workDays = try container.decode(Array.self, forKey: .workDays)
        daysOff = try container.decode(Array.self, forKey: .daysOff)
        totalHours = try container.decode(Double.self, forKey: .totalHours)
        defaultTimeIn = try container.decode(Date.self, forKey: .defaultTimeIn)
        defaultTimeOut = try container.decode(Date.self, forKey: .defaultTimeOut)
        defaultBreak = try container.decode(Int.self, forKey: .defaultBreak)
        disableAds = try container.decode(Bool.self, forKey: .disableAds)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tabSelection, forKey: .tabSelection)
        try container.encode(workDays, forKey: .workDays)
        try container.encode(daysOff, forKey: .daysOff)
        try container.encode(totalHours, forKey: .totalHours)
        try container.encode(defaultTimeIn, forKey: .defaultTimeIn)
        try container.encode(defaultTimeOut, forKey: .defaultTimeOut)
        try container.encode(defaultBreak, forKey: .defaultBreak)
        try container.encode(disableAds, forKey: .disableAds)
    }
    
    class Day: ObservableObject, Codable, Identifiable {
        @Published var name: String
        @Published var index: Int
        @Published var timeIn: Date
        @Published var timeOut: Date
        @Published var breakTime: Int
        
        init(name: String, index: Int, timeIn: Date = getDefaultDate(isIn: true), timeOut: Date = getDefaultDate(isIn: false), breakTime: Int = 0) {
            self.name = name
            self.index = index
            self.timeIn = timeIn
            self.timeOut = timeOut
            self.breakTime = breakTime
        }
        
        enum CodingKeys: CodingKey {
            case name,
                 index,
                 timeIn,
                 timeOut,
                 breakTime
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(String.self, forKey: .name)
            index = try container.decode(Int.self, forKey: .index)
            timeIn = try container.decode(Date.self, forKey: .timeIn)
            timeOut = try container.decode(Date.self, forKey: .timeOut)
            breakTime = try container.decode(Int.self, forKey: .breakTime)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(index, forKey: .index)
            try container.encode(timeIn, forKey: .timeIn)
            try container.encode(timeOut, forKey: .timeOut)
            try container.encode(breakTime, forKey: .breakTime)
        }
    }
    
    static func getDefaultDate(isIn: Bool) -> Date {
        let calenderDate = Calendar.current.dateComponents([.day, .year, .month], from: Date.now)
        var comps = DateComponents()
        comps.day = calenderDate.day
        comps.month = calenderDate.month
        comps.year = calenderDate.year
        comps.hour = isIn ? 9 : 17
        comps.minute = 0
        
        return Calendar.current.date(from: comps)!
    }
    
    func clear() {
        workDays.forEach { day in
            day.timeIn = defaultTimeIn
            day.timeOut = defaultTimeOut
            day.breakTime = defaultBreak
        }
        daysOff.forEach { day in
            day.timeIn = defaultTimeIn
            day.timeOut = defaultTimeOut
            day.breakTime = defaultBreak
        }
        self.objectWillChange.send()
    }
    
    func saveData() {
        if let json = try? JSONEncoder().encode(self) {
            print(String(decoding: json, as: UTF8.self))
            storage = String(decoding: json, as: UTF8.self)
        }
    }
    
    func getTotal() -> Double {
        return workDays.map { day in
            Date.timeBetween(inDate: day.timeIn, outDate: day.timeOut, breakMinutes: day.breakTime)
        }.reduce(0, +)
    }
}
