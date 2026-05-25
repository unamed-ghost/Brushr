import SwiftUI
import SwiftData


private enum BrushStep: Equatable {
    case ready
    case brushing
    case mouthwashQuestion
    case mouthwashing
    case flossQuestion
}

struct BrushingView: View {
    @Binding var selectedTab: Int
    @Environment(\.modelContext) private var modelContext
    @AppStorage("brushDurationSeconds") private var brushDurationSeconds = 120.0
    @AppStorage("mouthwashDurationSeconds") private var mouthwashDurationSeconds = 30.0
    @AppStorage("userName") private var userName = ""

    @State private var step: BrushStep = .ready
    @State private var timeRemaining: Double = 0
    @State private var totalTime: Double = 0
    @State private var timerTask: Task<Void, Never>?
    @State private var sessionStartDate = Date()
    @State private var brushActualDuration: TimeInterval = 0
    @State private var usedMouthwash = false

    var body: some View {
        Group {
            switch step {
            case .ready:
                ReadyView(
                    configuredDuration: brushDurationSeconds,
                    userName: userName,
                    onStart: startBrushing
                )
            case .brushing:
                TimerFlowView(
                    timeRemaining: timeRemaining,
                    totalTime: totalTime,
                    title: "Zähne putzen",
                    onCancel: cancelSession,
                    onSkip: skipBrushing
                )
            case .mouthwashQuestion:
                QuestionView(
                    question: "Möchtest du die\nMundspülung nutzen?",
                    yesLabel: "Ja",
                    noLabel: "Nein",
                    onYes: startMouthwashing,
                    onNo: showFlossQuestion
                )
            case .mouthwashing:
                TimerFlowView(
                    timeRemaining: timeRemaining,
                    totalTime: totalTime,
                    title: "Mundspülung",
                    onCancel: cancelSession,
                    onSkip: skipMouthwashing
                )
            case .flossQuestion:
                QuestionView(
                    question: "Hast du Zahnseide\ngenutzt?",
                    yesLabel: "Ja",
                    noLabel: "Nein",
                    onYes: { saveSession(usedFloss: true) },
                    onNo: { saveSession(usedFloss: false) }
                )
            }
        }
        .animation(.easeInOut(duration: 0.35), value: step)
    }

    private func startBrushing() {
        totalTime = brushDurationSeconds
        timeRemaining = brushDurationSeconds
        sessionStartDate = Date()
        step = .brushing
        startTimer { skipBrushing() }
    }

    private func skipBrushing() {
        brushActualDuration = totalTime - timeRemaining
        stopTimer()
        usedMouthwash = false
        step = .mouthwashQuestion
    }

    private func startMouthwashing() {
        usedMouthwash = true
        totalTime = mouthwashDurationSeconds
        timeRemaining = mouthwashDurationSeconds
        step = .mouthwashing
        startTimer { skipMouthwashing() }
    }

    private func skipMouthwashing() {
        stopTimer()
        step = .flossQuestion
    }

    private func showFlossQuestion() {
        step = .flossQuestion
    }

    private func saveSession(usedFloss: Bool) {
        let session = BrushSession(
            date: sessionStartDate,
            brushDuration: brushActualDuration,
            usedMouthwash: usedMouthwash,
            usedFloss: usedFloss
        )
        modelContext.insert(session)
        resetToReady()
        selectedTab = 0
    }

    private func cancelSession() {
        stopTimer()
        resetToReady()
        selectedTab = 0
    }

    private func resetToReady() {
        step = .ready
        timeRemaining = 0
        totalTime = 0
        brushActualDuration = 0
        usedMouthwash = false
    }

    private func startTimer(onComplete: @escaping () -> Void) {
        timerTask?.cancel()
        timerTask = Task {
            while timeRemaining > 0 && !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                timeRemaining = max(0, timeRemaining - 1)
            }
            guard !Task.isCancelled else { return }
            onComplete()
        }
    }

    private func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }
}

private struct ReadyView: View {
    let configuredDuration: Double
    let userName: String
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 48) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.system(size: 52, weight: .light))
                    .foregroundStyle(.tint)

                Text(userName.isEmpty ? "Bereit?" : "Bereit, \(userName)?")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(formatBrushDuration(configuredDuration))
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.15), lineWidth: 12)

                Circle()
                    .trim(from: 0, to: 1)
                    .stroke(Color.teal.opacity(0.3), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 220, height: 220)

            Button("Putzen starten", action: onStart)
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.horizontal, 48)
                .padding(.vertical, 16)
                .glassEffect(.regular.interactive(), in: Capsule())

            Spacer()
        }
        .padding()
    }
}

private struct TimerFlowView: View {
    let timeRemaining: Double
    let totalTime: Double
    let title: String
    let onCancel: () -> Void
    let onSkip: () -> Void

    private var progress: Double {
        guard totalTime > 0 else { return 0 }
        return timeRemaining / totalTime
    }

    var body: some View {
        VStack(spacing: 48) {
            Spacer()

            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.15), lineWidth: 14)

                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(
                        Color.teal,
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)

                Text(formatBrushDuration(timeRemaining))
                    .font(.system(size: 68, weight: .bold, design: .rounded))
                    .monospacedDigit()
            }
            .frame(width: 260, height: 260)

            HStack(spacing: 20) {
                Button("Abbrechen", action: onCancel)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .glassEffect(.regular.interactive(), in: Capsule())

                Button("Überspringen", action: onSkip)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .glassEffect(.regular.interactive(), in: Capsule())
            }

            Spacer()
        }
        .padding()
    }
}

private struct QuestionView: View {
    let question: String
    let yesLabel: String
    let noLabel: String
    let onYes: () -> Void
    let onNo: () -> Void

    var body: some View {
        VStack(spacing: 52) {
            Spacer()

            Text(question)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            HStack(spacing: 20) {
                Button(noLabel, action: onNo)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .frame(width: 130, height: 64)
                    .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 20))

                Button(yesLabel, action: onYes)
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(width: 130, height: 64)
                    .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 20))
            }

            Spacer()
        }
        .padding()
    }
}
