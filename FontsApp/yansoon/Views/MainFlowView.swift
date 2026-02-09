//
//  MainFlowView.swift
//  yansoon
//
//  Created by Rana Alngashy on 17/08/1447 AH.
//  Pravo
//
import SwiftUI

struct MainFlowView: View {
    // Shared app state - single source of truth
    @StateObject private var appState = AppStateViewModel()
    
    // Local ViewModels
    @StateObject private var timeLimitVM = TimeLimitViewModel()
    @StateObject private var todoVM = ToDoViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                // If setup is not complete, show the setup wizard
                if !appState.isSetupComplete {
                    TimeLimitView(viewModel: timeLimitVM)
                        .environmentObject(appState)
                        .transition(.opacity)
                } else {
                    // If setup is complete, show the ToDo dashboard directly
                    ToDoView(viewModel: todoVM)
                        .environmentObject(appState)
                        .transition(.opacity)
                }
            }
            .animation(.spring(), value: appState.isSetupComplete)
        }
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
