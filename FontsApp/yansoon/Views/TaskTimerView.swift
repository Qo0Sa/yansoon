//
//  TaskTimerView.swift
//  yansoon
//
//  Created by Sarah on 17/08/1447 AH.
//
//كلها 
import Combine
import SwiftUI

struct TaskTimerView: View {
    @EnvironmentObject var appState: AppStateViewModel
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var vm: TaskTimerViewModel
    @State private var isPulsing: Bool = false
    
    init(task: TodoTask, appState: AppStateViewModel? = nil) {
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
    
    private var formattedHourMinute: String {
        let seconds = vm.model.remainingSeconds > 0 ? vm.model.remainingSeconds : vm.model.overrunSeconds
        let totalMinutes = max(0, seconds / 60)
        let hours = totalMinutes / 60
        let mins = totalMinutes % 60
        let base = String(format: "%02d:%02d", hours, mins)
        return vm.model.remainingSeconds > 0 ? base : "+\(base)"
    }
    
    private var primaryButtonTitle: String {
        switch vm.model.state {
        case .idle: return "start"
        case .running: return "pause"
        case .paused: return "resume"
        case .finished: return "done"
        }
    }
    
    private var primaryButtonColor: Color {
        switch vm.model.state {
        case .idle: return Color("PrimaryButtons")
        case .running: return Color("PrimaryButtons")
        case .paused: return Color("DoneButton")
        case .finished: return Color("DoneButton")
        }
    }
    
    private func updatePulseIfNeeded() {
        if vm.model.state == .running {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        } else {
            withAnimation(.easeInOut(duration: 0.2)) {
                isPulsing = false
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            
            VStack(spacing: 32) {
                // لا يوجد هيدر ولا زر رجوع هنا
                
                Spacer()
                
                // الدائرة + الوقت + allocated
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: 14)
                        .frame(width: 240, height: 240)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(vm.model.plannedProgress))
                        .stroke(Color("ProgressBar"),
                                style: StrokeStyle(lineWidth: 14, lineCap: .round))
                        .frame(width: 240, height: 240)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.2), value: vm.model.plannedProgress)
                        .opacity(vm.model.plannedProgress > 0 ? 1 : 0)
                        .scaleEffect(isPulsing ? 1.03 : 1.0)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(vm.model.offLimitProgress))
                        .stroke(Color("OffLimit"),
                                style: StrokeStyle(lineWidth: 14, lineCap: .round))
                        .frame(width: 240, height: 240)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.2), value: vm.model.offLimitProgress)
                        .opacity(vm.model.offLimitProgress > 0 ? 1 : 0)
                        .scaleEffect(isPulsing ? 1.03 : 1.0)
                    
                    VStack(spacing: 6) {
                        Text(formattedHourMinute)
                            .font(AppFont.main(size: 48))
                            .foregroundColor(Color("PrimaryText"))
                        Text(allocatedText)
                            .font(AppFont.main(size: 14))
                            .foregroundColor(Color("SecondaryText"))
                    }
                }
                
                // الأزرار
                HStack(spacing: 16) {
                    Button {
                        vm.primaryButtonTapped()
                        updatePulseIfNeeded()
                    } label: {
                        Text(primaryButtonTitle)
                            .font(AppFont.main(size: 18))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(primaryButtonColor)
                            .cornerRadius(15)
                    }
                    
                    Button {
                        vm.done()
                        updatePulseIfNeeded()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(width: 56, height: 56)
                            .background(Color("DoneButton"))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer(minLength: 20)
            }
        }
        .onAppear {
            if vm.appState == nil {
                vm.appState = appState
            }
            updatePulseIfNeeded()
        }
        .onChange(of: vm.model.state) { _, _ in
            updatePulseIfNeeded()
        }
        // إخفاء عناصر شريط التنقل الافتراضي
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) { EmptyView() }
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
