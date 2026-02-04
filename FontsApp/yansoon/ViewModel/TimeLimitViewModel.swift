
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
    @Published var selectedMinutes: Double = 300
    
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
    
    func nextLevel() {
        if let next = EnergyLevel(rawValue: currentLevel.rawValue + 1) {
            currentLevel = next
            selectedMinutes = 60
        }
    }
}
