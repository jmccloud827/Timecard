import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var days: [Day]
    
    @AppStorage("Default Total Hours") private var defaultTotalHours = 40.0
    @AppStorage("Default Hours") private var defaultHours = 8.0
    @AppStorage("Default Break") private var defaultBreak = 60
    @AppStorage("Work Days") private var defaultWorkDays = "2,3,4,5,6,"
    
    private var sortedDays: [Day] {
        days.filter { day in workDays.contains(day.id) }.sorted { $0.id.rawValue < $1.id.rawValue }
    }
    
    private var weekToDate: Double {
        sortedDays.map { day in day.totalHours }.reduce(0, +)
    }
    
    private var lastDay: Day? {
        sortedDays.last { day in !day.punches.isEmpty }
    }
    
    private var currentDay: Day? {
        days.first(where: { day in day.id == Days.currentWeekday })
    }
    
    private var workDays: [Days] {
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
    
    private var daysOff: [Days] {
        return Days.allCases.filter { day in !workDays.contains(day) }
    }
    
    @State private var showSheet = false
    @State private var inputWeekToDate = 40.0
    @State private var inputLastPunch = Date.now
    @State private var addBreak = true
    @State private var inputBreakMinutes = 0
    @State private var update = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        TabView {
            NavigationStack {
                VStack {
                    Form {
                        HStack {
                            Text("Last Punch:")
                            
                            Spacer()
                            
                            Text("\(lastDay?.lastPunch?.punch.formatted() ?? "N/A")")
                        }
                        
                        HStack {
                            Text("Week to Date:")
                            
                            Spacer()
                            
                            Text("\(weekToDate.toString())")
                        }
                        
                        let calcHoursLeft: (Day) -> Double = { currentDay in defaultHours - currentDay.totalHours }
                        let calcHoursLeftWithBreak: (Day) -> Double = { currentDay in calcHoursLeft(currentDay) + Double(defaultBreak) / 60.0 }
                        let calcLastPunch: (Date, Bool) -> Date = { punch, isIn in isIn ? punch : Date.now }
                        VStack(spacing: 0) {
                            HStack {
                                Text("You will hit \(defaultHours.toString()) for today at:")
                                
                                Spacer()
                                
                                if let currentDay, let lastPunch = currentDay.lastPunch {
                                    var hoursLeft = calcHoursLeft(currentDay)
                                    var newLastPunch = calcLastPunch(lastPunch.punch, lastPunch.isIn)
                                    Group {
                                        if hoursLeft > 0 {
                                            let picker =
                                                DatePicker("", selection: Binding.constant(newLastPunch.addingTimeInterval(hoursLeft * 60 * 60)), displayedComponents: .hourAndMinute)
                                                .labelsHidden()
                                                .disabled(true)
                                            if update {
                                                picker
                                            } else {
                                                picker
                                            }
                                        } else {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                    .onReceive(timer) { _ in
                                        hoursLeft = calcHoursLeft(currentDay)
                                        newLastPunch = calcLastPunch(lastPunch.punch, lastPunch.isIn)
                                        update.toggle()
                                    }
                                } else {
                                    Text("N/A")
                                }
                            }
                            
                            HStack {
                                Spacer()
                                
                                Text("with \(defaultBreak) minute break:")
                                
                                Spacer()
                                
                                if let currentDay, let lastPunch = currentDay.lastPunch {
                                    var hoursLeft = calcHoursLeftWithBreak(currentDay)
                                    var newLastPunch = calcLastPunch(lastPunch.punch, lastPunch.isIn)
                                    Group {
                                        let picker =
                                            DatePicker("", selection: Binding.constant(newLastPunch.addingTimeInterval(hoursLeft * 60 * 60)), displayedComponents: .hourAndMinute)
                                            .labelsHidden()
                                            .disabled(true)
                                        if update {
                                            picker
                                        } else {
                                            picker
                                        }
                                    }
                                    .onReceive(timer) { _ in
                                        hoursLeft = calcHoursLeftWithBreak(currentDay)
                                        newLastPunch = calcLastPunch(lastPunch.punch, lastPunch.isIn)
                                    }
                                } else {
                                    Text("N/A")
                                }
                            }
                        }
                        
                        if weekToDate > defaultTotalHours - defaultHours * 1.1 {
                            VStack(spacing: 0) {
                                HStack {
                                    Text("You will hit \(defaultTotalHours.toString()) at:")
                                    
                                    Spacer()
                                    
                                    if let currentDay, let lastPunch = currentDay.lastPunch {
                                        var hoursLeft = calcHoursLeft(currentDay)
                                        var newLastPunch = calcLastPunch(lastPunch.punch, lastPunch.isIn)
                                        Group {
                                            if hoursLeft > 0 {
                                                let picker =
                                                    DatePicker("", selection: Binding.constant(getTimeOut(lastPunch: newLastPunch, weekToDate: weekToDate)), displayedComponents: .hourAndMinute)
                                                    .labelsHidden()
                                                    .disabled(true)
                                                if update {
                                                    picker
                                                } else {
                                                    picker
                                                }
                                            } else {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                        .onReceive(timer) { _ in
                                            hoursLeft = calcHoursLeft(currentDay)
                                            newLastPunch = calcLastPunch(lastPunch.punch, lastPunch.isIn)
                                        }
                                    } else {
                                        Text("N/A")
                                    }
                                }
                                
                                HStack {
                                    Spacer()
                                    
                                    Text("with \(defaultBreak) minute break:")
                                    
                                    Spacer()
                                    
                                    if let currentDay, let lastPunch = currentDay.lastPunch {
                                        var hoursLeft = calcHoursLeftWithBreak(currentDay)
                                        var newLastPunch = calcLastPunch(lastPunch.punch, lastPunch.isIn)
                                        Group {
                                            if hoursLeft > 0 {
                                                let picker =
                                                    DatePicker("", selection: Binding.constant(getTimeOut(lastPunch: newLastPunch, weekToDate: weekToDate)), displayedComponents: .hourAndMinute)
                                                    .labelsHidden()
                                                    .disabled(true)
                                                if update {
                                                    picker
                                                } else {
                                                    picker
                                                }
                                            } else {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                        .onReceive(timer) { _ in
                                            hoursLeft = calcHoursLeftWithBreak(currentDay)
                                            newLastPunch = calcLastPunch(lastPunch.punch, lastPunch.isIn)
                                        }
                                    } else {
                                        Text("N/A")
                                    }
                                }
                            }
                        }
                    }
                    
                    Button {
                        let date = Date.now
                        if let currentDay {
                            currentDay.punches.append(date)
                        } else {
                            let day = Day(id: Days.currentWeekday)
                            day.punches.append(date)
                            modelContext.insert(day)
                        }
                    } label: {
                        Text("Punch")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(currentDay?.punches.last?.timeBetween(Date.now) ?? 1 < (1 / 60))
                    .padding()
                }
                .navigationTitle("Dashboard")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showSheet = true
                        } label: {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                    }
                }
                .sheet(isPresented: $showSheet) {
                    Form {
                        Section("Default Values") {
                            HStack {
                                Text("Default Hours in week:")
                                
                                Spacer()
                                
                                TextField("", value: $defaultTotalHours, format: .number)
                                    .multilineTextAlignment(.trailing)
                                    .keyboardType(.decimalPad)
                                    .frame(width: 50)
                            }
                            
                            HStack {
                                Text("Default Hours in day:")
                                
                                Spacer()
                                
                                TextField("", value: $defaultHours, format: .number)
                                    .multilineTextAlignment(.trailing)
                                    .keyboardType(.decimalPad)
                                    .frame(width: 50)
                            }
                            
                            HStack {
                                Text("Default Break (Minutes):")
                                
                                Spacer()
                                
                                TextField("", value: $defaultBreak, format: .number)
                                    .multilineTextAlignment(.trailing)
                                    .keyboardType(.decimalPad)
                                    .frame(width: 50)
                            }
                        }
                        
                        Section("Work days") {
                            ForEach(workDays, id: \.rawValue) { workDay in
                                HStack {
                                    Text(workDay.displayValue)
                                    
                                    Spacer()
                                    
                                    Button {
                                        withAnimation {
                                            defaultWorkDays = defaultWorkDays.replacingOccurrences(of: "\(workDay.rawValue),", with: "")
                                        }
                                    } label: {
                                        Label("Remove", systemImage: "minus.circle.fill")
                                            .foregroundColor(.red)
                                            .labelStyle(.iconOnly)
                                    }
                                }
                            }
                        }
                        
                        Section("Days off") {
                            ForEach(daysOff, id: \.rawValue) { workDay in
                                HStack {
                                    Text(workDay.displayValue)
                                    
                                    Spacer()
                                    
                                    Button {
                                        withAnimation {
                                            defaultWorkDays += "\(workDay.rawValue),"
                                        }
                                    } label: {
                                        Label("Add", systemImage: "plus.circle.fill")
                                            .foregroundColor(.green)
                                            .labelStyle(.iconOnly)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .tabItem {
                Label("Dashboard", systemImage: "house")
            }
            
            NavigationStack {
                List {
                    HStack {
                        Text("Week to Date:")
                        
                        Spacer()
                        
                        Text(weekToDate.toString())
                    }
                    
                    ForEach(sortedDays) { day in
                        DayView(day: day)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear") {
                            for day in days {
                                day.punches = []
                            }
                        }
                    }
                }
                .navigationTitle("Timecard")
            }
            .tabItem {
                Label("Timecard", systemImage: "clock")
            }
            
            VStack(spacing: 0) {
                NavigationStack {
                    Form {
                        HStack {
                            Text("Week to Date:")
                            
                            Spacer()
                            
                            TextField("", value: $inputWeekToDate, format: .number)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.decimalPad)
                                .frame(width: 50)
                        }
                        
                        let calculate = {
                            if let lastDay, let lastPunch = currentDay?.lastPunch {
                                let now = (Date.now).setWeekday(weekday: lastDay.id)
                                var timeToAdd = 0.0
                                if lastPunch.isIn && now > lastPunch.punch {
                                    timeToAdd = lastPunch.punch.timeBetween((Date.now).setWeekday(weekday: lastDay.id))
                                }
                                inputWeekToDate = (Double(weekToDate.toString()) ?? 0.0) + (Double(timeToAdd.toString()) ?? 0.0)
                                inputLastPunch = lastPunch.isIn ? lastPunch.punch : Date.now
                                inputBreakMinutes = defaultBreak
                            }
                        }
                        DatePicker("Last Punch Time", selection: $inputLastPunch, displayedComponents: .hourAndMinute)
                            .onAppear {
                                calculate()
                            }
                            .onReceive(timer) { _ in
                                calculate()
                            }
                        
                        Toggle("Add Break?", isOn: $addBreak)
                        if addBreak {
                            HStack {
                                Text("Break Time (Minutes):")
                                
                                Spacer()
                                
                                TextField("", value: $inputBreakMinutes, format: .number)
                                    .multilineTextAlignment(.trailing)
                                    .keyboardType(.decimalPad)
                                    .frame(width: 50)
                            }
                        }
                        
                        DatePicker("You will hit \(defaultTotalHours.toString()) hours at:", selection: Binding.constant(getTimeOut(lastPunch: inputLastPunch, weekToDate: inputWeekToDate, breakMinutes: inputBreakMinutes)), displayedComponents: .hourAndMinute).disabled(true)
                    }
                    .navigationTitle("Calculator")
                }
            }
            .tabItem {
                Label("Calculator", systemImage: "minus.slash.plus")
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
            for weekday in Days.allCases {
                if !days.contains(where: { day in day.id == weekday }) {
                    let day = Day(id: weekday)
                    modelContext.insert(day)
                }
            }
            for day in days {
                day.punches = day.punches.map { punch in punch.setWeekday(weekday: day.id) }
            }
        }
    }
    
    func getTimeOut(lastPunch: Date, weekToDate: Double, breakMinutes: Int = 0) -> Date {
        lastPunch.addingTimeInterval(((defaultTotalHours - weekToDate) * 60 * 60) + Double(addBreak ? (breakMinutes * 60) : 0))
    }
}

struct DayView: View {
    @Bindable var day: Day
    
    @State private var showSheet = false
    @State private var newTime = Date.now
    
    var body: some View {
        Section {
            ForEach(Array($day.punches.enumerated()), id: \.offset) { index, punch in
                let isIn = index.isMultiple(of: 2)
                let previousPunch: Date? =
                    if index > 0 {
                        day.punches[index - 1]
                    } else {
                        nil
                    }
                
                let nextPunch: Date? =
                    if index < day.punches.count - 1 {
                        day.punches[index + 1]
                    } else {
                        nil
                    }
                if let previousPunch, let nextPunch {
                    DatePicker((isIn ? "In" : "Out") + ": ", selection: punch, in: previousPunch ... nextPunch, displayedComponents: .hourAndMinute)
                } else if let previousPunch {
                    DatePicker((isIn ? "In" : "Out") + ": ", selection: punch, in: previousPunch..., displayedComponents: .hourAndMinute)
                } else if let nextPunch {
                    DatePicker((isIn ? "In" : "Out") + ": ", selection: punch, in: ...nextPunch, displayedComponents: .hourAndMinute)
                } else {
                    DatePicker((isIn ? "In" : "Out") + ": ", selection: punch, displayedComponents: .hourAndMinute)
                }
            }
            .onDelete { offsets in
                withAnimation {
                    for index in offsets {
                        day.punches.remove(at: index)
                    }
                }
            }
        } header: {
            HStack {
                Text(day.id.displayValue)
                Spacer()
                Text("Total Hours: \(day.totalHours.toString())")
                Button {
                    showSheet = true
                } label: {
                    Label("Add", systemImage: "plus")
                        .labelStyle(.iconOnly)
                }
            }
        }
        .sheet(isPresented: $showSheet) {
            NavigationStack {
                DatePicker("New Time", selection: $newTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .datePickerStyle(.wheel)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") {
                                showSheet = false
                                addPunch()
                                newTime = Date.now
                            }
                        }
                        
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Cancel") {
                                showSheet = false
                                newTime = Date.now
                            }
                        }
                    }
            }
            .interactiveDismissDisabled()
            .presentationDetents([.height(200)])
        }
    }
    
    private func addPunch() {
        let newTime = newTime.setWeekday(weekday: day.id)
        if !day.punches.contains(where: { date in date.formatted(.dateTime.hour().minute()) == newTime.formatted(.dateTime.hour().minute()) }) {
            var punchArray = day.punches
            punchArray.append(newTime)
            punchArray.sort { $0 < $1 }
            day.punches.insert(newTime, at: punchArray.firstIndex(of: newTime)!)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Day.self, inMemory: true)
}
