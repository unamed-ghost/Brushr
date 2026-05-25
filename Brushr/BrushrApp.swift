import SwiftUI
import SwiftData

@main
struct BrushrApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([BrushSession.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            let fm = FileManager.default
            if let appSupport = try? fm.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            ), let files = try? fm.contentsOfDirectory(at: appSupport, includingPropertiesForKeys: nil) {
                for file in files where file.lastPathComponent.hasPrefix("default.store") {
                    try? fm.removeItem(at: file)
                }
            }
            do {
                return try ModelContainer(for: schema, configurations: [config])
            } catch let retryError {
                fatalError("Could not create ModelContainer: \(retryError)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
