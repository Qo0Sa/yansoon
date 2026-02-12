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

    @State private var selectedTask: TodoTask? = nil
    @State private var navigateToTimer = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()

            VStack(spacing: 0) {

                // Header + Progress + Tasks
                VStack(spacing: 16) {

                    // Header
                    HStack {
                        Text("Add Your To Do")
                            .font(AppFont.main(size: 24))
                            .foregroundColor(Color("PrimaryText"))

                        Spacer()

                        NavigationLink {
                            SettingsView()
                                .environmentObject(appState)
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(Color("PrimaryButtons"))
                                .font(.system(size: 25, weight: .semibold))
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 20)

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
                                    .fill(Color("BackgroundProgress"))

                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color("ProgressBar"))
                                    .frame(width: geometry.size.width * CGFloat(appState.progress))
                            }
                        }
                        .frame(height: 12)
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color("TaskBox"))
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
                                        TaskRow(task: task) {
                                            selectedTask = task
                                            navigateToTimer = true
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 25)
                        }
                    }
                    .frame(maxHeight: .infinity)

                    // Add Button (مرة وحدة فقط)
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

            
            
            
            // Navigation (مرة وحدة فقط + بدون تداخل)
            NavigationLink(isActive: $navigateToTimer) {
                if let task = selectedTask {
                    TaskTimerView(task: task)
                        .environmentObject(appState)
                } else {
                    EmptyView()
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
        // Notification Sheet
        .sheet(isPresented: $appState.showEnergySelectionPrompt) {
            EnergyCheckInSheet()
                .environmentObject(appState)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
          

         
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
                    .fill(Color("TaskBox"))
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(), value: task.isTimerRunning)
    }
}

// Add Task Sheet
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
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("TaskBox"))
                            )
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Estimated Time")
                            .font(AppFont.main(size: 16))
                            .foregroundColor(Color("SecondaryText"))

                        CircularSlidersheet(viewModel: timeLimitVM)
                            .frame(height: 320)
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
                    .disabled(
                        viewModel.newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        timeLimitVM.selectedMinutes < 5
                    )
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
            .onAppear {
                // لو تبين تربط slider بالمود الحالي (إذا عندك طريقة)
                // مثال: timeLimitVM.currentLevel = appState.currentMode   (لو نفس النوع)
                viewModel.newTaskHours = 0.0
                viewModel.newTaskMinutes = 5.0
            }
            .onChange(of: timeLimitVM.selectedMinutes) { newValue in
                viewModel.newTaskHours = Double(Int(newValue) / 60)
                viewModel.newTaskMinutes = Double(Int(newValue) % 60)
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

// MARK: - Circular Slider (00:00)
struct CircularSlidersheet: View {
    @ObservedObject var viewModel: TimeLimitViewModel

    private let sliderSize: CGFloat = 300

    private var progress: Double {
        let maxMinutes = viewModel.currentLevel.maxHours * 60
        guard maxMinutes > 0 else { return 0 }
        return viewModel.selectedMinutes / maxMinutes
    }

    private var hours: Int { Int(viewModel.selectedMinutes) / 60 }
    private var minutes: Int { Int(viewModel.selectedMinutes) % 60 }

    private func updateValue(with value: DragGesture.Value) {
        let vector = CGVector(dx: value.location.x - sliderSize/2, dy: value.location.y - sliderSize/2)
        let radians = atan2(vector.dy, vector.dx)
        var angle = Double(radians * 180 / .pi) + 90
        if angle < 0 { angle += 360 }

        let totalMinutes = (angle / 360) * (viewModel.currentLevel.maxHours * 60)
        let snapped = (totalMinutes / 5).rounded() * 5
        viewModel.selectedMinutes = min(viewModel.currentLevel.maxHours * 60, max(0, snapped))
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("PrimaryText").opacity(0.1), lineWidth: 10)
                .frame(width: sliderSize, height: sliderSize)

            Circle()
                .trim(from: 0, to: CGFloat(min(max(progress, 0), 1)))
                .stroke(
                    viewModel.isOverAverage ? Color("OffLimit") : Color("ProgressBar"),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .frame(width: sliderSize, height: sliderSize)
                .rotationEffect(.degrees(-90))

            // 00:00 display
            HStack(alignment: .firstTextBaseline, spacing: 4) {
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
        .frame(width: sliderSize, height: sliderSize)
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
