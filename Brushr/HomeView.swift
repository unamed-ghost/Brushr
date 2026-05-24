import SwiftUI
import SwiftData

struct HomeView: View {
    @Binding var selectedTab: Int
    @Query(sort: \BrushSession.date, order: .reverse) private var sessions: [BrushSession]
    @AppStorage("userName") private var userName = ""

    private var averageDuration: TimeInterval {
        guard !sessions.isEmpty else { return 0 }
        return sessions.reduce(0.0) { $0 + $1.brushDuration } / Double(sessions.count)
    }

    private var recentSessions: [BrushSession] {
        Array(sessions.prefix(5))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(userName.isEmpty ? "Willkommen!" : "Hi \(userName)!")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Dein Lächeln wartet!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)

                Button {
                    selectedTab = 1
                } label: {
                    Text("Jetzt putzen")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 26)
                }
                .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 20)
                
                Button {
                    selectedTab = 1
                } label: {
                    Text("Jetzt putzen")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 26)
                }
                .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 20)

                VStack(spacing: 8) {
                    Text("Durchschnittliche Dauer")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(averageDuration > 0 ? formatBrushDuration(averageDuration) : "–")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundStyle(averageDuration > 0 ? .primary : .tertiary)
                        .monospacedDigit()
                    if sessions.count > 0 {
                        Text("aus \(sessions.count) \(sessions.count == 1 ? "Vorgang" : "Vorgängen")")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .glassEffect(in: RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 20)

                if !recentSessions.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Deine Aktivität")
                            .font(.headline)
                            .padding(.horizontal, 20)

                        VStack(spacing: 10) {
                            ForEach(recentSessions) { session in
                                HomeSessionRow(session: session)
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                }

                Spacer(minLength: 100)
            }
        }
    }
}

private struct HomeSessionRow: View {
    let session: BrushSession

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.date, format: .dateTime.weekday(.abbreviated).day().month(.abbreviated))
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(session.date, format: .dateTime.hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(formatBrushDuration(session.brushDuration))
                .font(.headline)
                .fontWeight(.bold)
                .monospacedDigit()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .glassEffect(in: RoundedRectangle(cornerRadius: 16))
    }
}
