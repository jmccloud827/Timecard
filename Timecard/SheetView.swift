import SwiftUI

struct SheetView: View {
    @ObservedObject var viewModel: ViewModel
    var body: some View {
        Form {
            Section("Default Values") {
                DoubleTextView("Total Hours", double: $viewModel.totalHours)
                DatePicker("Default Time In", selection: $viewModel.defaultTimeIn, displayedComponents: .hourAndMinute)
                DatePicker("Default Time Out", selection: $viewModel.defaultTimeOut, displayedComponents: .hourAndMinute)
                MinutePicker("Default Break", breakTime: $viewModel.defaultBreak)
            }
            
            Section("Works Days") {
                ForEach(viewModel.workDays) { day in
                    HStack {
                        Text(day.name)
                        Spacer()
                        Button {
                            withAnimation {
                                viewModel.workDays = viewModel.workDays.filter { $0.name != day.name }
                                viewModel.daysOff.append(day)
                                viewModel.daysOff.sort { $0.index < $1.index }
                            }
                        } label: {
                            Label("Remove", systemImage: "minus.circle.fill").foregroundColor(.red).labelStyle(.iconOnly)
                        }
                    }
                }
            }
            
            Section("Days Off") {
                ForEach(viewModel.daysOff) { day in
                    HStack {
                        Text(day.name)
                        Spacer()
                        Button {
                            withAnimation {
                                viewModel.daysOff = viewModel.daysOff.filter { $0.name != day.name }
                                viewModel.workDays.append(day)
                                viewModel.workDays.sort { $0.index < $1.index }
                            }
                        } label: {
                            Label("Add", systemImage: "plus.circle.fill").foregroundColor(.green).labelStyle(.iconOnly)
                        }
                    }
                }
            }
        }
    }
}
