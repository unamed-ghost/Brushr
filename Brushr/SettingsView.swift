import SwiftUI

struct SettingsView: View {
    @AppStorage("userName") private var userName = ""
    @AppStorage("brushDurationSeconds") private var brushDurationSeconds = 120.0
    @AppStorage("mouthwashDurationSeconds") private var mouthwashDurationSeconds = 30.0

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
                } footer: {
                    Text("Brushr 0.1.2\nTestversion in einer frühen Entwicklungsphase.\nEs können Fehler auftreten.")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                }
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
