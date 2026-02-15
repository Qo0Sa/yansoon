
//
//  TimeLimitView.swift
//  yansoon
//
//  Created by Noor Alhassani on 16/08/1447 AH.
//



import SwiftUI

enum EnergyLevel: Int, CaseIterable, Codable {
    case high = 0
    case medium = 1
    case low = 2

    var title: LocalizedStringKey {
        switch self {
        case .high: return "High Energy"
        case .medium: return "Medium Energy"
        case .low: return "Low Energy"
        }
    }

    var maxHours: Double { 12 }

    var averageHours: Double {
        switch self {
        case .high: return 8
        case .medium: return 6
        case .low: return 4
        }
    }
}
