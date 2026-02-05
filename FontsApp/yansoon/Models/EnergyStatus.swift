//
//  EnergyStatus.swift
//  yansoon
//
//  Created by Rana Alngashy on 17/08/1447 AH.
//

import SwiftUI

struct EnergyStatus: Identifiable {
    let id = UUID()
    let level: EnergyLevel // Reusing your existing EnergyLevel enum
    let description: LocalizedStringKey
    let image: String
}

let energyOptions = [
    EnergyStatus(level: .high, description: "Feeling great and ready to focus", image: "AniseHigh"),
    EnergyStatus(level: .medium, description: "Steady but not at full capacity", image: "AniseMedium"),
    EnergyStatus(level: .low, description: "Tired and needing gentleness", image: "AniseLow")
]
