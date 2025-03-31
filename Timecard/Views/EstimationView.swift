import SwiftUI

/// A view that provides an estimation of when the user will reach their expected total hours worked.
///
/// The `EstimationView` calculates and displays the estimated time to reach the expected total hours
/// based on the user's last punch and the current total hours worked. It also considers the default break
/// duration set in the application settings.
struct EstimationView: View {
    @EnvironmentObject private var settings: Settings
    
    var lastPunch: (punch: Date, isIn: Bool)?
    var currentTotalHours: Double
    var expectedTotalHours: Double
    
    private var hoursLeft: Double { expectedTotalHours - currentTotalHours }
    private var hoursLeftPlusBreak: Double { hoursLeft + Double(settings.defaultBreak) / 60.0 }
    
    @State private var now = Date.now
    
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label)
            
            hoursLeftLabel
            
            hoursLeftPlusBreakLabel
        }
        .onReceive(timer) { _ in
            onReceiveOfTimer()
        }
    }
    
    private var label: String {
        if lastPunch?.isIn ?? false {
            "You will hit:"
        } else {
            "If you clock in at \(now.formatted(date: .omitted, time: .shortened)) you will hit:"
        }
    }
    
    private var hoursLeftLabel: some View {
        HStack {
            Text("\(expectedTotalHours.toString()) hours for today at:")
                .padding(.leading, 10)
            
            Spacer()
            
            if hoursLeft > 0 {
                Text(lastPunchOrNow.addingTimeInterval(hoursLeft * 60 * 60).formatted(date: .omitted, time: .shortened))
            } else {
                Image(systemName: "checkmark")
            }
        }
    }
    
    private var hoursLeftPlusBreakLabel: some View {
        HStack {
            Text("with a \(settings.defaultBreak) minute break:")
                .padding(.leading, 20)
            
            Spacer()
            
            if hoursLeftPlusBreak > 0 {
                Text(lastPunchOrNow.addingTimeInterval(hoursLeftPlusBreak * 60 * 60).formatted(date: .omitted, time: .shortened))
            } else {
                Image(systemName: "checkmark")
            }
        }
    }
    
    private var lastPunchOrNow: Date {
        if let lastPunch, lastPunch.isIn {
            lastPunch.punch
        } else {
            now
        }
    }
    
    private func onReceiveOfTimer() {
        now = Date.now
    }
}

#Preview {
    List {
        EstimationView(lastPunch: (Date.now, true), currentTotalHours: 7, expectedTotalHours: 8)
    }
    .environmentObject(Settings())
}
