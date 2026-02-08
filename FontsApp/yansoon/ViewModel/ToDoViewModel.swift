//
//  ToDoViewModel.swift
//  yansoon
//
//  Created by Sarah on 17/08/1447 AH.
//

import SwiftUI
import Foundation
import Combine

class ToDoViewModel: ObservableObject {
    
    weak var appState: AppStateViewModel?
    
    @Published var showAddTaskSheet = false
    @Published var newTaskTitle = ""
    @Published var newTaskHours: Double = 1.0
    @Published var newTaskMinutes: Double = 0.0
    
    @Published var showModeSelectionSheet = false
    
    var totalEstimatedMinutes: Double {
        appState?.tasks.reduce(0) { $0 + $1.estimatedMinutes } ?? 0
    }
    
    var totalEstimatedHours: Double {
        totalEstimatedMinutes / 60.0
    }
    
    func addTask() {
        guard !newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let totalMinutes = (newTaskHours * 60) + newTaskMinutes
        guard totalMinutes > 0 else { return }
        
        let task = TodoTask(
            title: newTaskTitle,
            estimatedMinutes: totalMinutes
        )
        appState?.addTask(task)
        resetForm()
    }
    
    func resetForm() {
        newTaskTitle = ""
        newTaskHours = 1.0
        newTaskMinutes = 0.0
        showAddTaskSheet = false
    }
    
    func deleteTask(at offsets: IndexSet) {
        appState?.deleteTask(at: offsets)
    }
    
    func toggleTask(_ taskId: UUID) {
        appState?.toggleTaskCompletion(taskId)
    }
    
    func switchMode(to mode: EnergyLevel) {
        appState?.switchMode(to: mode)
        showModeSelectionSheet = false
    }
}
