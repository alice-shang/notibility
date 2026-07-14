import SwiftUI

private struct TimerWedge: Shape {
    var fraction: CGFloat // 0...1 remaining

    var animatableData: CGFloat {
        get { fraction }
        set { fraction = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(-90),
            endAngle: .degrees(-90 + 360 * fraction),
            clockwise: false
        )
        path.closeSubpath()
        return path
    }
}

private enum TimerPhase {
    case work, rest

    var label: String {
        switch self {
        case .work: return "Work"
        case .rest: return "Rest"
        }
    }

    var tint: Color {
        switch self {
        case .work: return .accentColor
        case .rest: return .green
        }
    }
}

private struct AnalogDialView: View {
    let fraction: CGFloat
    let label: String
    let tint: Color
    let justFinished: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(.regularMaterial)
            Circle()
                .stroke(.secondary.opacity(0.25), lineWidth: 1)

            TimerWedge(fraction: fraction)
                .fill(justFinished ? Color.red.opacity(0.55) : tint.opacity(0.35))
                .padding(3)

            ForEach(0..<12) { i in
                Rectangle()
                    .fill(.secondary.opacity(0.4))
                    .frame(width: 1, height: 3)
                    .offset(y: -19)
                    .rotationEffect(.degrees(Double(i) * 30))
            }

            Text(label)
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .shadow(color: .black.opacity(0.12), radius: 3, y: 1)
        .scaleEffect(justFinished ? 1.15 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: justFinished)
        .contentShape(Circle())
    }
}

private struct TimerSetterPopover: View {
    @State private var loops: Int
    @Binding var isPresented: Bool
    let onSet: (Double, Int) -> Void

    private let presets: [(label: String, seconds: Double)] = [
        ("10s", 10),
        ("5m", 5 * 60),
        ("10m", 10 * 60),
        ("15m", 15 * 60),
        ("25m", 25 * 60),
        ("30m", 30 * 60),
        ("45m", 45 * 60),
        ("60m", 60 * 60)
    ]

    init(currentSeconds: Double, currentLoops: Int, isPresented: Binding<Bool>, onSet: @escaping (Double, Int) -> Void) {
        _loops = State(initialValue: currentLoops)
        _isPresented = isPresented
        self.onSet = onSet
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Set Timer")
                .font(.headline)

            Divider()

            Stepper("\(loops) loop\(loops == 1 ? "" : "s")", value: $loops, in: 1...20)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 6) {
                ForEach(presets, id: \.label) { preset in
                    Button(preset.label) {
                        onSet(preset.seconds, loops)
                        isPresented = false
                    }
                    .buttonStyle(.bordered)
                    .tint(.accentColor)
                    .font(.caption)
                }
            }
        }
        .padding(16)
        .frame(width: 240)
    }
}

struct AnalogTimerView: View {
    private let diameter: CGFloat = 46

    var onPhaseFlash: (String, Color) -> Void = { _, _ in }

    @State private var phase: TimerPhase = .work
    @State private var workSeconds: Double = 25 * 60
    @State private var totalSeconds: Double = 25 * 60
    @State private var remainingSeconds: Double = 25 * 60
    @State private var isRunning = false
    @State private var justFinished = false
    @State private var showingSetter = false
    @State private var totalLoops = 1
    @State private var currentLoop = 1
    @State private var isHoveringPlay = false

    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var fraction: CGFloat {
        guard totalSeconds > 0 else { return 0 }
        return CGFloat(remainingSeconds / totalSeconds)
    }

    private var label: String {
        let s = max(0, Int(remainingSeconds.rounded()))
        return String(format: "%d:%02d", s / 60, s % 60)
    }

    private var phaseCaption: String {
        totalLoops > 1 ? "\(phase.label) \(currentLoop)/\(totalLoops)" : phase.label
    }

    var body: some View {
        VStack(spacing: 2) {
            Text(phaseCaption)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(phase.tint)

            HStack(spacing: 8) {
                AnalogDialView(fraction: fraction, label: label, tint: phase.tint, justFinished: justFinished)
                    .frame(width: diameter, height: diameter)
                    .onTapGesture { showingSetter = true }
                    .popover(isPresented: $showingSetter) {
                        TimerSetterPopover(
                            currentSeconds: workSeconds,
                            currentLoops: totalLoops,
                            isPresented: $showingSetter
                        ) { seconds, loops in
                            setDuration(seconds: seconds, loops: loops)
                        }
                    }
                    .contextMenu {
                        Button("Reset") { reset() }
                    }

                Button(action: toggleRunning) {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(phase.tint)
                        .frame(width: 22, height: 22)
                        .background(.regularMaterial, in: Circle())
                        .shadow(color: .black.opacity(isHoveringPlay ? 0.16 : 0.08), radius: isHoveringPlay ? 4 : 2, y: 1)
                        .scaleEffect(isHoveringPlay ? 1.08 : 1)
                }
                .buttonStyle(.plain)
                .disabled(remainingSeconds <= 0)
                .onHover { hovering in
                    withAnimation(.easeOut(duration: 0.15)) { isHoveringPlay = hovering }
                }
            }
        }
        .onReceive(ticker) { _ in
            guard isRunning else { return }
            if remainingSeconds > 0 {
                remainingSeconds -= 1
                if remainingSeconds <= 0 {
                    remainingSeconds = 0
                    handlePhaseFinished()
                }
            }
        }
    }

    private func handlePhaseFinished() {
        pulseFinished()
        switch phase {
        case .work:
            phase = .rest
            totalSeconds = workSeconds / 3
            remainingSeconds = totalSeconds
            isRunning = true
            onPhaseFlash(TimerPhase.rest.label, TimerPhase.rest.tint)
        case .rest:
            let continuing = currentLoop < totalLoops
            if continuing {
                currentLoop += 1
            } else {
                currentLoop = 1
            }
            phase = .work
            totalSeconds = workSeconds
            remainingSeconds = totalSeconds
            isRunning = continuing
            onPhaseFlash(TimerPhase.work.label, TimerPhase.work.tint)
        }
    }

    private func setDuration(seconds: Double, loops: Int) {
        phase = .work
        workSeconds = seconds
        totalSeconds = workSeconds
        remainingSeconds = totalSeconds
        totalLoops = loops
        currentLoop = 1
        isRunning = false
        justFinished = false
    }

    private func toggleRunning() {
        guard remainingSeconds > 0 else { return }
        isRunning.toggle()
    }

    private func reset() {
        phase = .work
        isRunning = false
        justFinished = false
        workSeconds = 25 * 60
        totalSeconds = workSeconds
        remainingSeconds = totalSeconds
        totalLoops = 1
        currentLoop = 1
    }

    private func pulseFinished() {
        justFinished = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            justFinished = false
        }
    }
}
