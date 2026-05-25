import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 1

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Erfolge", systemImage: "trophy.fill", value: 0) {
                SuccessView(selectedTab: $selectedTab)
            }
            Tab("Putzen", systemImage: "sparkles", value: 1) {
                BrushingView(selectedTab: $selectedTab)
            }
            Tab("Aktivität", systemImage: "calendar", value: 2) {
                HistoryView()
            }
            Tab("Du", systemImage: "person.fill", value: 3) {
                SettingsView()
            }
        }
    }
}
