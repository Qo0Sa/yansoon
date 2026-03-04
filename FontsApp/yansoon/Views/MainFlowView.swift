//
//  MainFlowView.swift
//  yansoon
//
//  Created by Rana Alngashy on 17/08/1447 AH.
//

import SwiftUI

struct MainFlowView: View {
    
    // App State
    @EnvironmentObject var appState: AppStateViewModel
    
    // Local ViewModels
    @StateObject private var timeLimitVM = TimeLimitViewModel()
    @StateObject private var todoVM = ToDoViewModel()
    
    // Onboarding state
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        
        ZStack {
            
            // 1️⃣ Onboarding (first launch only)
            if !hasSeenOnboarding {
                
                OnboardingView()
                
            }
            
            // 2️⃣ Setup Flow (energy selection)
            else if !appState.isSetupComplete {
                
                NavigationStack {
                    EnergySelectionView()
                        .environmentObject(appState)
                }
                .transition(.opacity)
                
            }
            
            // 3️⃣ Main App
            else {
                
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

            print("isSetupComplete:", appState.isSetupComplete)
            print("currentMode:", String(describing: appState.currentMode))
        }
    }
    
    private func setupViewModels() {
        timeLimitVM.appState = appState
        todoVM.appState = appState
    }
}
