
//
//  TimeLimitView.swift
//  yansoon
//
//  Created by Noor Alhassani on 16/08/1447 AH.
//
//
//  TimeLimitView.swift
//  yansoon
//
//  Created by Noor Alhassani on 16/08/1447 AH.
//

import SwiftUI


struct TimeLimitView: View {
    // Corrected: Accept the injected ViewModel from MainFlowView
    @ObservedObject var viewModel: TimeLimitViewModel
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Header
                Text("Time Limits")
                    .font(AppFont.main(size: 24))
                    .foregroundColor(Color("PrimaryButtons"))
                    .padding(.top, 20)
                
                VStack(spacing: 12) {
                    Text("Set your working hours based on energy")
                        .font(AppFont.main(size: 18))
                        .foregroundColor(.white)
                    
                    Text(viewModel.currentLevel.title)
                        .font(AppFont.main(size: 18))
                        .foregroundColor(.white.opacity(0.7))
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                
                Spacer()
                
                // Slider Section
                CircularSliderComponent(viewModel: viewModel)
                
                // Time Display
                Text(viewModel.formattedTime)
                    .font(AppFont.main(size: 80))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Buttons Section
                VStack(spacing: 20) {
                    Button(action: { viewModel.nextLevel() }) {
                        // Correct: Changes to "Done" on the last step
                        Text(viewModel.currentLevel == .low ? "Done" : "Next")
                            .font(AppFont.main(size: 20))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                Color("PrimaryButtons")
                                    .opacity(0.9)
                                    .blur(radius: 0.5)
                            )
                            .cornerRadius(15)
                    }
                    Button(action: { viewModel.setDefault() }) {
                        Text("Set by Default")
                            .font(AppFont.main(size: 18))
                            .foregroundColor(Color("PrimaryButtons"))
                    }
                }
                .padding(.horizontal, 30)
                
                // Pagination Dots
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
    }
}

// MARK: - Refined Slider Component
struct CircularSliderComponent: View {
    @ObservedObject var viewModel: TimeLimitViewModel
    
    private let sliderSize: CGFloat = 300
    
    private var progress: Double {
        viewModel.selectedMinutes / (viewModel.currentLevel.maxHours * 60)
    }
    
    var body: some View {
        ZStack {
            // Background Track
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 10)
                .frame(width: sliderSize, height: sliderSize)
            
            // Progress Bar
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(viewModel.isOverAverage ? Color("OffLimit") : Color("ProgressBar"),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .frame(width: sliderSize, height: sliderSize)
                .rotationEffect(.degrees(-90))
            
            // Center Anise Image (Asset)
            Image("AniseShape")
                .resizable()
                .scaledToFit()
                .frame(width: 220, height: 220)
            
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
