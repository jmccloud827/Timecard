import AppIntents
import SwiftData
import SwiftUI
import WidgetKit

/// A widget that displays timecard information for the user.
///
/// The `TimecardWidget` provides a summary of the user's punch data, including their last punch time
/// and estimated time to reach expected total hours. It supports multiple widget sizes and updates
/// dynamically based on the user's settings and punch history.
struct TimecardWidget: SwiftUI.Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Widget", provider: Provider()) { entry in
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                let config = ModelConfiguration(isStoredInMemoryOnly: false)
                let container = try! ModelContainer(for: Week.self, Day.self, configurations: config)
                
                let _ = container.mainContext.insert(Week.sample)
                
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

/// A view that displays the entry for the timecard widget.
///
/// The `TimecardWidgetEntryView` presents the last punch time, current total hours, and
/// estimated time to reach expected hours based on the user's settings. It includes a button
/// to punch in and supports different layouts based on the widget family.
struct TimecardWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    
    var entry: Provider.Entry
    
    @StateObject private var settings = Settings()
    
    @Query private var weeks: [Week]

    var body: some View {
        Group {
            if let week = weeks.first {
                VStack(spacing: 0) {
                    Group {
                        let inside =
                            Group {
                                Text("Last punch:")
                                    .font(.headline)
                            
                                Text(week.lastPunch?.formatted(date: .abbreviated, time: .shortened) ?? "N/A")
                            }
                        if family == .systemSmall {
                            VStack {
                                inside
                            }
                        } else {
                            HStack {
                                inside
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
                                    
                                    if family == .systemLarge && week.currentDay.weekDay == settings.workDays.last {
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
                Button(intent: CreateWeekIntent()) {
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

/// A provider that supplies timeline entries for the timecard widget.
///
/// The `Provider` conforms to the `TimelineProvider` protocol and is responsible for creating
/// and managing the timeline of entries that the widget displays. It supplies placeholders,
/// snapshots, and timelines based on the current date and time.
struct Provider: TimelineProvider {
    /// Creates a placeholder entry for the widget.
    ///
    /// This method provides a simple entry that is displayed while the widget is loading.
    ///
    /// - Parameter context: The context in which the placeholder is displayed.
    /// - Returns: A `TimecardEntry` instance representing the placeholder.
    func placeholder(in _: Context) -> TimecardEntry {
        TimecardEntry(date: Date())
    }

    /// Retrieves a snapshot of the widget's content.
    ///
    /// This method is called to get a quick snapshot of the widget's current state.
    ///
    /// - Parameters:
    ///   - context: The context in which the snapshot is requested.
    ///   - completion: A closure that is called with the snapshot entry.
    func getSnapshot(in _: Context, completion: @escaping (TimecardEntry) -> Void) {
        let entry = TimecardEntry(date: Date())
        completion(entry)
    }

    /// Generates a timeline of entries for the widget.
    ///
    /// This method creates a series of entries based on the current date and time,
    /// providing updates for the widget at specified intervals.
    ///
    /// - Parameters:
    ///   - context: The context in which the timeline is generated.
    ///   - completion: A closure that is called with the generated timeline.
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

/// A structure representing an entry in the timecard widget's timeline.
///
/// The `TimecardEntry` conforms to the `TimelineEntry` protocol and contains a date
/// that represents the time associated with the entry.
struct TimecardEntry: TimelineEntry {
    let date: Date
}

/// An intent that handles adding a punch to the user's timecard.
///
/// The `PunchAppIntent` conforms to the `AppIntent` protocol and provides functionality
/// to add a punch entry when triggered from the widget.
struct PunchAppIntent: AppIntent {
    nonisolated static let title: LocalizedStringResource = "Add punch"
    
    /// Initializes a new instance of the intent.
    nonisolated init() {}
    
    /// Performs the action of adding a punch to the timecard.
    ///
    /// This method adds the current time as a punch entry to the user's timecard,
    /// saves the changes to the model, and reloads the widget timelines.
    ///
    /// - Returns: An `IntentResult` indicating the result of the operation.
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

/// An intent that handles creating a week for the user's timecard.
///
/// The `CreateWeekIntent` conforms to the `AppIntent` protocol and provides functionality
/// to create a week when triggered from the widget.
struct CreateWeekIntent: AppIntent {
    nonisolated static let title: LocalizedStringResource = "Create Week"
    
    /// Initializes a new instance of the intent.
    nonisolated init() {}
    
    /// Performs the action of creating a week for the timecard.
    ///
    /// This method creates a week for the user's timecard,
    /// saves the changes to the model, and reloads the widget timelines.
    ///
    /// - Returns: An `IntentResult` indicating the result of the operation.
    @MainActor func perform() async throws -> some IntentResult {
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        let container = try! ModelContainer(for: Week.self, Day.self, configurations: config)
        container.mainContext.insert(Week())
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
