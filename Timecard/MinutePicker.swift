import SwiftUI

struct MinutePicker: View {
    let text: String
    @Binding var breakTime: Int
    
    init(_ text: String, breakTime: Binding<Int>) {
        self.text = text
        _breakTime = breakTime
    }
    
    var body: some View {
        Picker(text, selection: $breakTime) {
            ForEach(0...60, id: \.self) {
                Text("\($0) Minute\($0 == 1 ? "" : "s")")
            }
        }
    }
}
