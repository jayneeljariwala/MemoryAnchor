import SwiftUI
import CoreData

@main
struct MemoryAnchorsApp: App {
    private let dependencies = AppDependencies.live

    var body: some Scene {
        WindowGroup {
            ContentView(dependencies: dependencies)
                .environment(\.managedObjectContext, dependencies.persistenceController.container.viewContext)
        }
    }
}
