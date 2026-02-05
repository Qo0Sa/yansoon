//
//  EnergyStatus.swift
//  yansoon
//
//  Created by Rana Alngashy on 17/08/1447 AH.
//
import SwiftUI

struct EnergyStatus: Identifiable {
    let id = UUID()
    let level: EnergyLevel
    let description: LocalizedStringKey
    let image: String
}

// Ensure your EnergyLevel enum matches these cases
let energyOptions = [
    EnergyStatus(level: .high, description: "Feeling great and ready to focus", image: "yansoonStatus/high"),
    EnergyStatus(level: .medium, description: "Steady but not at full capacity", image: "yansoonStatus/medium"),
    EnergyStatus(level: .low, description: "Tired and needing gentleness", image: "yansoonStatus/low")
]
