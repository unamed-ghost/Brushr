import SwiftUI
import SwiftData

struct AddEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("brushDurationSeconds") private var defaultBrushDuration = 120.0

    @State private var date = Date()
    @State private var didBrush = true
    @State private var brushDuration: Double = 120.0
    @State private var usedMouthwash = false
    @State private var usedFloss = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker(
                        "Datum & Uhrzeit",
                        selection: $date,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }

                Section {
                    Toggle(isOn: $didBrush) {
                        Label("Geputzt", systemImage: "sparkles")
                    }
                    .tint(.teal)

                    if didBrush {
                        HStack {
                            Label("Dauer", systemImage: "timer")
                            Spacer()
                            Text(formatBrushDuration(brushDuration))
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.semibold)
                                .monospacedDigit()
                                .foregroundStyle(.teal)
                            Stepper("", value: $brushDuration, in: 15...600, step: 15)
                                .labelsHidden()
                                .fixedSize()
                        }
                    }
                }

                Section {
                    Toggle(isOn: $usedMouthwash) {
                        Label("Mundspülung", systemImage: "drop.fill")
                    }
                    .tint(.blue)

                    Toggle(isOn: $usedFloss) {
                        Label("Zahnseide", systemImage: "arrow.up.and.down")
                    }
                    .tint(.mint)
                }
            }
            .navigationTitle("Nachtragen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Verwerfen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Sichern") { save() }
                        .fontWeight(.semibold)
                        .disabled(!didBrush && !usedMouthwash && !usedFloss)
                }
            }
            .onAppear {
                brushDuration = defaultBrushDuration
            }
        }
    }

    private func save() {
        let session = BrushSession(
            date: date,
            brushDuration: didBrush ? brushDuration : 0,
            usedMouthwash: usedMouthwash,
            usedFloss: usedFloss
        )
        modelContext.insert(session)
        dismiss()
    }
}
