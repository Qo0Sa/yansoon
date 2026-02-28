//
//  ToDoView.swift
//  yansoon
//

import SwiftUI

struct ToDoView: View {
    @EnvironmentObject var appState: AppStateViewModel
    @ObservedObject var viewModel: ToDoViewModel

    @State private var selectedTask: TodoTask? = nil
    @State private var navigateToTimer = false
    
    @State private var editingTask: TodoTask? = nil
    @State private var showEditTaskSheet = false
    @State private var showBurnoutAlert = false
    
    @Environment(\.dismiss) private var dismiss
    @State private var showSettingsTip = true
    @State private var gearFrame: CGRect = .zero  // ← لحفظ موقع الـ gear icon
    
    private var isShowingAchievement: Bool {
        !appState.tasks.isEmpty && appState.tasks.allSatisfy({ $0.isCompleted })
    }

    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()

            VStack(spacing: 0) {
                // Header + Progress Section
                VStack(spacing: 16) {
                    HStack {
                        Text("Add Your To Do")
                            .font(AppFont.main(size: 24))
                            .foregroundColor(Color("PrimaryText"))

                        Spacer()

                        NavigationLink {
                            SettingsView().environmentObject(appState)
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(Color("PrimaryButtons"))
                                .font(.system(size: 25, weight: .semibold))
                                .background(
                                    GeometryReader { geo in
                                        Color.clear.onAppear {
                                            gearFrame = geo.frame(in: .global)
                                        }
                                    }
                                )
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 20)

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
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color("TaskBox")))
                    .padding(.horizontal, 25)
                    .padding(.top, 20)
                    .padding(.bottom, 15)

                    // Tasks List
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tasks")
                            .font(AppFont.main(size: 18))
                            .foregroundColor(Color("PrimaryText"))
                            .padding(.horizontal, 25)

                        List {
                            if appState.tasks.isEmpty {
                                emptyStateView
                            } else if isShowingAchievement {
                                achievementView
                            } else {
                                ForEach(appState.tasks) { task in
                                    TaskRow(task: task) {
                                        if appState.progress >= 1.0 && !task.isCompleted {
                                            showBurnoutAlert = true
                                        } else {
                                            selectedTask = task
                                            navigateToTimer = true
                                        }
                                    }
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 6, leading: 25, bottom: 6, trailing: 25))
                                    .opacity(appState.progress >= 1.0 && !task.isCompleted ? 0.5 : 1.0)
                                    .grayscale(appState.progress >= 1.0 && !task.isCompleted ? 1.0 : 0.0)
                                    .swipeActions(edge: .leading) {
                                        Button {
                                            editingTask = task
                                            showEditTaskSheet = true
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        .tint(.green)
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            if let index = appState.tasks.firstIndex(where: { $0.id == task.id }) {
                                                viewModel.deleteTask(at: IndexSet(integer: index))
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                    .frame(maxHeight: .infinity)

                    // Add Button
                    if !isShowingAchievement {
                        Button(action: {
                            viewModel.showAddTaskSheet = true
                        }) {
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
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }

            // ← Spotlight overlay - كل شي يغبش إلا الـ gear icon
            if showSettingsTip {
                Color.black.opacity(0.55)
                    .ignoresSafeArea()
                    .mask(
                        Rectangle()
                            .overlay(
                                Circle()
                                    .frame(width: 70, height: 70)
                                    .position(x: gearFrame.midX, y: gearFrame.midY)
                                    .blendMode(.destinationOut)
                            )
                            .compositingGroup()
                    )
                    .ignoresSafeArea()
                    .zIndex(998)
                    .allowsHitTesting(false)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: showSettingsTip)
            }

            // ← Tip فوق كل شي
            if showSettingsTip {
                VStack {
                    HStack {
                        Spacer()
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(.yellow)
                                Text("Tip")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(Color("SecondaryText"))
                            }
                            Text("Adjust your energy limits and preferences here.")
                                .font(AppFont.main(size: 15))
                                .foregroundColor(Color("PrimaryText"))
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(3)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .frame(width: 180, alignment: .leading)
                        .background {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        }
                        .padding(.trailing, 20)
                    }
                    .padding(.top, 70)
                    Spacer()
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .topTrailing)))
                .animation(.spring(response: 0.9, dampingFraction: 0.7), value: showSettingsTip)
                .zIndex(999)
                .allowsHitTesting(false)
            }

            // Invisible NavigationLink
            NavigationLink(isActive: $navigateToTimer) {
                if let task = selectedTask {
                    TaskTimerView(task: task).environmentObject(appState)
                } else {
                    EmptyView()
                }
            } label: { EmptyView() }.hidden()
        }
        .alert("Are you done working?", isPresented: $appState.showPostTaskPopUp) {
            Button("Yes") { appState.showEnergySelectionPrompt = true }
            Button("No", role: .cancel) { }
        } message: {
            Text("To help track your burnout, please check in on your energy levels.")
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            appState.handleReturnToApp()
        }
        .onAppear { viewModel.appState = appState }
        .sheet(isPresented: $viewModel.showAddTaskSheet) {
            AddTaskSheet(viewModel: viewModel)
        }
        .sheet(item: $editingTask) { task in
            EditTaskSheet(task: task).environmentObject(appState)
        }
        .sheet(isPresented: $appState.showEnergySelectionPrompt) {
            EnergyCheckInSheet().environmentObject(appState)
        }
        .alert("Energy Limit Reached", isPresented: $showBurnoutAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your energy cannot handle more tasks, you will burn out.")
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.appState = appState

            if !StorageManager.shared.didShowSettingsTip() {
                showSettingsTip = true
                StorageManager.shared.setDidShowSettingsTip()

                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation { showSettingsTip = false }
                }
            } else {
                showSettingsTip = false
            }
        }
    }

    private var emptyStateView: some View {
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
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
    
    private var achievementView: some View {
        VStack(spacing: 20) {
            Image(systemName: "cup.and.saucer.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(Color("PrimaryButtons"))
            
            Text("Task Accomplished!")
                .font(AppFont.main(size: 20))
                .foregroundColor(Color("PrimaryText"))
            
            Text("Time for a warm cup of Yansoon.")
                .font(AppFont.main(size: 14))
                .foregroundColor(Color("SecondaryText"))
            
            Button(action: {
                withAnimation { appState.clearCompletedTasks() }
            }) {
                Text("Start Fresh")
                    .font(AppFont.main(size: 16))
                    .foregroundColor(.black)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color("PrimaryButtons"))
                    .cornerRadius(12)
            }
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}

//struct SettingsTip: Tip {
//    var title: Text { Text("Settings") }
//    var message: Text? { Text("Adjust your energy limits and preferences here.") }
//}

// MARK: - Helper Function
private func energyImage(for level: EnergyLevel?) -> String {
    switch level {
    case .high: return "yansoonStatus/high"
    case .medium: return "yansoonStatus/medium"
    case .low: return "yansoonStatus/low"
    case nil: return "yansoonStatus/medium"
    }
}

// MARK: - TaskRow
struct TaskRow: View {
    @EnvironmentObject var appState: AppStateViewModel
    let task: TodoTask
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                if task.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color("PrimaryButtons"))
                        .frame(width: 20, height: 20)
                } else {
                    Image(systemName: appState.progress >= 1.0 ? "lock.fill" : "circle")
                        .foregroundColor(appState.progress >= 1.0 ? Color("OffLimit") : Color("PrimaryButtons"))
                        .font(.system(size: 19))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(AppFont.main(size: 16))
                        .foregroundColor(task.isCompleted ? Color("SecondaryText") : Color("PrimaryText"))
                        .strikethrough(task.isCompleted, color: Color("SecondaryText"))
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
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color("OffLimit").opacity(appState.progress >= 1.0 && !task.isCompleted ? 0.3 : 0), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(), value: task.isTimerRunning)
    }
}

// MARK: - Edit Task Sheet
struct EditTaskSheet: View {
    @EnvironmentObject var appState: AppStateViewModel
    @Environment(\.dismiss) var dismiss
    @StateObject private var timeLimitVM = TimeLimitViewModel()
    
    let task: TodoTask
    @State private var editedTitle: String

    init(task: TodoTask) {
        self.task = task
        _editedTitle = State(initialValue: task.title)
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").ignoresSafeArea()

                VStack(spacing: 25) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Task Name")
                            .font(AppFont.main(size: 16))
                            .foregroundColor(Color("SecondaryText"))

                        TextField("Enter task name", text: $editedTitle)
                            .font(AppFont.main(size: 18))
                            .foregroundColor(Color("PrimaryText"))
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color("TaskBox")))
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
                        if let index = appState.tasks.firstIndex(where: { $0.id == task.id }) {
                            appState.tasks[index].title = editedTitle
                            appState.tasks[index].estimatedMinutes = timeLimitVM.selectedMinutes
                        }
                        dismiss()
                    }) {
                        Text("Save Changes")
                            .font(AppFont.main(size: 18))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color("PrimaryButtons"))
                            .cornerRadius(12)
                    }
                    .disabled(editedTitle.isEmpty || timeLimitVM.selectedMinutes < 5)
                }
                .padding(25)
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundColor(Color("PrimaryButtons"))
                }
            }
            .onAppear {
                timeLimitVM.selectedMinutes = task.estimatedMinutes
            }
        }
    }
}

// MARK: - Add Task Sheet
struct AddTaskSheet: View {
    @ObservedObject var viewModel: ToDoViewModel
    @Environment(\.dismiss) var dismiss
    @StateObject private var timeLimitVM = TimeLimitViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").ignoresSafeArea()

                VStack(spacing: 25) {

                    // Task Name
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

                    // Estimated Time
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Estimated Time")
                            .font(AppFont.main(size: 16))
                            .foregroundColor(Color("SecondaryText"))

                        CircularSlidersheet(viewModel: timeLimitVM)
                            .frame(height: 320)
                    }

                    Spacer()
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

            // 🔥 This is the only structural improvement
            .safeAreaInset(edge: .bottom) {
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
                        .padding(.horizontal, 25)
                        .padding(.bottom, 10)
                }
                .disabled(
                    viewModel.newTaskTitle
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .isEmpty ||
                    timeLimitVM.selectedMinutes < 5
                )
                .background(Color("Background"))
            }

            .onAppear {
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

// MARK: - Circular Slider
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
        let center = sliderSize / 2
        let vector = CGVector(dx: value.location.x - center, dy: value.location.y - center)
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

            Circle()
                .trim(from: 0, to: CGFloat(min(max(progress, 0), 1)))
                .stroke(
                    viewModel.isOverAverage ? Color("OffLimit") : Color("ProgressBar"),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(String(format: "%02d", hours))
                    .font(AppFont.main(size: 55))
                    .foregroundColor(Color("PrimaryText"))
                
                Text("h")
                    .font(AppFont.main(size: 20))
                    .foregroundColor(Color("SecondaryText"))
                    .padding(.trailing, 2)

                Text(":")
                    .font(AppFont.main(size: 40))
                    .foregroundColor(Color("SecondaryText"))
                    .padding(.bottom, 8)

                Text(String(format: "%02d", minutes))
                    .font(AppFont.main(size: 55))
                    .foregroundColor(Color("PrimaryText"))
                
                Text("m")
                    .font(AppFont.main(size: 20))
                    .foregroundColor(Color("SecondaryText"))
            }

            Circle()
                .fill(viewModel.isOverAverage ? Color("OffLimit") : Color("ProgressBar"))
                .frame(width: 24, height: 24)
                .offset(y: -sliderSize / 2)
                .rotationEffect(.degrees(progress * 360))
        }
        .frame(width: sliderSize, height: sliderSize)
        .contentShape(Circle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    updateValue(with: value)
                }
        )
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
