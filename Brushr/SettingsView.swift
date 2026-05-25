import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("userName") private var userName = ""
    @AppStorage("brushDurationSeconds") private var brushDurationSeconds = 120.0
    @AppStorage("mouthwashDurationSeconds") private var mouthwashDurationSeconds = 30.0
    @Environment(\.modelContext) private var modelContext
    @Query private var sessions: [BrushSession]
    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Label("Name", systemImage: "person.fill")
                        Spacer()
                        TextField("Dein Name", text: $userName)
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(.secondary)
                    }
                }
                Section {
                    DurationRow(
                        label: "Putzen",
                        icon: "sparkles",
                        value: $brushDurationSeconds,
                        step: 15,
                        min: 30,
                        max: 600
                    )
                } footer: {
                    Text("Mindestens 2 Minuten gelten als ideal.")
                }

                Section {
                    DurationRow(
                        label: "Mundspülung",
                        icon: "drop.fill",
                        value: $mouthwashDurationSeconds,
                        step: 5,
                        min: 10,
                        max: 120
                    )
                } footer: {
                    Text("Die passende Dauer findest du auf der Verpackung deiner Mundspülung.")
                }
                
                Section {
                    Button(role: .destructive) {
                        showResetConfirmation = true
                    } label: {
                        Label("App zurücksetzen", systemImage: "trash")
                    }
                } footer: {
                    Text("Löscht alle Daten und Einstellungen unwiederruflich.")
                }

            }
            .safeAreaInset(edge: .bottom) {
                Text("Brushr 0.2 · Testversion in einer frühen Entwicklungsphase.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 8)
            }
            .confirmationDialog(
                "App zurücksetzen?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Alle Daten löschen", role: .destructive) {
                    for session in sessions { modelContext.delete(session) }
                    userName = ""
                    brushDurationSeconds = 120.0
                    mouthwashDurationSeconds = 30.0
                }
            } message: {
                Text("Alle Daten und Einstellungen werden gelöscht.")
            }
        }
    }
}

private struct DurationRow: View {
    let label: String
    let icon: String
    @Binding var value: Double
    let step: Double
    let min: Double
    let max: Double

    var body: some View {
        HStack {
            Label(label, systemImage: icon)

            Spacer()

            Text(formatBrushDuration(value))
                .font(.system(.body, design: .rounded))
                .fontWeight(.semibold)
                .monospacedDigit()
                .foregroundStyle(.teal)

            Stepper("", value: $value, in: min...max, step: step)
                .labelsHidden()
                .fixedSize()
        }
    }
}
