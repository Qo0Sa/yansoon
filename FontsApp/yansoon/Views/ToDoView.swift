//
//  ToDoView.swift
//  yansoon
//
//  Created by Sarah
//

import SwiftUI

struct ToDoView: View {
    @EnvironmentObject var appState: AppStateViewModel
    @StateObject private var viewModel = ToDoViewModel()
    @State private var selectedTask: Task? = nil
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Header with Mode Selector
                VStack(spacing: 16) {
                    // Title
                    HStack {
                        Text("Add Your To Do")
                            .font(AppFont.main(size: 24))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                       
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 20)
                    
             
                }
                
                // MARK: - Progress Section
                VStack(spacing: 12) {
                    HStack {
                        //بعدل هذي على حسب الليفل الي مختاره تتغير
                        Image(energyImage(for: appState.currentMode))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                        
                        Text("Total Hours")
                            .font(AppFont.main(size: 16))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(appState.progressText)
                            .font(AppFont.main(size: 16))
                            .foregroundColor(Color("PrimaryButtons"))
                    }
                    
                    // Progress Bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.1))
                            
                            // Progress Fill
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("ProgressBar"))
                                .frame(width: geometry.size.width * CGFloat(appState.progress))
                        }
                    }
                    .frame(height: 12)
                }
                .padding(.horizontal, 25)
                .padding(.top, 20)
                .padding(.bottom, 15)
                
                // MARK: - Tasks Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tasks")
                        .font(AppFont.main(size: 18))
                        .foregroundColor(.white)
                        .padding(.horizontal, 25)
                    
                    ScrollView {
                        VStack(spacing: 12) {
                            if appState.tasks.isEmpty {
                                // Empty State
                                VStack(spacing: 12) {
                                    Image(systemName: "checklist")
                                        .font(.system(size: 50))
                                        .foregroundColor(.white.opacity(0.3))
                                    
                                    Text("No tasks yet")
                                        .font(AppFont.main(size: 16))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 60)
                            } else {
                                ForEach(appState.tasks) { task in
                                    TaskRow(task: task, onTap: {
                                        selectedTask = task
                                    })
                                }
                            }
                        }
                        .padding(.horizontal, 25)
                    }
                }
                .frame(maxHeight: .infinity)
                
                // MARK: - Add Button
                Button(action: { viewModel.showAddTaskSheet = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color("PrimaryButtons"))
                        .cornerRadius(15)
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            viewModel.appState = appState
        }
        .sheet(isPresented: $viewModel.showAddTaskSheet) {
            AddTaskSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showModeSelectionSheet) {
            ModeSelectionSheet(viewModel: viewModel, currentMode: appState.currentMode)
        }
//        .sheet(item: $selectedTask) { task in
//            TaskTimerView(task: task)
//                .environmentObject(appState)
//        }
        .navigationBarBackButtonHidden(true)

    }
    

}



// MARK: - Task Row Component
struct TaskRow: View {
    let task: Task
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                
                // LEFT: Circle أو Checkmark حسب التايمر
                if task.isTimerRunning {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color("PrimaryButtons"))
                        .frame(width: 20, height: 20)
                        .transition(.scale) // حركة عند التحول
                } else {
                    Circle()
                        .fill(Color("PrimaryButtons"))
                        .frame(width: 8, height: 8)
                        .transition(.scale)
                }
                
                // معلومات المهمة
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(AppFont.main(size: 16))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                   
                }
                
                Spacer() // لدفع المحتوى لليسار
                
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.05))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(), value: task.isTimerRunning) // تحديث تلقائي عند تغير التايمر
    }
}






// MARK: - Add Task Sheet
struct AddTaskSheet: View {
    @ObservedObject var viewModel: ToDoViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    // Task Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Task Name")
                            .font(AppFont.main(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                        
                        TextField("Enter task name", text: $viewModel.newTaskTitle)
                            .font(AppFont.main(size: 18))
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.05))
                            )
                    }
                    
                    // Estimated Time
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Estimated Time")
                            .font(AppFont.main(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                        
                        HStack(spacing: 20) {
                            // Hours Picker
                            VStack {
                                Text("Hours")
                                    .font(AppFont.main(size: 14))
                                    .foregroundColor(.white.opacity(0.5))
                                
                                Picker("Hours", selection: $viewModel.newTaskHours) {
                                    ForEach(0..<13) { hour in
                                        Text("\(hour)").tag(Double(hour))
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(height: 150)
                            }
                            
                            // Minutes Picker
                            VStack {
                                Text("Minutes")
                                    .font(AppFont.main(size: 14))
                                    .foregroundColor(.white.opacity(0.5))
                                
                                Picker("Minutes", selection: $viewModel.newTaskMinutes) {
                                    ForEach([0.0, 15.0, 30.0, 45.0], id: \.self) { min in
                                        Text("\(Int(min))").tag(min)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(height: 150)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Add Button
                    Button(action: {
                        viewModel.addTask()
                        dismiss()
                    }) {
                        Text("Add Task")
                            .font(AppFont.main(size: 18))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color("PrimaryButtons"))
                            .cornerRadius(12)
                    }
                    .disabled(viewModel.newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty ||
                             (viewModel.newTaskHours == 0 && viewModel.newTaskMinutes == 0))
                }
                .padding(25)
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color("PrimaryButtons"))
                }
            }
        }
    }
}


// MARK: - Mode Selection Sheet
struct ModeSelectionSheet: View {
    @ObservedObject var viewModel: ToDoViewModel
    let currentMode: EnergyLevel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
        }
    }
    
}
    
    
    private func energyImage(for level: EnergyLevel) -> String {
        switch level {
        case .high: return "yansoonStatus/high"
        case .medium: return "yansoonStatus/medium"
        case .low: return "yansoonStatus/low"
        }
    }







#Preview("To Do View") {
    ToDoView()
        .environmentObject({
            let appState = AppStateViewModel()
            appState.energySettings = EnergySettings(
                highEnergyHours: 4.5,
                mediumEnergyHours: 3.0,
                lowEnergyHours: 1.5
            )
            appState.currentMode = .high
            appState.tasks = [
                Task(title: "Review project documentation",
                     estimatedMinutes: 60,
                     actualMinutes: 30),
                Task(title: "Respond to emails",
                     estimatedMinutes: 30,
                     actualMinutes: 30,
                     isCompleted: true),
                Task(title: "Update task board",
                     estimatedMinutes: 45,
                     actualMinutes: 0)
            ]
            return appState
        }())
}
