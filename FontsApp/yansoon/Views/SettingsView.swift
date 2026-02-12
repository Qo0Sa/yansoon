






import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppStateViewModel
    @StateObject private var vm = SettingsViewModel()

    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()

            VStack(spacing: 22) {

              
               

                //////////////////////////////////////////////////////
                // ⭐ الكارد الخلفي الكبير
                //////////////////////////////////////////////////////
                VStack(spacing: 14) {
                    // Toggle
                    HStack {
                        Text("Use Default Settings")
                            .font(AppFont.main(size: 18))
                            .foregroundColor(.primaryText)
                        Spacer()

                        Toggle("", isOn: Binding(
                            get: { vm.useDefaultSettings },
                            set: { newValue in
                                vm.useDefaultSettings = newValue
                                if newValue { vm.setDefaultIfNeeded() }
                            }
                        ))
                        .labelsHidden()
                        .tint(Color("PrimaryButtons"))
                    }
                    
                    EnergyCard(
                        level: .high,
                        hours: $vm.highHours,
                        isOverAverage: vm.isOverAverage(level: .high),
                        disabled: vm.useDefaultSettings,
                        onChange: vm.updateHigh
                    )

                    EnergyCard(
                        level: .medium,
                        hours: $vm.mediumHours,
                        isOverAverage: vm.isOverAverage(level: .medium),
                        disabled: vm.useDefaultSettings,
                        onChange: vm.updateMedium
                    )

                    EnergyCard(
                        level: .low,
                        hours: $vm.lowHours,
                        isOverAverage: vm.isOverAverage(level: .low),
                        disabled: vm.useDefaultSettings,
                        onChange: vm.updateLow
                    )
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                )

                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .onAppear { vm.bind(appState: appState)}
            
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
            
        
        
    }
}

//////////////////////////////////////////////////////////////
// MARK: - EnergyCard (كل Level له كارد خاص)
//////////////////////////////////////////////////////////////

private struct EnergyCard: View {
    let level: EnergyLevel
    @Binding var hours: Double
    let isOverAverage: Bool
    let disabled: Bool
    let onChange: (Double) -> Void

    private let sliderSize: CGFloat = 110

    private var progress: Double {
        hours / level.maxHours
    }

    private var formattedHours: String {
        let totalMinutes = Int(hours * 60)
        let h = totalMinutes / 60
        let m = totalMinutes % 60
        return String(format: "%02d:%02d", h, m)
    }

    private func imageName(for level: EnergyLevel) -> String {
        switch level {
        case .high: return "yansoonStatus/high"
        case .medium: return "yansoonStatus/medium"
        case .low: return "yansoonStatus/low"
        }
    }

    var body: some View {
        VStack(spacing: 10) {

            // ⭐ الليفل فوق
            Text(level.title)
                .font(AppFont.main(size: 17))
                .foregroundColor(Color("PrimaryText"))

            // ⭐ الدائرة
            ZStack {
                Circle()
                    .stroke((Color("PrimaryText")).opacity(0.1), lineWidth: 8)
                    .frame(width: sliderSize, height: sliderSize)

                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(isOverAverage ? Color("OffLimit") : Color("ProgressBar"),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: sliderSize, height: sliderSize)
                    .rotationEffect(.degrees(-90))

                Image(imageName(for: level))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 45, height: 45)

                // Knob
                Circle()
                    .fill(isOverAverage ? Color("OffLimit") : Color("ProgressBar"))
                    .frame(width: 14, height: 14)
                    .offset(y: -sliderSize / 2)
                    .rotationEffect(.degrees(progress * 360))
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                guard !disabled else { return }
                                updateValue(with: value)
                            }
                    )
            }

            // ⭐ الوقت تحت
            Text(formattedHours)
                .font(AppFont.main(size: 22))
                .foregroundColor(Color("PrimaryText"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.04)) // ⭐ كارد لكل Level
        )
        .opacity(disabled ? 0.5 : 1)
    }

    private func updateValue(with value: DragGesture.Value) {
        let center = sliderSize / 2
        let vector = CGVector(dx: value.location.x - center,
                              dy: value.location.y - center)

        let radians = atan2(vector.dy, vector.dx)
        var angle = Double(radians * 180 / .pi) + 90

        if angle < 0 { angle += 360 }

        let newHours = (angle / 360) * level.maxHours
        let stepped = (newHours * 2).rounded() / 2

        hours = min(level.maxHours, max(0, stepped))
        onChange(hours)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppStateViewModel())
        .preferredColorScheme(.dark)
}
