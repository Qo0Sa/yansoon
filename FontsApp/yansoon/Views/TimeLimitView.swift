////
////  TimeLimitView.swift
////  yansoon
////
//import SwiftUI
//
//struct TimeLimitView: View {
//    @ObservedObject var viewModel: TimeLimitViewModel
//    @EnvironmentObject var appState: AppStateViewModel
//    @Environment(\.dismiss) var dismiss
//    
//    // Helper to extract hours and minutes for the display
//    private var hours: Int { Int(viewModel.selectedMinutes) / 60 }
//    private var minutes: Int { Int(viewModel.selectedMinutes) % 60 }
//    
//    var body: some View {
//        ZStack {
//            Color("Background").ignoresSafeArea()
//            
//            VStack(spacing: 25) {
//                Spacer()
//                VStack(spacing: 12) {
//                    Text("Set your working hours based on energy")
//                        .font(AppFont.main(size: 18))
//                    Text(viewModel.currentLevel.title)
//                        .font(AppFont.main(size: 18))
//                        .opacity(0.7)
//                }
//                .foregroundColor(Color("PrimaryText"))
//                .multilineTextAlignment(.center)
//                .padding(.horizontal)
//                
//                Spacer()
//                
//                CircularSliderComponent(viewModel: viewModel)
//                
//                Button(action: { viewModel.setDefault() }) {
//                    Text("Set by default")
//                        .font(AppFont.main(size: 18))
//                        .foregroundColor(Color("PrimaryButtons"))
//                }
//                
//                // MARK: - Updated Time Display with h and m
//                HStack(alignment: .lastTextBaseline, spacing: 2) {
//                    Text(String(format: "%02d", hours))
//                        .font(AppFont.main(size: 80))
//                        .foregroundColor(Color("PrimaryText"))
//                    
//                    Text("h")
//                        .font(AppFont.main(size: 24))
//                        .foregroundColor(Color("SecondaryText"))
//                        .padding(.trailing, 5)
//
//                    Text(String(format: "%02d", minutes))
//                        .font(AppFont.main(size: 80))
//                        .foregroundColor(Color("PrimaryText"))
//                    
//                    Text("m")
//                        .font(AppFont.main(size: 24))
//                        .foregroundColor(Color("SecondaryText"))
//                }
//                
//                Spacer()
//                
//                VStack(spacing: 20) {
//                    if viewModel.currentLevel == .low {
//                        NavigationLink(destination: EnergySelectionView().environmentObject(appState)) {
//                            Text("Next")
//                                .font(AppFont.main(size: 20))
//                                .foregroundColor(.black)
//                                .frame(maxWidth: .infinity)
//                                .padding(.vertical, 16)
//                                .background(Color("PrimaryButtons"))
//                                .cornerRadius(15)
//                        }
//                    } else {
//                        Button(action: {
//                            withAnimation {
//                                viewModel.nextLevel()
//                            }
//                        }) {
//                            Text("Next")
//                                .font(AppFont.main(size: 20))
//                                .foregroundColor(.black)
//                                .frame(maxWidth: .infinity)
//                                .padding(.vertical, 16)
//                                .background(Color("PrimaryButtons"))
//                                .cornerRadius(15)
//                        }
//                    }
//                }
//                .padding(.horizontal, 30)
//                
//                HStack(spacing: 10) {
//                    ForEach(0..<3) { index in
//                        Circle()
//                            .fill(index == viewModel.currentLevel.rawValue ? Color("PrimaryButtons") : Color.gray)
//                            .frame(width: 8, height: 8)
//                    }
//                }
//                .padding(.bottom, 30)
//            }
//        }
//        .navigationBarTitleDisplayMode(.inline)
//        .navigationBarBackButtonHidden(true)
//        .toolbar {
//            if viewModel.currentLevel != .high {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button(action: {
//                        if let previous = EnergyLevel(rawValue: viewModel.currentLevel.rawValue - 1) {
//                            withAnimation {
//                                viewModel.currentLevel = previous
//                                viewModel.selectedMinutes = appState.energySettings.hours(for: previous) * 60
//                            }
//                        }
//                    }) {
//                        HStack(spacing: 5) {
//                            Image(systemName: "chevron.left")
//                            Text("Back")
//                        }
//                        .foregroundColor(Color("PrimaryButtons"))
//                    }
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Circular Slider Component
//struct CircularSliderComponent: View {
//    @ObservedObject var viewModel: TimeLimitViewModel
//    
//    private let sliderSize: CGFloat = 300
//    
//    private var progress: Double {
//        viewModel.selectedMinutes / (viewModel.currentLevel.maxHours * 60)
//    }
//    
//    private func imageName(for level: EnergyLevel) -> String {
//        switch level {
//        case .high: return "yansoonStatus/high"
//        case .medium: return "yansoonStatus/medium"
//        case .low: return "yansoonStatus/low"
//        }
//    }
//    
//    var body: some View {
//        ZStack {
//            Circle()
//                .stroke((Color("PrimaryText")).opacity(0.1), lineWidth: 10)
//                .frame(width: sliderSize, height: sliderSize)
//            
//            Circle()
//                .trim(from: 0, to: CGFloat(progress))
//                .stroke(viewModel.isOverAverage ? Color("OffLimit") : Color("ProgressBar"),
//                        style: StrokeStyle(lineWidth: 10, lineCap: .round))
//                .frame(width: sliderSize, height: sliderSize)
//                .rotationEffect(.degrees(-90))
//            
//            Image(imageName(for: viewModel.currentLevel))
//                .resizable()
//                .scaledToFit()
//                .frame(width: 220, height: 220)
//                .animation(.easeInOut, value: viewModel.currentLevel)
//            
//            Circle()
//                .fill(viewModel.isOverAverage ? Color("OffLimit") : Color("ProgressBar"))
//                .frame(width: 24, height: 24)
//                .offset(y: -sliderSize / 2)
//                .rotationEffect(.degrees(progress * 360))
//        }
//        .frame(width: sliderSize, height: sliderSize)
//        .contentShape(Circle())
//        .gesture(
//            DragGesture(minimumDistance: 0)
//                .onChanged { value in
//                    updateValue(with: value)
//                }
//        )
//    }
//    
//    private func updateValue(with value: DragGesture.Value) {
//        let center = sliderSize / 2
//        let vector = CGVector(dx: value.location.x - center, dy: value.location.y - center)
//        let radians = atan2(vector.dy, vector.dx)
//        var angle = Double(radians * 180 / .pi) + 90
//        
//        if angle < 0 { angle += 360 }
//        
//        let totalMinutes = (angle / 360) * (viewModel.currentLevel.maxHours * 60)
//        let snapped = (totalMinutes / 5).rounded() * 5
//        viewModel.selectedMinutes = min(viewModel.currentLevel.maxHours * 60, max(0, snapped))
//    }
//}
//
//#Preview {
//    let mockVM = TimeLimitViewModel()
//    mockVM.currentLevel = .high
//    return TimeLimitView(viewModel: mockVM)
//        .environmentObject(AppStateViewModel())
//        .preferredColorScheme(.dark)
//}
