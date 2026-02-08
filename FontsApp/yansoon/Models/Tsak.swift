//
//  Tsak.swift
//  yansoon
//
//  Created by Sarah on 17/08/1447 AH.
//

import Foundation

struct TodoTask: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var estimatedMinutes: Double
    var actualMinutes: Double
    var isCompleted: Bool
    var createdAt: Date
    
    // Timer state (not saved)
    var isTimerRunning: Bool = false
    var timerStartTime: Date? = nil
    
    init(id: UUID = UUID(),
         title: String,
         estimatedMinutes: Double,
         actualMinutes: Double = 0.0,
         isCompleted: Bool = false,
         createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.estimatedMinutes = estimatedMinutes
        self.actualMinutes = actualMinutes
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
    
    var progress: Double {
        guard estimatedMinutes > 0 else { return 0 }
        return min(actualMinutes / estimatedMinutes, 1.0)
    }
    
    var remainingMinutes: Double {
        max(0, estimatedMinutes - actualMinutes)
    }
    
    var estimatedTimeFormatted: String {
        formatMinutes(estimatedMinutes)
    }
    
    var actualTimeFormatted: String {
        formatMinutes(actualMinutes)
    }
    
    var remainingTimeFormatted: String {
        formatMinutes(remainingMinutes)
    }
    
    private func formatMinutes(_ minutes: Double) -> String {
        let hours = Int(minutes) / 60
        let mins = Int(minutes) % 60
        if hours > 0 {
            return String(format: "%d:%02d hr", hours, mins)
        } else {
            return String(format: "%d min", mins)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, estimatedMinutes, actualMinutes, isCompleted, createdAt
    }
}
