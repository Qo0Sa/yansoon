//
//  EnergySettings.swift
//  yansoon
//
//  Created by Sarah on 17/08/1447 AH.
//



import Foundation

struct EnergySettings: Codable, Equatable {
    var highEnergyHours: Double
    var mediumEnergyHours: Double
    var lowEnergyHours: Double
    
    /// Default values
    static let `default` = EnergySettings(
        highEnergyHours: 8.0,
        mediumEnergyHours: 6.0,
        lowEnergyHours: 4.0
    )
    
    /// Get hours for specific energy level
    func hours(for level: EnergyLevel) -> Double {
        switch level {
        case .high: return highEnergyHours
        case .medium: return mediumEnergyHours
        case .low: return lowEnergyHours
        }
    }
    
    /// Update hours for specific level
    mutating func setHours(_ hours: Double, for level: EnergyLevel) {
        switch level {
        case .high: highEnergyHours = hours
        case .medium: mediumEnergyHours = hours
        case .low: lowEnergyHours = hours
        }
    }
}
