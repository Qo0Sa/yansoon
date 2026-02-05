//
//  EnergySelectionViewModel.swift
//  yansoon
//
//  Created by Rana Alngashy on 17/08/1447 AH.
//

import SwiftUI
import Foundation
import Combine
class EnergySelectionViewModel: ObservableObject {
    @Published var selectedLevel: EnergyLevel? = nil
    
    func select(_ level: EnergyLevel) {
        selectedLevel = level
    }
    
    func proceedToTasks() {
        if let level = selectedLevel {
            print("Moving to task input for: \(level)")
            // Trigger navigation here
        }
    }
}
