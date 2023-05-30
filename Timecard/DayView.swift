import SwiftUI

struct DayView: View {
    var day: String
    @Binding var inDate: Date
    @Binding var outDate: Date
    @Binding var breakDate: Int
    
    var body: some View {
        Section {
            DatePicker("In", selection: $inDate, displayedComponents: .hourAndMinute)
            DatePicker("Out", selection: $outDate, displayedComponents: .hourAndMinute)
            MinutePicker("Break", breakTime: $breakDate)
        } header: {
            HStack {
                Text(day)
                Spacer()
                Text("Hours: \(Date.timeBetween(inDate: inDate, outDate: outDate, breakMinutes: breakDate).toString())")
            }
        }
    }
}
