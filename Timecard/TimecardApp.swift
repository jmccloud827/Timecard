//
//  TimecardApp.swift
//  Timecard
//
//  Created by Jacob McCloud on 5/26/23.
//

import SwiftUI

@main
struct TimecardApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appDelegate.viewModel)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var viewModel = ViewModel()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if let viewModel = try? JSONDecoder().decode(ViewModel.self, from: Data(viewModel.storage.utf8)) {
            self.viewModel = viewModel
        }
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        viewModel.saveData()
    }
}
