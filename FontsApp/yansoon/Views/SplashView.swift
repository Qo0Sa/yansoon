//
//  SplashView.swift
//  yansoon
//
//  Created by Noor Alhassani on 16/08/1447 AH.

import SwiftUI

struct SplashView: View {
    let durationSeconds: Double
    let onFinish: () -> Void

    @State private var logoScale: CGFloat = 0.85
    @State private var logoOpacity: Double = 0.0
    @State private var rotation: Angle = .degrees(0)
    @State private var pulse = false

    init(durationSeconds: Double = 2.0, onFinish: @escaping () -> Void) {
        self.durationSeconds = durationSeconds
        self.onFinish = onFinish
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

                    DispatchQueue.main.asyncAfter(deadline: .now() + durationSeconds) {
                        onFinish()
                    }
                }
        }
    }
}

