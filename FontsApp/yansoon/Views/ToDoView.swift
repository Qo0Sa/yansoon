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
    @State private var selectedTask: TodoTask? = nil
    @Environment(\.dismiss) private var dismiss
    @State private var showSettings = false
    @State private var navigateToTimer = false
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        Text("Add Your To Do")
                            .font(AppFont.main(size: 24))
                            .foregroundColor(Color("PrimaryText"))
                        Spacer()
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 20)
                }
                
                // Progress
                VStack(spacing: 12) {
                    HStack {
                        Image(energyImage(for: appState.currentMode))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                        
                        Text("Total Hours")
                            .font(AppFont.main(size: 16))
                            .foregroundColor(Color("PrimaryText"))
                        
                        Spacer()
                        
                        Text(appState.progressText)
                            .font(AppFont.main(size: 16))
                            .foregroundColor(Color("PrimaryButtons"))
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.1))
                            
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
                
                // Tasks
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tasks")
                        .font(AppFont.main(size: 18))
                        .foregroundColor(Color("PrimaryText"))
                        .padding(.horizontal, 25)
                    
                    ScrollView {
                        VStack(spacing: 12) {
                            if appState.tasks.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "checklist")
                                        .font(.system(size: 50))
                                        .foregroundColor(Color("PrimaryText").opacity(0.3))
                                    
                                    Text("No tasks yet")
                                        .font(AppFont.main(size: 16))
                                        .foregroundColor(Color("SecondaryText"))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 60)
                            } else {
                                ForEach(appState.tasks) { task in
                                    TaskRow(task: task, onTap: {
                                        selectedTask = task
                                        navigateToTimer = true
                                    })
                                }
                            }
                        }
                        .padding(.horizontal, 25)
                    }
                }
                .frame(maxHeight: .infinity)
                
                // Add
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
            
            // NavigationLink ثابت الوجهة: دائماً يرجّع View
            NavigationLink(isActive: $navigateToTimer) {
                Group {
                    if let task = selectedTask {
                        TaskTimerView(task: task)
                            .environmentObject(appState)
                    } else {
                        // لو ما فيه تاسك مختار، نرجّع View فاضي لتفادي أخطاء الـ ViewBuilder
                        EmptyView()
                    }
                }
            } label: {
                EmptyView()
            }
            .hidden()
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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.backward")
                        Text("Back")
                    }
                    .foregroundColor(Color("PrimaryButtons"))
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    SettingsView()
                        .environmentObject(appState)
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(Color("PrimaryButtons"))
                }
            }
        }
    }
}

struct TaskRow: View {
    let task: TodoTask
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                if task.isTimerRunning {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color("PrimaryButtons"))
                        .frame(width: 20, height: 20)
                        .transition(.scale)
                } else {
                    Circle()
                        .fill(Color("PrimaryButtons"))
                        .frame(width: 8, height: 8)
                        .transition(.scale)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(AppFont.main(size: 16))
                        .foregroundColor(Color("PrimaryText"))
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.05))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(), value: task.isTimerRunning)
    }
}

struct AddTaskSheet: View {
    @ObservedObject var viewModel: ToDoViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").ignoresSafeArea()
                VStack(spacing: 25) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Task Name")
                            .font(AppFont.main(size: 16))
                            .foregroundColor(Color("SecondaryText"))
                        TextField("Enter task name", text: $viewModel.newTaskTitle)
                            .font(AppFont.main(size: 18))
                            .foregroundColor(Color("PrimaryText"))
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Estimated Time")
                            .font(AppFont.main(size: 16))
                            .foregroundColor(Color("SecondaryText"))
                        HStack(spacing: 20) {
                            VStack {
                                Text("Hours")
                                    .font(AppFont.main(size: 14))
                                    .foregroundColor(Color("SecondaryText"))
                                Picker("Hours", selection: $viewModel.newTaskHours) {
                                    ForEach(0..<13) { hour in
                                        Text("\(hour)").tag(Double(hour))
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(height: 150)
                            }
                            VStack {
                                Text("Minutes")
                                    .font(AppFont.main(size: 14))
                                    .foregroundColor(Color("SecondaryText"))
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
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color("PrimaryButtons"))
                }
            }
        }
    }
}

struct ModeSelectionSheet: View {
    @ObservedObject var viewModel: ToDoViewModel
    let currentMode: EnergyLevel
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack { Color("Background").ignoresSafeArea() }
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
                TodoTask(title: "Review project documentation",
                         estimatedMinutes: 60,
                         actualMinutes: 30),
                TodoTask(title: "Respond to emails",
                         estimatedMinutes: 30,
                         actualMinutes: 30,
                         isCompleted: true),
                TodoTask(title: "Update task board",
                         estimatedMinutes: 45,
                         actualMinutes: 0)
            ]
            return appState
        }())
}
