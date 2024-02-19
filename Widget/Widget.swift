import AppIntents
import WidgetKit
import SwiftData
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), emoji: "😀")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), emoji: "😀")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, emoji: "😀")
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let emoji: String
}

struct WidgetEntryView : View {
    @Environment(\.modelContext) private var modelContext
    
    var entry: Provider.Entry
    
    @Query private var days: [Day]

    var body: some View {
        VStack {
            HStack {
                Text("Last punch:")
                
                let date = days.first { day in day.id == Days.currentWeekday }?.punches.last
                if let date {
                    Text(date.formatted(.dateTime.hour().minute()))
                } else {
                    Text("N/A")
                }
            }

            Spacer()
            
            Button(intent: PunchAppIntent()) {
                Text("Punch")
                    .frame(maxWidth: .infinity)
            }
            .controlSize(.large)
        }
    }
}

struct PunchAppIntent: AppIntent {
    static let title: LocalizedStringResource = "My title"
    static let description: IntentDescription = .init("My description")
    
    init() { }
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

struct Widget: SwiftUI.Widget {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Day.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Widget", provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .modelContainer(sharedModelContainer)
        }
        .configurationDisplayName("Timecard")
        .description("Timcard punch system.")
    }
}

#Preview(as: .systemSmall) {
    Widget()
} timeline: {
    SimpleEntry(date: .now, emoji: "😀")
    SimpleEntry(date: .now, emoji: "🤩")
}
