//
//  EnergySelectionViewModel.swift
//  yansoon
//
//  Created by Rana Alngashy on 17/08/1447 AH.
//  Updated to work with AppStateViewModel
//

import SwiftUI
import Foundation
import Combine

class EnergySelectionViewModel: ObservableObject {
    @Published var selectedLevel: EnergyLevel?
    
    // Reference to shared app state
    weak var appState: AppStateViewModel?
    
    func select(_ level: EnergyLevel) {
        selectedLevel = level
    }
    
    func proceedToTasks() {
        guard let level = selectedLevel, let appState = appState else { return }
        
        // Update the current mode in AppState
        appState.switchMode(to: level)
        
        print("✅ Switched to \(level.title) mode")
    }
}
