import SwiftUI
import SwiftData

struct SuccessView: View {
    @Binding var selectedTab: Int
    @Query(sort: \BrushSession.date, order: .reverse) private var sessions: [BrushSession]
    @AppStorage("userName") private var userName = ""

    private var currentStreak: Int {
        let cal = Calendar.current
        let uniqueDays = Set(sessions.map { cal.startOfDay(for: $0.date) })
        guard !uniqueDays.isEmpty else { return 0 }

        var checkDate = cal.startOfDay(for: Date())
        if !uniqueDays.contains(checkDate) {
            guard let yesterday = cal.date(byAdding: .day, value: -1, to: checkDate) else { return 0 }
            checkDate = yesterday
        }

        var streak = 0
        while uniqueDays.contains(checkDate) {
            streak += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prev
        }
        return streak
    }

    private var averageDuration: TimeInterval {
        let withBrushing = sessions.filter { $0.brushDuration > 0 }
        guard !withBrushing.isEmpty else { return 0 }
        return withBrushing.reduce(0.0) { $0 + $1.brushDuration } / Double(withBrushing.count)
    }

    private var mouthwashPercentage: Int {
        guard !sessions.isEmpty else { return 0 }
        return Int(round(Double(sessions.filter { $0.usedMouthwash }.count) / Double(sessions.count) * 100))
    }

    private var flossPercentage: Int {
        guard !sessions.isEmpty else { return 0 }
        return Int(round(Double(sessions.filter { $0.usedFloss }.count) / Double(sessions.count) * 100))
    }

    private var brushCount: Int { sessions.filter { $0.brushDuration > 0 }.count }
    private var mouthwashCount: Int { sessions.filter { $0.usedMouthwash }.count }
    private var flossCount: Int { sessions.filter { $0.usedFloss }.count }

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
                            .foregroundStyle(currentStreak > 0 ? Color.orange : Color.secondary.opacity(0.3))
                        Text(currentStreak > 0 ? "\(currentStreak) \(currentStreak == 1 ? "Tag" : "Tage")" : "Verloren")
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

            // Mundspülung % + Zahnseide %
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "drop.fill")
                            .foregroundStyle(mouthwashPercentage > 0 ? Color.blue : Color.secondary.opacity(0.3))
                        Text(sessions.isEmpty ? "–" : "\(mouthwashPercentage) %")
                            .font(.system(.title2, design: .rounded, weight: .bold))
                    }
                    Text("mit Mundspülung")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.and.down")
                            .foregroundStyle(flossPercentage > 0 ? Color.mint : Color.secondary.opacity(0.3))
                        Text(sessions.isEmpty ? "–" : "\(flossPercentage) %")
                            .font(.system(.title2, design: .rounded, weight: .bold))
                    }
                    Text("mit Zahnseide")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            // Gesamtübersicht
            HStack(spacing: 0) {
                VStack(spacing: 4) {
                    Text("\(brushCount)")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                    Text("Putzen")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                Divider()
                    .frame(height: 36)

                VStack(spacing: 4) {
                    Text("\(mouthwashCount)")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                    Text("Mundspülung")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                Divider()
                    .frame(height: 36)

                VStack(spacing: 4) {
                    Text("\(flossCount)")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                    Text("Zahnseide")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
    }
}
