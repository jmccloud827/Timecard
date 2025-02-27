import SwiftUI

/// A view that allows users to configure application settings.
///
/// The `SettingsView` provides a user interface for adjusting default values related to
/// work hours, breaks, and workdays. Users can modify the default total hours, daily hours,
/// break duration, as well as add or remove workdays from their schedule.
struct SettingsView: View {
    @EnvironmentObject private var settings: Settings
    
    var body: some View {
        Form {
            Section("Default Values") {
                HStack {
                    Text("Default Hours in week:")
                    
                    Spacer()
                    
                    TextField("", value: $settings.defaultTotalHours, format: .number)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .frame(width: 50)
                }
                
                HStack {
                    Text("Default Hours in day:")
                    
                    Spacer()
                    
                    TextField("", value: $settings.defaultHours, format: .number)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .frame(width: 50)
                }
                
                HStack {
                    Text("Default Break (Minutes):")
                    
                    Spacer()
                    
                    TextField("", value: $settings.defaultBreak, format: .number)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .frame(width: 50)
                }
            }
            
            Section("Work days") {
                ForEach(settings.workDays, id: \.rawValue) { workDay in
                    HStack {
                        Text(workDay.displayValue)
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                settings.defaultWorkDays = settings.defaultWorkDays.replacingOccurrences(of: "\(workDay.rawValue),", with: "")
                            }
                        } label: {
                            Label("Remove", systemImage: "minus.circle.fill")
                                .foregroundColor(.red)
                                .labelStyle(.iconOnly)
                        }
                    }
                }
            }
            
            Section("Days off") {
                ForEach(settings.daysOff, id: \.rawValue) { workDay in
                    HStack {
                        Text(workDay.displayValue)
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                settings.defaultWorkDays += "\(workDay.rawValue),"
                            }
                        } label: {
                            Label("Add", systemImage: "plus.circle.fill")
                                .foregroundColor(.green)
                                .labelStyle(.iconOnly)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(Settings())
}
