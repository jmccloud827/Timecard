import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @State var viewModel: ViewModel
    
    @State private var showSheet = false
    @State private var lastPunchTime = Date.now
    @State private var weekToDate = 40.0
    @State private var addBreak = false
    @State private var breakTime = 0
    
    init(storage: String) {
        if let viewModel = try? JSONDecoder().decode(ViewModel.self, from: Data(storage.utf8)) {
            _viewModel = .init(wrappedValue: viewModel)
        } else {
            _viewModel = .init(wrappedValue: .init())
        }
    }
    
    var body: some View {
        TabView(selection: $viewModel.tabSelection) {
            VStack(spacing: 0) {
                NavigationView {
                    Form {
                        ForEach($viewModel.workDays) { day in
                            DayView(day: day.wrappedValue.name, inDate: day.timeIn, outDate: day.timeOut, breakDate: day.breakTime)
                        }
                        
                        HStack {
                            Text("Total Hours:")
                            Spacer()
                            Text(viewModel.getTotal().toString())
                        }
                    }
                    .navigationTitle("Timecard")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                showSheet = true
                                viewModel.saveData()
                            } label: {
                                Label("Settings", systemImage: "gearshape.fill")
                            }
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Clear") {
                                viewModel.clear()
                            }
                        }
                    }
                    .sheet(isPresented: $showSheet) {
                        SheetView(viewModel: $viewModel)
                    }
                }
                if !viewModel.disableAds {
                    BannerView()
                }
            }
            .tabItem { Label("Timecard", systemImage: "list.bullet.rectangle.portrait") }
            .tag(1)
            
            VStack(spacing: 0) {
                NavigationView {
                    Form {
                        DoubleTextView("Week to Date Hours", double: $weekToDate)
                        DatePicker("Last Punch Time", selection: $lastPunchTime, displayedComponents: .hourAndMinute)
                        Toggle("Add Break?", isOn: $addBreak)
                        if addBreak {
                            MinutePicker("Break", breakTime: $breakTime)
                        }
                        DatePicker("You will hit \(viewModel.totalHours.toString()) hours at:", selection: Binding.constant(getTimeOut()), displayedComponents: .hourAndMinute).disabled(true)
                    }
                    .navigationTitle("Timecard")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                showSheet = true
                            } label: {
                                Label("Settings", systemImage: "gearshape.fill")
                            }
                        }
                    }
                    .sheet(isPresented: $showSheet) {
                        SheetView(viewModel: $viewModel)
                    }
                }
                if !viewModel.disableAds {
                    BannerView()
                }
            }
            .tabItem { Label("Calculator", systemImage: "minus.slash.plus") }
            .tag(2)
        }
        .navigationViewStyle(.stack)
        .scrollDismissesKeyboard()
        .onChange(of: scenePhase) { value in
            if value != .active {
                viewModel.saveData()
            }
        }
        .onAppear {
            weekToDate = viewModel.totalHours
            breakTime = viewModel.defaultBreak
            addBreak = viewModel.defaultBreak != 0
        }
    }
    
    func getTimeOut() -> Date {
        lastPunchTime.addingTimeInterval(((viewModel.totalHours - weekToDate) * 60 * 60) + Double(addBreak ? (breakTime * 60) : 0))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(storage: "")
    }
}
