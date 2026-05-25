import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \BrushSession.date, order: .reverse) private var sessions: [BrushSession]
    @Environment(\.modelContext) private var modelContext

    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())

    private var availableYears: [Int] {
        let years = Set(sessions.map { Calendar.current.component(.year, from: $0.date) })
        let sorted = years.sorted(by: >)
        return sorted.isEmpty ? [selectedYear] : sorted
    }

    private var filteredSessions: [BrushSession] {
        let cal = Calendar.current
        return sessions.filter {
            cal.component(.month, from: $0.date) == selectedMonth &&
            cal.component(.year, from: $0.date) == selectedYear
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if !filteredSessions.isEmpty {
                    ForEach(filteredSessions) { session in
                        HistoryRow(session: session)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                    .onDelete(perform: deleteSessions)
                } else {
                    ContentUnavailableView(
                        "Nichts los hier.",
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text("Noch nicht geputzt?")
                    )
                    .listRowBackground(Color.clear)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    monthYearFilter
                }
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
        }
    }

    private var monthYearFilter: some View {
        HStack(spacing: 8) {
            Picker("Monat", selection: $selectedMonth) {
                ForEach(1...12, id: \.self) { month in
                    Text(monthName(month)).tag(month)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()

            Picker("Jahr", selection: $selectedYear) {
                ForEach(availableYears, id: \.self) { year in
                    Text(String(year)).tag(year)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
        }
    }

    private func deleteSessions(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredSessions[index])
        }
    }

    private func monthName(_ month: Int) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "de_DE")
        return fmt.monthSymbols[month - 1].capitalized
    }
}

private struct HistoryRow: View {
    let session: BrushSession

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(session.date, format: .dateTime.weekday(.wide).day().month(.wide))
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(session.date, format: .dateTime.hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 8) {
                if session.usedMouthwash {
                    Image(systemName: "drop.fill")
                        .foregroundStyle(Color.blue)
                }
                if session.usedFloss {
                    Image(systemName: "arrow.up.and.down")
                        .foregroundStyle(Color.mint)
                }
            }
            .font(.subheadline)

            if session.brushDuration > 0 {
                Text(formatBrushDuration(session.brushDuration))
                    .font(.headline)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .foregroundStyle(.teal)
            }
        }
        .padding(.vertical, 4)
    }
}
