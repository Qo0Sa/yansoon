//  yansoonApp.swift
//  yansoon
//
import SwiftUI
import TipKit
import UserNotifications

@main
struct yansoonApp: App {
    @StateObject private var appState = AppStateViewModel()
    @State private var showSplash = true
    
    
    init() {
        try? Tips.configure()
        // Clear any stale badge count on every launch
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
    
    
    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashView(durationSeconds: 2.0) {
                    withAnimation {
                        showSplash = false
                    }
                }
                .environmentObject(appState)
            } else {
                MainFlowView()
                    .environmentObject(appState)
            }
        }
    }
}
