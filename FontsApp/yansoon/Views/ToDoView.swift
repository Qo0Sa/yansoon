

//
//  ToDoView.swift
//  yansoon
//
//  Created by Sarah
//

import SwiftUI

struct ToDoView: View {
    @EnvironmentObject var appState: AppStateViewModel
    @ObservedObject var viewModel: ToDoViewModel
//   @StateObject private var viewModel = ToDoViewModel()
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
                                .fill(.backgroundProgress)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("ProgressBar"))
                                .frame(width: geometry.size.width * CGFloat(appState.progress))
                        }
                    }
                    .frame(height: 12)
                }
                .padding(14) // مسافة داخلية للكرت
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.taskBox)
                )
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
            
            // NavigationLink للتايمر
            NavigationLink(isActive: $navigateToTimer) {
                Group {
                    if let task = selectedTask {
                        TaskTimerView(task: task)
                            .environmentObject(appState)
                    } else {
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
                    .fill(.taskBox)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(), value: task.isTimerRunning)
    }
}



//شايف التايمر الي بالبروقرسس ابيه 00:00 يكون وعلى حسب المود نفس الي قبل و
struct AddTaskSheet: View {
    @ObservedObject var viewModel: ToDoViewModel
    @Environment(\.dismiss) var dismiss
    @StateObject private var timeLimitVM = TimeLimitViewModel()

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
                            .background(RoundedRectangle(cornerRadius: 12).fill(.taskBox))
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Estimated Time")
                            .font(AppFont.main(size: 16))
                            .foregroundColor(Color("SecondaryText"))

                        CircularSlidersheet(viewModel: timeLimitVM)
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
                              timeLimitVM.selectedMinutes < 5)
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
            .onChange(of: timeLimitVM.selectedMinutes) { newValue in
                // ربط السلايدر مع الـ ViewModel
                viewModel.newTaskHours = Double(Int(newValue) / 60)
                viewModel.newTaskMinutes = Double(Int(newValue) % 60)
            }
            .onAppear {
                // تعيين القيمة الابتدائية (5 دقائق)
                viewModel.newTaskHours = 0.0
                viewModel.newTaskMinutes = 5.0
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

// MARK: - Energy Check-In Sheet
    struct EnergyCheckInSheet: View {
        @EnvironmentObject var appState: AppStateViewModel
        @StateObject private var selectionVM = EnergySelectionViewModel()
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            NavigationView {
                ZStack {
                    Color("Background").ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        VStack(spacing: 12) {
                            Text("Time to Check In!")
                                .font(AppFont.main(size: 24))
                            Text("How are you feeling right now?")
                                .font(AppFont.main(size: 16))
                                .opacity(0.7)
                        }
                        .foregroundColor(Color("PrimaryText"))
                        .padding(.top, 30)
                        
                        Spacer()
                        
                        VStack(spacing: 35) {
                            EnergyButton(level: .high,
                                         sub: "Feeling great and ready to focus",
                                         img: "yansoonStatus/high",
                                         selected: $selectionVM.selectedLevel)
                            
                            EnergyButton(level: .medium,
                                         sub: "Steady but not at full capacity",
                                         img: "yansoonStatus/medium",
                                         selected: $selectionVM.selectedLevel)
                            
                            EnergyButton(level: .low,
                                         sub: "Tired and needing gentleness",
                                         img: "yansoonStatus/low",
                                         selected: $selectionVM.selectedLevel)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            guard let selected = selectionVM.selectedLevel else { return }
                            appState.switchMode(to: selected)
                            appState.dismissEnergyPrompt()
                            dismiss()
                        }) {
                            Text("Continue")
                                .font(AppFont.main(size: 20))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(selectionVM.selectedLevel != nil ? Color("PrimaryButtons") : Color.gray.opacity(0.3))
                                )
                        }
                        .disabled(selectionVM.selectedLevel == nil)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 40)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Later") {
                            appState.dismissEnergyPrompt()
                            dismiss()
                        }
                        .foregroundColor(Color("PrimaryButtons"))
                    }
                }
            }
            .onAppear {
                selectionVM.appState = appState
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



struct CircularSlidersheet: View {
    @ObservedObject var viewModel: TimeLimitViewModel
    
    private let sliderSize: CGFloat = 300
    
    private var progress: Double {
        viewModel.selectedMinutes / (viewModel.currentLevel.maxHours * 60)
    }
    
    private var hours: Int {
        Int(viewModel.selectedMinutes) / 60
    }
    
    private var minutes: Int {
        Int(viewModel.selectedMinutes) % 60
    }
    
    private func updateValue(with value: DragGesture.Value) {
        let vector = CGVector(dx: value.location.x, dy: value.location.y)
        let radians = atan2(vector.dy, vector.dx)
        var angle = Double(radians * 180 / .pi) + 90
        
        if angle < 0 { angle += 360 }
        
        let totalMinutes = (angle / 360) * (viewModel.currentLevel.maxHours * 60)
        let snapped = (totalMinutes / 5).rounded() * 5
        // الحد الأدنى 5 دقائق
        viewModel.selectedMinutes = min(viewModel.currentLevel.maxHours * 60, max(5, snapped))
    }

    
    var body: some View {
        ZStack {
            // Background Track
            Circle()
                .stroke((Color("PrimaryText")).opacity(0.1), lineWidth: 10)
                .frame(width: sliderSize, height: sliderSize)
            
            // Progress Bar
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(viewModel.isOverAverage ? Color("OffLimit") : Color("ProgressBar"),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .frame(width: sliderSize, height: sliderSize)
                .rotationEffect(.degrees(-90))
            
            // عرض الوقت في وسط الدائرة بتنسيق 00:00
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(String(format: "%02d", hours))
                    .font(AppFont.main(size: 60))
                    .foregroundColor(Color("PrimaryText"))
                
                Text(":")
                    .font(AppFont.main(size: 60))
                    .foregroundColor(Color("SecondaryText"))
                
                Text(String(format: "%02d", minutes))
                    .font(AppFont.main(size: 60))
                    .foregroundColor(Color("PrimaryText"))
            }
            
            // Knob - Locked to the bar
            Circle()
                .fill(viewModel.isOverAverage ? Color("OffLimit") : Color("ProgressBar"))
                .frame(width: 24, height: 24)
                .offset(y: -sliderSize / 2)
                .rotationEffect(.degrees(progress * 360))
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            updateValue(with: value)
                        }
                )
        }
    }
    
}















#Preview("To Do View") {
    ToDoView(viewModel: ToDoViewModel())
        .environmentObject({
            let appState = AppStateViewModel()
            appState.energySettings = EnergySettings(
                highEnergyHours: 4.5,
                mediumEnergyHours: 3.0,
                lowEnergyHours: 1.5
            )
            appState.currentMode = .high
            return appState
        }())
}
