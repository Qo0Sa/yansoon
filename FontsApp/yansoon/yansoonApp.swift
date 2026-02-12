
//  yansoonApp.swift
//  yansoon
//

import SwiftUI

@main
struct yansoonApp: App {
    @StateObject private var appState = AppStateViewModel()
    @State private var showSplash = true

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
