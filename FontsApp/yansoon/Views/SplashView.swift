//
//  SplashView.swift
//  yansoon
//
//  Created by Noor Alhassani on 16/08/1447 AH.


import SwiftUI

struct SplashView: View {
    // 1. Receive the AppState
    @EnvironmentObject var appState: AppStateViewModel
    
    let durationSeconds: Double
    
    @State private var isActive = false
    @State private var logoScale: CGFloat = 0.85
    @State private var logoOpacity: Double = 0.0
    @State private var rotation: Angle = .degrees(0)
    @State private var pulse = false
    
    init(durationSeconds: Double = 2.0) {
        self.durationSeconds = durationSeconds
    }
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            
            Image("yansoonStatus/low")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)
                .scaleEffect(logoScale * (pulse ? 1.03 : 0.97))
                .rotationEffect(rotation)
                .opacity(logoOpacity)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.9)) {
                        logoOpacity = 1.0
                        logoScale = 1.0
                    }
                    withAnimation(.easeInOut(duration: 1.2)) {
                        rotation = .degrees(360)
                    }
                    withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                        pulse = true
                    }
                }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + durationSeconds) {
                isActive = true
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            // 2. Pass AppState to the MainFlowView
            MainFlowView()
                .environmentObject(appState)
        }
    }
}
#Preview("Splash only (60s)") {
    // برفيو لمدة دقيقة (60 ثانية) لعرض التأثيرات على الشعار فقط
    NavigationStack {
        SplashView(durationSeconds: 60.0)
    }
    .preferredColorScheme(.dark)
}
