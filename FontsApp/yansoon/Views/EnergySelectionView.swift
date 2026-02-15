//
//  EnergySelectionView.swift
//  yansoon
//
//  Created by Rana Alngashy on 17/08/1447 AH.
//


import SwiftUI

struct EnergySelectionView: View {
    @EnvironmentObject var appState: AppStateViewModel
    @StateObject private var selectionVM = EnergySelectionViewModel()
    @Environment(\.dismiss) var dismiss // 1. ADD THIS LINE
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                Text("Choose Your Current Energy Level")
                    .font(AppFont.main(size: 20))
                Text("How are you feeling right now?")
                    .font(AppFont.main(size: 16))
                    .opacity(0.7)
            }
            .foregroundColor(Color("PrimaryText"))
            .padding(.top, 50)
            
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
                
                appState.currentMode = selected
              
                print("⏰ Initial Notification Scheduled")
                appState.completeSetup()
                
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
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 40)
        .onAppear {
            selectionVM.appState = appState
        }
        .background(Color("Background").ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        // 2. ADD THIS TOOLBAR MODIFIER HERE:
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss() // This takes you back to TimeLimitView (Low Energy)
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(Color("PrimaryButtons"))
                }
            }
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
        Button(action: {
            withAnimation(.spring()) {
                selected = level
            }
        }) {
            VStack(spacing: 8) {
                Image(img)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .opacity(selected == level || selected == nil ? 1 : 0.4)
                    .scaleEffect(selected == level ? 1.1 : 1.0)
                
                Text(level.title)
                    .font(AppFont.main(size: 20))
                    .foregroundColor(selected == level ? Color("PrimaryButtons") : Color("PrimaryText"))
                
                Text(sub)
                    .font(AppFont.main(size: 14))
                    .foregroundColor(Color("PrimaryText").opacity(0.5))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    EnergySelectionView()
        .environmentObject(AppStateViewModel())
        .preferredColorScheme(.dark)
}
