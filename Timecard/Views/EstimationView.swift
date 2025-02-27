import SwiftUI

struct EstimationView: View {
    @EnvironmentObject private var settings: Settings
    
    var lastPunch: (punch: Date, isIn: Bool)?
    var currentTotalHours: Double
    var expectedTotalHours: Double
    
    private var hoursLeft: Double { expectedTotalHours - currentTotalHours }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("You will hit:")
            
            HStack {
                Text("\(expectedTotalHours.toString()) hours for today at:")
                    .padding(.leading, 10)
                
                Spacer()
                
                if let lastPunch {
                    if hoursLeft > 0 {
                        Text(calcLastPunch(lastPunch: lastPunch).addingTimeInterval(hoursLeft * 60 * 60).formatted(date: .omitted, time: .shortened))
                    } else {
                        Image(systemName: "checkmark")
                    }
                } else {
                    Text("N/A")
                }
            }
            
            HStack {
                Text("with a \(settings.defaultBreak) minute break:")
                    .padding(.leading, 20)
                
                Spacer()
                
                if let lastPunch {
                    let hoursLeftPlusBreak = hoursLeft + Double(settings.defaultBreak) / 60.0
                    if hoursLeftPlusBreak > 0 {
                        Text(calcLastPunch(lastPunch: lastPunch).addingTimeInterval(hoursLeftPlusBreak * 60 * 60).formatted(date: .omitted, time: .shortened))
                    } else {
                        Image(systemName: "checkmark")
                    }
                } else {
                    Text("N/A")
                }
            }
        }
    }
    
    private func calcLastPunch(lastPunch: (punch: Date, isIn: Bool)) -> Date {
        lastPunch.isIn ? lastPunch.punch : Date.now
    }
}

#Preview {
    List {
        EstimationView(lastPunch: (Date.now, true), currentTotalHours: 7, expectedTotalHours: 8)
    }
    .environmentObject(Settings())
}
