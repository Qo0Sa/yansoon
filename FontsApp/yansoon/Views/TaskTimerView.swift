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
    @State private var hasShownOverrunAlert: Bool = false
    let task: TodoTask   // ✅ اضيفيها

    init(task: TodoTask, appState: AppStateViewModel? = nil) {
         self.task = task   // ✅ اضيفيها
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
    
    // الوقت المنقضي - الساعات والدقائق
    private var formattedHoursMinutes: String {
        let elapsedSeconds: Int
        if vm.model.remainingSeconds > 0 {
            let totalAllocated = Int(vm.estimatedMinutes * 60)
            elapsedSeconds = totalAllocated - vm.model.remainingSeconds
        } else {
            let totalAllocated = Int(vm.estimatedMinutes * 60)
            elapsedSeconds = totalAllocated + vm.model.overrunSeconds
        }
        
        let totalMinutes = max(0, elapsedSeconds / 60)
        let hours = totalMinutes / 60
        let mins = totalMinutes % 60
        
        return String(format: "%02d:%02d", hours, mins)
    }
    
    // الثواني فقط
    private var formattedSeconds: String {
        let elapsedSeconds: Int
        if vm.model.remainingSeconds > 0 {
            let totalAllocated = Int(vm.estimatedMinutes * 60)
            elapsedSeconds = totalAllocated - vm.model.remainingSeconds
        } else {
            let totalAllocated = Int(vm.estimatedMinutes * 60)
            elapsedSeconds = totalAllocated + vm.model.overrunSeconds
        }
        
        let secs = elapsedSeconds % 60
        return String(format: ":%02d", secs)
    }
    
    // Progress من 0 إلى 1 بناءً على الوقت المنقضي
    private var elapsedProgress: Double {
        let totalAllocated = vm.estimatedMinutes * 60
        let elapsedSeconds: Double
        
        if vm.model.remainingSeconds > 0 {
            elapsedSeconds = totalAllocated - Double(vm.model.remainingSeconds)
        } else {
            elapsedSeconds = totalAllocated + Double(vm.model.overrunSeconds)
        }
        
        // Progress من 0 إلى 1 (لو تجاوز 100% نخليه يكمل)
        return min(elapsedSeconds / totalAllocated, 1.0)
    }
    
    // Progress للوقت الزائد (بعد ما يخلص الوقت المخصص)
    private var overrunProgress: Double {
        let totalAllocated = vm.estimatedMinutes * 60
        let elapsedSeconds: Double
        
        if vm.model.remainingSeconds > 0 {
            return 0
        } else {
            elapsedSeconds = totalAllocated + Double(vm.model.overrunSeconds)
            let overProgress = (elapsedSeconds - totalAllocated) / totalAllocated
            return min(overProgress, 1.0)
        }
    }
    
    private var playPauseIcon: String {
        switch vm.model.state {
        case .idle: return "play.fill"
        case .running: return "pause.fill"
        case .paused: return "play.fill"
        case .finished: return "play.fill"
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
    
    // حساب الوقت المنقضي بالدقائق
    private func calculateElapsedMinutes() -> Double {
        let elapsedSeconds: Int
        if vm.model.remainingSeconds > 0 {
            let totalAllocated = Int(vm.estimatedMinutes * 60)
            elapsedSeconds = totalAllocated - vm.model.remainingSeconds
        } else {
            let totalAllocated = Int(vm.estimatedMinutes * 60)
            elapsedSeconds = totalAllocated + vm.model.overrunSeconds
        }
        return Double(elapsedSeconds) / 60.0
    }
    
    // حفظ الوقت المنقضي وإيقاف التايمر
    private func saveAndDismiss() {
        let elapsedMinutes = calculateElapsedMinutes()

        // ✅ منع Done إذا ما فيه وقت
        guard elapsedMinutes > 0 else {
            // Optional: vibration خفيف عشان يعرف إن الزر ما اشتغل
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            return
        }

        vm.done()
        updatePulseIfNeeded()

        // إضافة الوقت
        appState.addCompletedTime(taskId: task.id, minutes: elapsedMinutes)

        // ✅ تحديد أن التاسك اكتملت فقط بعد Done
        appState.markTaskDone(task.id)

        dismiss()
    }

    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // الدائرة نفس CircularSlidersheet
                ZStack {
                    // Background Track
                    Circle()
                        .stroke(Color("PrimaryText").opacity(0.1), lineWidth: 10)
                        .frame(width: 300, height: 300)
                    
                    // Progress Bar (الوقت المخصص - لون أخضر)
                    Circle()
                        .trim(from: 0, to: CGFloat(elapsedProgress))
                        .stroke(Color("ProgressBar"),
                                style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(width: 300, height: 300)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.2), value: elapsedProgress)
                        .scaleEffect(isPulsing ? 1.02 : 1.0)
                    
                    // Overrun Progress Bar (الوقت الزائد - لون أحمر)
                    Circle()
                        .trim(from: 0, to: CGFloat(overrunProgress))
                        .stroke(Color("OffLimit"),
                                style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(width: 300, height: 300)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.2), value: overrunProgress)
                        .scaleEffect(isPulsing ? 1.02 : 1.0)
                    
                    // عرض الوقت في وسط الدائرة - الساعات والدقائق كبيرة والثواني صغيرة
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
                        
                        Text(allocatedText)
                            .font(AppFont.main(size: 14))
                            .foregroundColor(Color("SecondaryText"))
                    }
                    
                    // Knob - يتحرك مع التقدم
                    Circle()
                        .fill(vm.model.overrunSeconds > 0 ? Color("OffLimit") : Color("ProgressBar"))
                        .frame(width: 24, height: 24)
                        .offset(y: -150)
                        .rotationEffect(.degrees((vm.model.overrunSeconds > 0 ? overrunProgress : elapsedProgress) * 360))
                }
                
                // الأزرار
                HStack(spacing: 16) {
                    // زر Done الكبير
                    Button {
                        saveAndDismiss()
                    } label: {
                        Text("Done")
                            .font(AppFont.main(size: 18))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.primaryButtons)
                            .cornerRadius(15)
                    }
                    
                    // زر Start/Pause الصغير (أيقون فقط)
                    Button {
                        vm.primaryButtonTapped()
                        updatePulseIfNeeded()
                    } label: {
                        Image(systemName: playPauseIcon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.  primaryButtons)
                            .frame(width: 56, height: 56)
                            .background(.primaryButtons.opacity(0.2))
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
            vm.syncNow()   // ⭐ يخلي الوقت يتحدث إذا رجعتي للتطبيق
            updatePulseIfNeeded()
        }
        
        .navigationTitle("Timer")
        .navigationBarTitleDisplayMode(.inline)

        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            vm.syncNow()   // ⭐ إذا رجع التطبيق من الخلفية
        }

        .onChange(of: vm.model.state) { _, _ in
            updatePulseIfNeeded()
        }
        .onChange(of: vm.model.overrunSeconds) { oldValue, newValue in
            // عند أول ثانية من تجاوز الوقت، نعطي تنبيه
            if oldValue == 0 && newValue > 0 && !hasShownOverrunAlert {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.warning)
                hasShownOverrunAlert = true
            }
        }
        // إخفاء عناصر شريط التنقل الافتراضي
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    vm.pause()     // اختياري: يوقف التايمر قبل الرجوع
                    dismiss()      // يرجع فقط بدون ما يسوي Done
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
