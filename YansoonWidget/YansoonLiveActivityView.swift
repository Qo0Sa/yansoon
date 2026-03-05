//
//  YansoonLiveActivityView.swift
//  YansoonWidgetExtension
//
//  ⚠️ This file belongs ONLY in the Widget Extension target.
//

import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Yansoon Logo Mark (pixel-perfect from SVG paths, no asset dependency)
private struct YansoonMark: View {
    var size: CGFloat = 20

    var body: some View {
        Canvas { ctx, canvasSize in
            let s = canvasSize.width
            func pt(_ x: Double, _ y: Double) -> CGPoint {
                CGPoint(x: x / 211.0 * s, y: y / 211.0 * s)
            }
            do {
                var p = Path()
                p.move(to: pt(97.7654, 114.511))
                p.addLine(to: pt(68.5285, 144.596))
                p.addLine(to: pt(28.7727, 177.287))
                p.addLine(to: pt(63.4237, 134.659))
                p.closeSubpath()
                ctx.fill(p, with: .color(Color(red: 0.980, green: 0.592, blue: 0.012)))
            }
            do {
                var p = Path()
                p.move(to: pt(108.771, 85.5385))
                p.addLine(to: pt(86.9369, 11.0001))
                p.addLine(to: pt(129.322, 2.48274))
                p.closeSubpath()
                ctx.fill(p, with: .color(Color(red: 0.875, green: 0.384, blue: 0.008)))
            }
            do {
                var p = Path()
                p.move(to: pt(115.246, 90.6528))
                p.addLine(to: pt(124.041, 52.0766))
                p.addLine(to: pt(187.177, 30.0849))
                p.addLine(to: pt(151.212, 60.3689))
                p.closeSubpath()
                ctx.fill(p, with: .color(Color(red: 0.835, green: 0.329, blue: 0.004)))
            }
            do {
                var p = Path()
                p.move(to: pt(115.246, 90.6528))
                p.addLine(to: pt(151.908, 70.6213))
                p.addLine(to: pt(187.177, 30.0849))
                p.addLine(to: pt(151.212, 60.3689))
                p.closeSubpath()
                ctx.fill(p, with: .color(Color(red: 0.976, green: 0.569, blue: 0.008)))
            }
            do {
                var p = Path()
                p.move(to: pt(157.383, 69.5187))
                p.addLine(to: pt(198.625, 80.4003))
                p.addLine(to: pt(122.516, 96.9619))
                p.closeSubpath()
                ctx.fill(p, with: .color(Color(red: 0.725, green: 0.247, blue: 0.008)))
            }
            do {
                var p = Path()
                p.move(to: pt(211, 84.0282))
                p.addLine(to: pt(203.111, 125.353))
                p.addLine(to: pt(126.383, 104.06))
                p.closeSubpath()
                ctx.fill(p, with: .color(Color(red: 0.882, green: 0.408, blue: 0.008)))
            }
            do {
                var p = Path()
                p.move(to: pt(163.355, 123.303))
                p.addLine(to: pt(185.167, 179.927))
                p.addLine(to: pt(118.804, 110.684))
                p.closeSubpath()
                ctx.fill(p, with: .color(Color(red: 0.910, green: 0.459, blue: 0.008)))
            }
            do {
                var p = Path()
                p.move(to: pt(119.577, 111))
                p.addLine(to: pt(185.166, 179.811))
                p.addLine(to: pt(147.886, 150.274))
                p.closeSubpath()
                ctx.fill(p, with: .color(Color(red: 0.984, green: 0.600, blue: 0.012)))
            }
            do {
                var p = Path()
                p.move(to: pt(105.809, 117.309))
                p.addLine(to: pt(128.24, 193.65))
                p.addLine(to: pt(81.5227, 211))
                p.closeSubpath()
                ctx.fill(p, with: .color(Color(red: 0.886, green: 0.404, blue: 0.008)))
            }
            do {
                var p = Path()
                p.move(to: pt(112.306, 116.047))
                p.addLine(to: pt(142.781, 151.694))
                p.addLine(to: pt(130.251, 186.867))
                p.closeSubpath()
                ctx.fill(p, with: .color(Color(red: 0.718, green: 0.235, blue: 0.008)))
            }
            do {
                var p = Path()
                p.move(to: pt(0, 78.0343))
                p.addLine(to: pt(89.8761, 99.6432))
                p.addLine(to: pt(10.3644, 119.99))
                p.closeSubpath()
                ctx.fill(p, with: .color(Color(red: 0.910, green: 0.459, blue: 0.008)))
            }
            do {
                var p = Path()
                p.move(to: pt(16.3974, 123.618))
                p.addLine(to: pt(91.8243, 107.53))
                p.addLine(to: pt(56.1532, 136.709))
                p.closeSubpath()
                ctx.fill(p, with: .color(Color(red: 0.722, green: 0.243, blue: 0.012)))
            }
            do {
                var p = Path()
                p.move(to: pt(83.0697, 19.6747))
                p.addLine(to: pt(102.251, 88.9177))
                p.addLine(to: pt(71.6224, 53.5864))
                p.closeSubpath()
                ctx.fill(p, with: .color(Color(red: 0.729, green: 0.239, blue: 0.008)))
            }
            do {
                var p = Path()
                p.move(to: pt(97.9201, 114.312))
                p.addLine(to: pt(88.1745, 156.899))
                p.addLine(to: pt(28.154, 177.877))
                p.closeSubpath()
                ctx.fill(p, with: .color(Color(red: 0.847, green: 0.341, blue: 0.004)))
            }
            do {
                var p = Path()
                p.move(to: pt(30.165, 30.2426))
                p.addLine(to: pt(94.981, 93.6496))
                p.addLine(to: pt(49.3469, 79.9272))
                p.closeSubpath()
                ctx.fill(p, with: .color(Color(red: 0.933, green: 0.490, blue: 0.004)))
            }
            do {
                var p = Path()
                p.move(to: pt(66.2083, 54.2587))
                p.addLine(to: pt(95.1357, 94.0645))
                p.addLine(to: pt(59.7112, 62.1038))
                p.addLine(to: pt(30.3197, 30.2839))
                p.closeSubpath()
                ctx.fill(p, with: .color(Color(red: 0.980, green: 0.596, blue: 0.012)))
            }
            do {
                let ex = 106.738 / 211.0 * s
                let ey = 102.167 / 211.0 * s
                let rx = 8.97214 / 211.0 * s
                let ry = 9.14828 / 211.0 * s
                let dotPath = Path(ellipseIn: CGRect(x: ex-rx, y: ey-ry, width: rx*2, height: ry*2))
                ctx.fill(dotPath, with: .color(Color(red: 0.882, green: 0.392, blue: 0.004)))
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Live Activity Widget

struct YansoonLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: YansoonActivityAttributes.self) { context in

            // ── Lock Screen / StandBy banner ──────────────────────────────
            // State is pushed by ViewModel — no TimelineView needed
            LockScreenView(context: context)

        } dynamicIsland: { context in
            DynamicIsland {
                // ── Dynamic Island expanded ───────────────────────────────
                DynamicIslandExpandedRegion(.leading) {
                    ExpandedLeadingView(context: context)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    ExpandedTrailingView(context: context)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedBottomView(context: context)
                }
            } compactLeading: {
                // ── Dynamic Island compact ────────────────────────────────
                ZStack {
                    YansoonMark(size: 20)
                    if context.state.isOverrun {
                        Circle()
                            .stroke(Color.red, lineWidth: 1.5)
                            .frame(width: 22, height: 22)
                    }
                }

            } compactTrailing: {
                TimerLabel(context: context, style: .compact)

            } minimal: {
                ZStack {
                    YansoonMark(size: 16)
                    if context.state.isOverrun {
                        Circle()
                            .stroke(Color.red, lineWidth: 1)
                            .frame(width: 18, height: 18)
                    }
                }
            }
            .widgetURL(URL(string: "yansoon://timer"))
            .keylineTint(context.state.isOverrun ? .red : .orange)
        }
    }
}

// MARK: - Lock Screen Banner

private struct LockScreenView: View {
    let context: ActivityViewContext<YansoonActivityAttributes>

    private var isOverrun: Bool { context.state.isOverrun }
    private var isPaused:  Bool { context.state.isPaused  }

    private var accentColor: Color {
        isOverrun ? .red : Color(red: 0.98, green: 0.57, blue: 0.01)
    }

    private var statusText: String {
        isOverrun ? "Time exceeded" :
        isPaused  ? "Paused"        : "In progress"
    }

    var body: some View {
        HStack(spacing: 14) {

            // Logo inside progress ring
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 3)
                Circle()
                    .trim(from: 0, to: isOverrun ? 1.0 : context.state.progress)
                    .stroke(accentColor,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                YansoonMark(size: 28)
            }
            .frame(width: 46, height: 46)

            // Task info
            VStack(alignment: .leading, spacing: 2) {
                Text(context.attributes.taskTitle)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(statusText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isOverrun ? .red : .white.opacity(0.55))
            }

            Spacer()

            // Timer — live when running, frozen when paused or exceeded
            VStack(alignment: .trailing, spacing: 1) {
                TimerLabel(context: context, style: .lockScreen,
                           overrideOverrun: isOverrun, overridePaused: isPaused)
                Text(isOverrun ? "exceeded" : "elapsed")
                    .font(.system(size: 10))
                    .foregroundStyle(isOverrun ? .red.opacity(0.7) : .white.opacity(0.4))
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(.black)
    }
}

// MARK: - Dynamic Island Expanded Regions

private struct ExpandedLeadingView: View {
    let context: ActivityViewContext<YansoonActivityAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(context.attributes.taskTitle)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
            Text(context.state.isOverrun ? "Time exceeded" :
                 context.state.isPaused  ? "Paused"        : "Running")
                .font(.system(size: 11))
                .foregroundStyle(context.state.isOverrun ? .red : .white.opacity(0.6))
        }
        .padding(.leading, 4)
    }
}

private struct ExpandedTrailingView: View {
    let context: ActivityViewContext<YansoonActivityAttributes>

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.15), lineWidth: 3)
            Circle()
                .trim(from: 0, to: context.state.progress)
                .stroke(
                    context.state.isOverrun ? Color.red : Color.orange,
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 36, height: 36)
        .padding(.trailing, 4)
    }
}

private struct ExpandedBottomView: View {
    let context: ActivityViewContext<YansoonActivityAttributes>

    var body: some View {
        HStack {
            Spacer()
            TimerLabel(context: context, style: .expanded)
            Spacer()
        }
        .padding(.bottom, 4)
    }
}

// MARK: - Timer Label

enum TimerLabelStyle { case compact, lockScreen, expanded }

private struct TimerLabel: View {
    let context: ActivityViewContext<YansoonActivityAttributes>
    let style: TimerLabelStyle
    var overrideOverrun: Bool = false
    var overridePaused:  Bool = false

    private var isOverrun: Bool { context.state.isOverrun || overrideOverrun }
    private var isPaused:  Bool { context.state.isPaused  || overridePaused  }

    private var fontSize: CGFloat {
        switch style {
        case .compact:    return 13
        case .lockScreen: return 22
        case .expanded:   return 17
        }
    }

    var body: some View {
        Group {
            if isPaused {
                // Frozen when paused (or overrun+paused)
                Text(formattedElapsed)
            } else {
                // Live ticking — even when overrun, timer keeps counting up
                Text(context.state.timerStartDate, style: .timer)
                    .foregroundStyle(isOverrun ? .red : .white)
            }
        }
        .font(.system(size: fontSize, weight: .semibold).monospacedDigit())
        .foregroundStyle(isOverrun ? .red : .white)
    }

    private var formattedElapsed: String {
        // When auto-overrun (app was suspended), freeze display at estimated time
        let s = (isOverrun && !context.state.isOverrun)
            ? context.attributes.estimatedSeconds
            : context.state.elapsedSeconds
        let m = s / 60
        let sec = s % 60
        if m >= 60 {
            return String(format: "%d:%02d:%02d", m / 60, m % 60, sec)
        }
        return String(format: "%02d:%02d", m, sec)
    }
}

// MARK: - Widget Bundle

@main
struct YansoonWidgetBundle: WidgetBundle {
    var body: some Widget {
        YansoonLiveActivity()
    }
}
