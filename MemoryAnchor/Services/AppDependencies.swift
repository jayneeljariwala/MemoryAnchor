import Foundation
import CoreData

struct AppDependencies {
    let persistenceController: PersistenceController
    let memoryManager: MemoryManaging
    let arSessionManager: ARSessionManaging

    static let live: AppDependencies = {
        let persistenceController = PersistenceController.shared
        return AppDependencies(
            persistenceController: persistenceController,
            memoryManager: MemoryManager(container: persistenceController.container),
            arSessionManager: ARSessionManager()
        )
    }()
}
