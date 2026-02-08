//
//  SettingsView.swift
//  yansoon
//
//  Created by Noura Faiz Alfaiz on 08/02/2026.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppStateViewModel
    @StateObject private var vm = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header (بدون سهم رجوع)
                    HStack {
                        // إزالة زر السهم
                        Text("Settings")
                            .font(AppFont.main(size: 24))
                            .foregroundColor(Color("PrimaryText"))
                        Spacer()
                        Color.clear.frame(width: 24, height: 24)
                    }
                    .padding(.top, 8)
                    
                    // Time Limits Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Time Limits")
                            .font(AppFont.main(size: 18))
                            .foregroundColor(Color("PrimaryText"))
                        
                        HStack {
                            Text("Use Default Settings")
                                .font(AppFont.main(size: 16))
                                .foregroundColor(Color("SecondaryText"))
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { vm.useDefaultSettings },
                                set: { newValue in
                                    vm.useDefaultSettings = newValue
                                    if newValue {
                                        vm.setDefaultIfNeeded()
                                    }
                                }
                            ))
                            .labelsHidden()
                            .tint(Color("PrimaryButtons"))
                        }
                        .padding(.horizontal, 12)
                        
                        // Cards
                        VStack(spacing: 12) {
                            EnergyCard(
                                level: .high,
                                hours: $vm.highHours,
                                progress: vm.progress(for: .high),
                                isOverAverage: vm.isOverAverage(level: .high),
                                disabled: vm.useDefaultSettings,
                                onChange: vm.updateHigh
                            )
                            
                            EnergyCard(
                                level: .medium,
                                hours: $vm.mediumHours,
                                progress: vm.progress(for: .medium),
                                isOverAverage: vm.isOverAverage(level: .medium),
                                disabled: vm.useDefaultSettings,
                                onChange: vm.updateMedium
                            )
                            
                            EnergyCard(
                                level: .low,
                                hours: $vm.lowHours,
                                progress: vm.progress(for: .low),
                                isOverAverage: vm.isOverAverage(level: .low),
                                disabled: vm.useDefaultSettings,
                                onChange: vm.updateLow
                            )
                        }
                    }
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.05)))
                    
                    // Appearance Preferences
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Appearance Preferences")
                            .font(AppFont.main(size: 18))
                            .foregroundColor(Color("PrimaryText"))
                        
                        Picker("", selection: Binding(
                            get: { vm.appearanceMode },
                            set: { vm.appearanceMode = $0 }
                        )) {
                            ForEach(AppearanceMode.allCases) { mode in
                                Text(mode.title).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.05)))
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            vm.bind(appState: appState)
        }
    }
}

private struct EnergyCard: View {
    let level: EnergyLevel
    @Binding var hours: Double
    let progress: Double
    let isOverAverage: Bool
    let disabled: Bool
    let onChange: (Double) -> Void
    
    private func imageName(for level: EnergyLevel) -> String {
        switch level {
        case .high: return "yansoonStatus/high"
        case .medium: return "yansoonStatus/medium"
        case .low: return "yansoonStatus/low"
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 8)
                    .frame(width: 70, height: 70)
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(isOverAverage ? Color("OffLimit") : Color("ProgressBar"),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(-90))
                Image(imageName(for: level))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(level.title)
                    .font(AppFont.main(size: 16))
                    .foregroundColor(Color("PrimaryText"))
                
                Stepper(value: Binding(
                    get: { hours },
                    set: { newVal in
                        let clamped = max(0, min(level.maxHours, newVal))
                        let stepped = (clamped * 2).rounded() / 2
                        hours = stepped
                        onChange(stepped)
                    }
                ), in: 0...level.maxHours, step: 0.5) {
                    Text("\(String(format: "%.1f", hours)) hrs")
                        .font(AppFont.main(size: 16))
                        .foregroundColor(isOverAverage ? Color("OffLimit") : Color("PrimaryButtons"))
                }
                .disabled(disabled)
                .opacity(disabled ? 0.5 : 1.0)
            }
            
            Spacer()
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white.opacity(0.05)))
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppStateViewModel())
        .preferredColorScheme(.dark)
}
