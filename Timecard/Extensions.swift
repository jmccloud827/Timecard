import SwiftUI

func print(_ items: Any...) {
#if DEBUG
    for item in items { Swift.print(item, separator: "", terminator: "") }
    Swift.print("")
#endif
}

extension View {
    @ViewBuilder func scrollDismissesKeyboard() -> some View {
        if #available(iOS 16.0, *) {
            self.scrollDismissesKeyboard(.interactively)
        } else {
            self
        }
    }
}

extension Double {
    func toString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumIntegerDigits = 1
        formatter.maximumIntegerDigits = 2
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(floatLiteral: self)) ?? ""
    }
}

extension Date {
    static func timeBetween(inDate: Date, outDate: Date, breakMinutes: Int) -> Double {
        let inCalender = Calendar.current.dateComponents([.hour, .minute], from: inDate)
        let outCalender = Calendar.current.dateComponents([.hour, .minute], from: outDate)
        let hours = Double(outCalender.hour ?? 0) - Double(inCalender.hour ?? 0)
        let minutes = Double(outCalender.minute ?? 0) - Double(inCalender.minute ?? 0) - Double(breakMinutes)
        return hours + (minutes / 60.0)
    }
}
