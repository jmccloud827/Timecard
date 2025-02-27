import AppIntents
import SwiftData
import SwiftUI
import WidgetKit

struct TimecardWidget: SwiftUI.Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Widget", provider: Provider()) { entry in
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                let config = ModelConfiguration(isStoredInMemoryOnly: true)
                let container = try! ModelContainer(for: Week.self, configurations: config)
                
                let _ = container.mainContext.insert(Week.mockWeek)
                
                TimecardWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
                    .modelContainer(container)
            } else {
                TimecardWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
                    .modelContainer(for: Week.self)
            }
        }
        .configurationDisplayName("Timecard")
        .description("Timecard punch system.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct TimecardWidgetEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.widgetFamily) private var family
    
    var entry: Provider.Entry
    
    @StateObject private var settings = Settings()
    
    @Query private var weeks: [Week]

    var body: some View {
        Group {
            if let week = weeks.first {
                VStack(spacing: 0) {
                    Group {
                        if family == .systemSmall {
                            VStack {
                                Text("Last punch:")
                                    .font(.headline)
                                
                                let date = week.currentDay.punches.last
                                if let date {
                                    Text(date.formatted(date: .abbreviated, time: .shortened))
                                } else {
                                    Text("N/A")
                                }
                            }
                        } else {
                            HStack {
                                Text("Last punch:")
                                    .font(.headline)
                                
                                let date = week.currentDay.punches.last
                                if let date {
                                    Text(date.formatted(date: .abbreviated, time: .shortened))
                                } else {
                                    Text("N/A")
                                }
                            }
                            .padding(.bottom, family == .systemLarge ? 10 : 5)
                        }
                    }
                    .multilineTextAlignment(.center)
                    
                    
                    if family != .systemSmall {
                        RoundedRectangle(cornerSize: .init(width: 20, height: 20), style: .continuous)
                            .foregroundStyle(.accent.opacity(0.2))
                            .overlay {
                                VStack {
                                    EstimationView(lastPunch: week.currentDay.lastPunch, currentTotalHours: week.currentDay.totalHours, expectedTotalHours: settings.defaultHours)
                                        .font(family == .systemLarge ? .body : .caption)
                                        .padding(.bottom, family == .systemLarge ? 5 : 0)
                                    
                                    if family == .systemLarge {
                                        EstimationView(lastPunch: week.currentDay.lastPunch, currentTotalHours: week.currentDay.totalHours, expectedTotalHours: settings.defaultHours)
                                            .padding(.bottom, 5)
                                    }
                                    
                                    if family == .systemLarge {
                                        Spacer()
                                    }
                                }
                                .padding()
                            }
                            .padding(.bottom, family == .systemLarge ? 10 : 0)
                    }
                    
                    Spacer()
                    
                    Button(intent: PunchAppIntent()) {
                        Text("Punch")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(week.currentDay.isPunchButtonDisabled)
                }
                .environmentObject(settings)
            } else {
                Button {
                    let week = Week()
                    modelContext.insert(week)
                } label: {
                    Text("Get started")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .tint(.accent)
        .dynamicTypeSize(.xSmall ... .large)
    }
}

struct Provider: TimelineProvider {
    func placeholder(in _: Context) -> TimecardEntry {
        TimecardEntry(date: Date())
    }

    func getSnapshot(in _: Context, completion: @escaping (TimecardEntry) -> Void) {
        let entry = TimecardEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<TimecardEntry>) -> Void) {
        var entries: [TimecardEntry] = []

        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = TimecardEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct TimecardEntry: TimelineEntry {
    let date: Date
}

struct PunchAppIntent: AppIntent {
    nonisolated static let title: LocalizedStringResource = "Add punch"
    
    init() {}
    
    @MainActor func perform() async throws -> some IntentResult {
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        let container = try! ModelContainer(for: Week.self, configurations: config)
        let week = try container.mainContext.fetch(FetchDescriptor<Week>()).first
        week?.currentDay.addPunch(Date.now)
        try container.mainContext.save()
        WidgetCenter.shared.reloadAllTimelines()
        
        return .result()
    }
}

#Preview("Small", as: .systemSmall) {
    TimecardWidget()
} timeline: {
    TimecardEntry(date: .now)
}

#Preview("Medium", as: .systemMedium) {
    TimecardWidget()
} timeline: {
    TimecardEntry(date: .now)
}

#Preview("Large", as: .systemLarge) {
    TimecardWidget()
} timeline: {
    TimecardEntry(date: .now)
}
