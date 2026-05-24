import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house.fill", value: 0) {
                HomeView(selectedTab: $selectedTab)
            }
            Tab("Putzen", systemImage: "sparkles", value: 1) {
                BrushingView(selectedTab: $selectedTab)
            }
            Tab("Aktivität", systemImage: "calendar", value: 2) {
                HistoryView()
            }
            Tab("Einstellungen", systemImage: "gearshape.fill", value: 3) {
                SettingsView()
            }
        }
    }
}
