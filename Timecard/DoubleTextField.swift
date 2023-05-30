import SwiftUI

struct DoubleTextView: View {
    let text: String
    @Binding var double: Double
    
    init(_ text: String, double: Binding<Double>) {
        self.text = text
        _double = double
    }
    
    var body: some View {
        HStack {
            Text(text)
            Spacer()
            TextField(text, value: $double, format: .number)
                .multilineTextAlignment(.trailing)
                .keyboardType(.decimalPad)
                .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                    if let textField = obj.object as? UITextField {
                        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                    }
                }
        }
    }
}
