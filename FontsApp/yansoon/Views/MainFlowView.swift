//
//  MainFlowView.swift
//  yansoon
//
//  Created by Rana Alngashy on 17/08/1447 AH.
//
import SwiftUI

struct MainFlowView: View {
    // This is the single source of truth for the setup process
    @StateObject private var setupViewModel = TimeLimitViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                if setupViewModel.isSetupComplete {
                    EnergySelectionView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                } else {
                    // This will now work without errors
                    TimeLimitView(viewModel: setupViewModel)
                }
            }
            .animation(.spring(), value: setupViewModel.isSetupComplete)
        }
    }
}
