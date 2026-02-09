
//
//  TimeLimitView.swift
//  yansoon
//
//  Created by Noor Alhassani on 16/08/1447 AH.
//
//

import SwiftUI


struct TimeLimitView: View {
    @ObservedObject var viewModel: TimeLimitViewModel
    @EnvironmentObject var appState: AppStateViewModel
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            
            VStack(spacing: 25) {
                Spacer()
                VStack(spacing: 12) {
                    Text("Set your working hours based on energy")
                        .font(AppFont.main(size: 18))
                    Text(viewModel.currentLevel.title)
                        .font(AppFont.main(size: 18))
                        .opacity(0.7)
                }
                .foregroundColor(Color("PrimaryText"))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                
                Spacer()
                
                CircularSliderComponent(viewModel: viewModel)
                
                Button(action: { viewModel.setDefault() }) {
                    Text("Set by default")
                        .font(AppFont.main(size: 18))
                        .foregroundColor(Color("PrimaryButtons"))
                }
                
                Text(viewModel.formattedTime)
                    .font(AppFont.main(size: 80))
                    .foregroundColor(Color("PrimaryText"))
                
                Spacer()
                
                VStack(spacing: 20) {
                    if viewModel.currentLevel == .low {
                        // On the final step, navigate to Energy Selection
                        NavigationLink(destination: EnergySelectionView().environmentObject(appState)) {
                            Text("Next")
                                .font(AppFont.main(size: 20))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color("PrimaryButtons"))
                                .cornerRadius(15)
                        }
                    } else {
                        Button(action: { viewModel.nextLevel() }) {
                            Text("Next")
                                .font(AppFont.main(size: 20))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color("PrimaryButtons"))
                                .cornerRadius(15)
                        }
                    }
                }
                .padding(.horizontal, 30)
                
                HStack(spacing: 10) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(index == viewModel.currentLevel.rawValue ? Color("PrimaryButtons") : Color.gray)
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
    }
}
// MARK: - Refined Slider Component
struct CircularSliderComponent: View {
    @ObservedObject var viewModel: TimeLimitViewModel
    
    private let sliderSize: CGFloat = 300
    
    private var progress: Double {
        viewModel.selectedMinutes / (viewModel.currentLevel.maxHours * 60)
    }
    
    // Helper function to pick the right asset based on level
    private func imageName(for level: EnergyLevel) -> String {
        switch level {
        case .high:
            return "yansoonStatus/high"
        case .medium:
            return "yansoonStatus/medium"
        case .low:
            return "yansoonStatus/low"
        }
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
            
            // Center Anise Image - Now DYNAMIC
            Image(imageName(for: viewModel.currentLevel))
                .resizable()
                .scaledToFit()
                .frame(width: 220, height: 220)
                .animation(.easeInOut, value: viewModel.currentLevel)
            
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
    
    private func updateValue(with value: DragGesture.Value) {
        let vector = CGVector(dx: value.location.x, dy: value.location.y)
        let radians = atan2(vector.dy, vector.dx)
        var angle = Double(radians * 180 / .pi) + 90
        
        if angle < 0 { angle += 360 }
        
        let totalMinutes = (angle / 360) * (viewModel.currentLevel.maxHours * 60)
        let snapped = (totalMinutes / 5).rounded() * 5
        viewModel.selectedMinutes = min(viewModel.currentLevel.maxHours * 60, max(0, snapped))
    }
}
#Preview {
    let mockVM = TimeLimitViewModel()
    // You can set it to .medium or .low here to see different versions!
    mockVM.currentLevel = .high
    
    return TimeLimitView(viewModel: mockVM)
        .preferredColorScheme(.dark)
}
