//
//  TaskTimerView.swift
//  yansoon
//
//  Created by Sarah on 17/08/1447 AH.
//
import Combine
import SwiftUI

struct TaskTimerView: View {
    @EnvironmentObject var appState: AppStateViewModel
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var vm: TaskTimerViewModel
    @State private var isPulsing: Bool = false
    @State private var hasShownOverrunAlert: Bool = false
    let task: TodoTask

    init(task: TodoTask, appState: AppStateViewModel? = nil) {
         self.task = task
         _vm = StateObject(wrappedValue: TaskTimerViewModel(task: task, appState: appState))
     }
    
    private var allocatedText: String {
        let minutes = Int(vm.estimatedMinutes)
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 && mins == 0 {
            return "\(hours) hour allocated"
        } else if hours > 0 && mins > 0 {
            return "\(hours)h \(mins)m allocated"
        } else {
            return "\(mins) min allocated"
        }
    }
    
    private var formattedHoursMinutes: String {
        let totalAllocated = Int(vm.estimatedMinutes * 60)
        let elapsedSeconds = vm.model.remainingSeconds > 0 ? (totalAllocated - vm.model.remainingSeconds) : (totalAllocated + vm.model.overrunSeconds)
        let totalMinutes = max(0, elapsedSeconds / 60)
        return String(format: "%02d:%02d", totalMinutes / 60, totalMinutes % 60)
    }
    
    private var formattedSeconds: String {
        let totalAllocated = Int(vm.estimatedMinutes * 60)
        let elapsedSeconds = vm.model.remainingSeconds > 0 ? (totalAllocated - vm.model.remainingSeconds) : (totalAllocated + vm.model.overrunSeconds)
        return String(format: ":%02d", elapsedSeconds % 60)
    }
    
    private var elapsedProgress: Double {
        let totalAllocated = vm.estimatedMinutes * 60
        let elapsed = vm.model.remainingSeconds > 0 ? (totalAllocated - Double(vm.model.remainingSeconds)) : totalAllocated
        return min(elapsed / totalAllocated, 1.0)
    }
    
    private var overrunProgress: Double {
        guard vm.model.remainingSeconds == 0 else { return 0 }
        let totalAllocated = vm.estimatedMinutes * 60
        return min(Double(vm.model.overrunSeconds) / totalAllocated, 1.0)
    }
    
    private func updatePulseIfNeeded() {
        withAnimation(vm.isRunning ? .easeInOut(duration: 0.9).repeatForever(autoreverses: true) : .easeInOut(duration: 0.2)) {
            isPulsing = vm.isRunning
        }
    }
    
    private func calculateElapsedMinutes() -> Double {
        let totalAllocated = Int(vm.estimatedMinutes * 60)
        let elapsedSeconds = vm.model.remainingSeconds > 0 ? (totalAllocated - vm.model.remainingSeconds) : (totalAllocated + vm.model.overrunSeconds)
        return Double(elapsedSeconds) / 60.0
    }
    
    private func saveAndDismiss() {
        let elapsedMinutes = calculateElapsedMinutes()
        guard elapsedMinutes > 0 else {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            return
        }

        vm.done()
        updatePulseIfNeeded()
        appState.addCompletedTime(taskId: task.id, minutes: elapsedMinutes)
        appState.markTaskDone(task.id)

        // --- Part 3: Send "Are you done?" signal ---
        UserDefaults.standard.set(true, forKey: "pending_done_check")
        NotificationManager.shared.sendImmediateNotification(
            title: "Task Finished!",
            body: "Are you done working? Open Yansoon to check in."
        )

        dismiss()
    }

    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            
            VStack(spacing: 32) {
                // --- Part 1.1: Top Overrun Alert ---
                if vm.model.overrunSeconds > 0 {
                    Text("⚠️ Timer exceeded task estimation time")
                        .font(AppFont.main(size: 14))
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color("OffLimit"))
                        .cornerRadius(20)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color("PrimaryText").opacity(0.1), lineWidth: 10)
                        .frame(width: 300, height: 300)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(elapsedProgress))
                        .stroke(Color("ProgressBar"), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(width: 300, height: 300)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.2), value: elapsedProgress)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(overrunProgress))
                        .stroke(Color("OffLimit"), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(width: 300, height: 300)
                        .rotationEffect(.degrees(-90))
                        .scaleEffect(isPulsing ? 1.02 : 1.0)
                    
                    VStack(spacing: 8) {
                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                            Text(formattedHoursMinutes)
                                .font(AppFont.main(size: 60))
                                .foregroundColor(vm.model.overrunSeconds > 0 ? Color("OffLimit") : Color("PrimaryText"))
                                .monospacedDigit()
                            
                            Text(formattedSeconds)
                                .font(AppFont.main(size: 24))
                                .foregroundColor(vm.model.overrunSeconds > 0 ? Color("OffLimit") : Color("PrimaryText"))
                                .monospacedDigit()
                        }
                        
                        // --- Part 1.3: Red +Time Passed ---
                        if vm.model.overrunSeconds > 0 {
                            Text("+\(vm.model.overrunSeconds / 60) min")
                                .font(AppFont.main(size: 18 ))
                                .foregroundColor(Color("OffLimit"))
                        }
                        
                        Text(allocatedText)
                            .font(AppFont.main(size: 14))
                            .foregroundColor(Color("SecondaryText"))
                    }
                    
                    Circle()
                        .fill(vm.model.overrunSeconds > 0 ? Color("OffLimit") : Color("ProgressBar"))
                        .frame(width: 24, height: 24)
                        .offset(y: -150)
                        .rotationEffect(.degrees((vm.model.overrunSeconds > 0 ? overrunProgress : elapsedProgress) * 360))
                }
                
                HStack(spacing: 16) {
                    Button { saveAndDismiss() } label: {
                        Text("Done")
                            .font(AppFont.main(size: 18))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color("PrimaryButtons"))
                            .cornerRadius(15)
                    }
                    
                    Button {
                        vm.primaryButtonTapped()
                        updatePulseIfNeeded()
                    } label: {
                        Image(systemName: vm.isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color("PrimaryButtons"))
                            .frame(width: 56, height: 56)
                            .background(Color("PrimaryButtons").opacity(0.2))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer(minLength: 20)
            }
        }
        .onAppear {
            if vm.appState == nil { vm.appState = appState }
            vm.syncNow()
            updatePulseIfNeeded()
        }
        .navigationTitle("Timer")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            vm.syncNow()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    vm.pause()
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color("PrimaryButtons"))
                }
            }
        }
    }
}

#Preview {
    let appState = AppStateViewModel()
    let task = TodoTask(title: "One hour task", estimatedMinutes: 60, actualMinutes: 0)
    return TaskTimerView(task: task, appState: appState)
        .environmentObject(appState)
        .preferredColorScheme(.dark)
}
