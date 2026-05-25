import SwiftUI
import SwiftData

struct SuccessView: View {
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
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(userName.isEmpty ? "Du machst das toll!" : "Du machst das toll, \(userName)!")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 20)

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                        Text("3 Tage")
                            .font(.system(.title2, design: .rounded, weight: .bold))
                    }
                    Text("Streak")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 6) {
                    Text(averageDuration > 0 ? formatBrushDuration(averageDuration) : "–")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .monospacedDigit()
                        .foregroundStyle(averageDuration > 0 ? .primary : .tertiary)
                    Text(sessions.isEmpty
                         ? "Noch keine Daten"
                         : "⌀ aus \(sessions.count) \(sessions.count == 1 ? "Vorgang" : "Vorgängen")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }
}
