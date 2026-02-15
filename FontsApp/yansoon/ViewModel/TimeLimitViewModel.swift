
//
//  TimeLimitView.swift
//  yansoon
//
//  Created by Noor Alhassani on 16/08/1447 AH.
//

import SwiftUI
import Foundation
import Combine

@MainActor
final class TimeLimitViewModel: ObservableObject {
    @Published var currentLevel: EnergyLevel = .high
    @Published var selectedMinutes: Double = 0.0

    weak var appState: AppStateViewModel?

    var formattedTime: String {
        let hours = Int(selectedMinutes) / 60
        let mins = Int(selectedMinutes) % 60
        return String(format: "%02d:%02d", hours, mins)
    }

    var isOverAverage: Bool {
        // إذا averageHours عندك داخل EnergyLevel
        return (selectedMinutes / 60) > currentLevel.averageHours
    }

    // ✅ أهم إضافة: نهيئ السلايدر من إعدادات اليوزر
    func syncFromAppState() {
        // ✅ في شاشة الإعدادات نبي يبدأ صفر
        selectedMinutes = 0.0
    }

    func setLevelToUserMode() {
        guard let appState else { return }
        currentLevel = appState.currentMode
        selectedMinutes = 0.0   // ✅ يبدأ صفر
    }


    func setDefault() {
        // default على متوسط المستوى (إذا هذا اللي تبينه)
        selectedMinutes = currentLevel.averageHours * 60

        selectedMinutes = (selectedMinutes / 5).rounded() * 5
    }

    func nextLevel() {
        if let appState {
            let hours = selectedMinutes / 60.0
            appState.updateHours(hours, for: currentLevel)
        }

        if let next = EnergyLevel(rawValue: currentLevel.rawValue + 1) {
            currentLevel = next
            selectedMinutes = 0.0   // ✅ يبدأ صفر للمستوى اللي بعده
        } else {
            appState?.completeSetup()
        }
    }

    
    var formattedHoursMinutesText: String {
        let hours = Int(selectedMinutes) / 60
        let mins = Int(selectedMinutes) % 60
        return "\(hours)h \(mins)m"
    }

}
