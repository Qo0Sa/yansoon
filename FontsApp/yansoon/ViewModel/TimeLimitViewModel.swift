
//
//  TimeLimitView.swift
//  yansoon
//
//  Created by Noor Alhassani on 16/08/1447 AH.
//

import SwiftUI
import Foundation
import Combine

class TimeLimitViewModel: ObservableObject {
    @Published var currentLevel: EnergyLevel = .high
    @Published var selectedMinutes: Double = 0.0
    
    // Reference to shared app state
    weak var appState: AppStateViewModel?
    
    var formattedTime: String {
        let hours = Int(selectedMinutes) / 60
        let mins = Int(selectedMinutes) % 60
        return String(format: "%02d:%02d", hours, mins)
    }
    
    var isOverAverage: Bool {
        return (selectedMinutes / 60) > currentLevel.averageHours
    }
    
    func setDefault() {
        selectedMinutes = currentLevel.averageHours * 60
    }
    // Add this inside TimeLimitViewModel class
    func previousLevel() {
        if let previous = EnergyLevel(rawValue: currentLevel.rawValue - 1) {
            currentLevel = previous
            // Optionally reload the hours previously set in appState
            if let appState = appState {
                selectedMinutes = appState.energySettings.hours(for: previous) * 60
            }
        }
    }
    func nextLevel() {
        // Save current level hours to AppState
        if let appState = appState {
            let hours = selectedMinutes / 60.0
            appState.updateHours(hours, for: currentLevel)
        }
        
        // Move to next level or finish setup
        if let next = EnergyLevel(rawValue: currentLevel.rawValue + 1) {
            currentLevel = next
            selectedMinutes = 0.0
        } else {
            // After Low Energy, the setup is finished
            appState?.completeSetup()
        }
    }
}
