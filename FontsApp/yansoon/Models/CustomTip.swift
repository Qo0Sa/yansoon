//
//  CustomTip.swift
//  yansoon
//
//  Created by Sarah on 07/09/1447 AH.
//


import SwiftUI

struct CustomTipModifier: ViewModifier {
    @Binding var show: Bool
    let text: String

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                if show {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.yellow)

                            Text("Tip")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Color("SecondaryText"))
                        }

                        Text(text)
                            .font(AppFont.main(size: 13))
                            .foregroundColor(Color("PrimaryText"))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(3)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .frame(width: 180, alignment: .leading)
                    .background {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                    }
                    .overlay(alignment: .topTrailing) {
                        // Arrow pointing up to gear icon
                        Triangle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 12, height: 7)
                            .offset(x: -10, y: -6)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    }
                    .offset(x: 0, y: 40)
                    .zIndex(999)
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 0.9, anchor: .topTrailing)
                                .combined(with: .opacity),
                            removal: .opacity
                        )
                    )
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: show)
                }
            }
    }
}

// Arrow shape for the tooltip pointer
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

extension View {
    func customTip(show: Binding<Bool>, text: String) -> some View {
        modifier(CustomTipModifier(show: show, text: text))
    }
}
