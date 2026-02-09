//
//  SplashView.swift
//  yansoon
//
//  Created by Noor Alhassani on 16/08/1447 AH.
//

import SwiftUI

struct SplashView: View {
    // مدة السبللاش قابلة للتخصيص (تفيدنا في الـ Preview)
    let durationSeconds: Double
    
    @State private var isActive = false
    @State private var logoScale: CGFloat = 0.85      // البداية أصغر بقليل
    @State private var logoOpacity: Double = 0.0      // Fade-in
    @State private var rotation: Angle = .degrees(0)  // دوران الدخول
    @State private var pulse = false                  // نبض مستمر خفيف
    
    // مُهيّئ افتراضي بقيمة 2 ثانية للحالة العادية في التطبيق
    init(durationSeconds: Double = 2.0) {
        self.durationSeconds = durationSeconds
    }
    
    var body: some View {
        ZStack {
            // فقط خلفية الشاشة (بدون عناصر إضافية)
            Color("Background").ignoresSafeArea()
            
            // الشعار: تكبير + دوران + Fade-in + نبض خفيف
            Image("yansoonStatus/low") // إذا اسمك "low" فقط، بدّليها إلى "low"
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)
                // Scale مركّب: Scale الدخول + نبض مستمر
                .scaleEffect(logoScale * (pulse ? 1.03 : 0.97))
                .rotationEffect(rotation)
                .opacity(logoOpacity)
                .onAppear {
                    // Fade-in + Scale دخول
                    withAnimation(.easeOut(duration: 0.9)) {
                        logoOpacity = 1.0
                        logoScale = 1.0
                    }
                    // دوران لمرة واحدة أثناء الدخول
                    withAnimation(.easeInOut(duration: 1.2)) {
                        rotation = .degrees(360)
                    }
                    // نبض مستمر خفيف على نفس الشعار
                    withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                        pulse = true
                    }
                }
        }
        .onAppear {
            // الانتقال بعد المدة المحددة
            DispatchQueue.main.asyncAfter(deadline: .now() + durationSeconds) {
                isActive = true
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            // الوجهة الرئيسية بعد السبللاش
            MainFlowView()
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
