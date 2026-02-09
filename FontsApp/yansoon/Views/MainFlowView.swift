//
//  MainFlowView.swift
//  yansoon
//
//  Created by Rana Alngashy on 17/08/1447 AH.

import SwiftUI

struct MainFlowView: View {
    // 1. CHANGED: Now it receives the object, it doesn't create it.
    @EnvironmentObject var appState: AppStateViewModel
    
    // Local ViewModels
    @StateObject private var timeLimitVM = TimeLimitViewModel()
    @StateObject private var todoVM = ToDoViewModel()

    var body: some View {
        ZStack {
            if !appState.isSetupComplete {
                NavigationStack {
                    TimeLimitView(viewModel: timeLimitVM)
                        .environmentObject(appState)
                }
                .transition(.opacity)
            } else {
                NavigationStack {
                    ToDoView(viewModel: todoVM)
                        .environmentObject(appState)
                }
                .transition(.opacity)
            }
        }
        .animation(.spring(), value: appState.isSetupComplete)
        .onAppear {
            setupViewModels()
            requestNotificationPermissions()
        }
    }
    
    private func setupViewModels() {
        timeLimitVM.appState = appState
        todoVM.appState = appState
    }
    
    private func requestNotificationPermissions() {
        Task {
            let _ = await appState.requestNotificationPermission()
        }
    }
}
