//
//  EnergySelectionView.swift
//  yansoon
//
//  Created by Rana Alngashy on 17/08/1447 AH.
//  Updated to work with AppStateViewModel
//

import SwiftUI

struct EnergySelectionView: View {
    @EnvironmentObject var appState: AppStateViewModel
    @StateObject private var selectionVM = EnergySelectionViewModel()
    
    @State private var shouldNavigate = false
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(spacing: 12) {
                    Text("Choose Your Current Energy Level")
                        .font(AppFont.main(size: 26))
                    Text("How are you feeling right now?")
                        .font(AppFont.main(size: 16))
                        .opacity(0.7)
                }
                .foregroundColor(.white)
                .padding(.top, 50)
                
                Spacer()
                
                // The three Anise options
                VStack(spacing: 35) {
                    EnergyButton(
                        level: .high,
                        sub: "Feeling great and ready to focus",
                        img: "AniseHigh",
                        selected: $selectionVM.selectedLevel
                    )
                    EnergyButton(
                        level: .medium,
                        sub: "Steady but not at full capacity",
                        img: "AniseMedium",
                        selected: $selectionVM.selectedLevel
                    )
                    EnergyButton(
                        level: .low,
                        sub: "Tired and needing gentleness",
                        img: "AniseLow",
                        selected: $selectionVM.selectedLevel
                    )
                }
                
                Spacer()
                
                // Continue Button
                Button(action: {
                    if let level = selectionVM.selectedLevel {
                        appState.currentMode = level
                        shouldNavigate = true
                    }
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
        .onAppear {
            selectionVM.appState = appState
        }
        .navigationDestination(isPresented: $shouldNavigate) {
            ToDoView()
                .environmentObject(appState)
        }
    }
}

// MARK: - EnergyButton Component
struct EnergyButton: View {
    let level: EnergyLevel
    let sub: String
    let img: String
    @Binding var selected: EnergyLevel?
    
    var body: some View {
        Button(action: { selected = level }) {
            VStack(spacing: 8) {
                Image(img)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .opacity(selected == level || selected == nil ? 1 : 0.4)
                
                Text(level.title)
                    .font(AppFont.main(size: 20))
                    .foregroundColor(selected == level ? Color("PrimaryButtons") : .white)
                
                Text(sub)
                    .font(AppFont.main(size: 14))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }
}

// MARK: - Preview
#Preview("Energy Selection View") {
    NavigationStack {
        EnergySelectionView()
            .environmentObject({
                let appState = AppStateViewModel()
                appState.energySettings = EnergySettings(
                    highEnergyHours: 4.5,
                    mediumEnergyHours: 3.0,
                    lowEnergyHours: 1.5
                )
                return appState
            }())
    }
}

#Preview("Energy Selection - Dark Mode") {
    NavigationStack {
        EnergySelectionView()
            .environmentObject(AppStateViewModel())
    }
    .preferredColorScheme(.dark)
}

#Preview("Energy Selection - Light Mode") {
    NavigationStack {
        EnergySelectionView()
            .environmentObject(AppStateViewModel())
    }
    .preferredColorScheme(.light)
}
