
//  yansoonApp.swift
//  yansoon
//
import SwiftUI
import TipKit

@main
struct yansoonApp: App {
    @StateObject private var appState = AppStateViewModel()
    @State private var showSplash = true
    
    
    init() {
        try? Tips.configure()
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
