
//  yansoonApp.swift
//  yansoon
//

import SwiftUI

@main
struct yansoonApp: App {
    // 1. Initialize the NotificationManager
    private let notificationManager = NotificationManager.shared
    
    // 2. Create AppState HERE (Lifted State)
    // This ensures it exists before any view loads
    @StateObject private var appState = AppStateViewModel()
    
    var body: some Scene {
        WindowGroup {
            SplashView()
                // 3. Pass it down to the Splash Screen
                .environmentObject(appState)
        }
    }
}
