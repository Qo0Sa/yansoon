//
//  MainFlowView.swift
//  yansoon
//
//  Created by Rana Alngashy on 17/08/1447 AH.
//  Updated with complete flow
//

import SwiftUI

struct MainFlowView: View {
    // Shared app state - single source of truth
    @StateObject private var appState = AppStateViewModel()
    
    // Local ViewModels
    @StateObject private var timeLimitVM = TimeLimitViewModel()
    @StateObject private var energySelectionVM = EnergySelectionViewModel()
    
    @State private var showToDoView = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if !appState.isSetupComplete {
                    // STEP 1: Time Limit Setup
                    TimeLimitView(viewModel: timeLimitVM)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                } else if !showToDoView {
                    // STEP 2: Energy Selection
                    EnergySelectionView()
                        .environmentObject(appState)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                } else {
                    // STEP 3: To Do View
                    ToDoView()
                        .environmentObject(appState)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                }
            }
            .animation(.spring(), value: appState.isSetupComplete)
            .animation(.spring(), value: showToDoView)
        }
        .onAppear {
            setupViewModels()
        }
        .onChange(of: appState.isSetupComplete) { _, isComplete in
            if isComplete {
                // When setup is complete, show energy selection
                showToDoView = false
            }
        }
    }
    
    private func setupViewModels() {
        // Link ViewModels to AppState
        timeLimitVM.appState = appState
        energySelectionVM.appState = appState
    }
}
