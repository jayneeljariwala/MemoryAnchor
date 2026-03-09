import Foundation
import CoreData

final class MemoryManager: MemoryManaging {
    private enum Entity {
        static let memory = "MemoryRecord"
        static let worldMap = "WorldMapRecord"
    }

    private enum Field {
        static let id = "id"
        static let anchorName = "anchorName"
        static let note = "note"
        static let imageData = "imageData"
        static let audioFileName = "audioFileName"
        static let createdAt = "createdAt"
        static let transformData = "transformData"

        static let worldMapData = "worldMapData"
        static let savedAt = "savedAt"
    }

    private let container: NSPersistentContainer

    init(container: NSPersistentContainer) {
        self.container = container
    }

    func saveMemory(
        id: UUID,
        anchorName: String,
        note: String,
        imageData: Data?,
        audioFileName: String?,
        transformData: Data
    ) async throws {
        let context = container.newBackgroundContext()

        try await context.perform {
            let object = NSEntityDescription.insertNewObject(forEntityName: Entity.memory, into: context)
            object.setValue(id, forKey: Field.id)
            object.setValue(anchorName, forKey: Field.anchorName)
            object.setValue(note, forKey: Field.note)
            object.setValue(imageData, forKey: Field.imageData)
            object.setValue(audioFileName, forKey: Field.audioFileName)
            object.setValue(Date(), forKey: Field.createdAt)
            object.setValue(transformData, forKey: Field.transformData)
            try context.save()
        }
    }

    func fetchMemories() async throws -> [MemoryAnchorModel] {
        let context = container.newBackgroundContext()

        return try await context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: Entity.memory)
            request.sortDescriptors = [NSSortDescriptor(key: Field.createdAt, ascending: false)]

            let records = try context.fetch(request)
            return records.compactMap { record in
                guard
                    let id = record.value(forKey: Field.id) as? UUID,
                    let anchorName = record.value(forKey: Field.anchorName) as? String,
                    let note = record.value(forKey: Field.note) as? String,
                    let createdAt = record.value(forKey: Field.createdAt) as? Date,
                    let transformData = record.value(forKey: Field.transformData) as? Data
                else {
                    return nil
                }

                return MemoryAnchorModel(
                    id: id,
                    anchorName: anchorName,
                    note: note,
                    imageData: record.value(forKey: Field.imageData) as? Data,
                    audioFileName: record.value(forKey: Field.audioFileName) as? String,
                    createdAt: createdAt,
                    transformData: transformData
                )
            }
        }
    }

    func deleteMemory(id: UUID) async throws {
        let context = container.newBackgroundContext()

        try await context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: Entity.memory)
            request.predicate = NSPredicate(format: "%K == %@", Field.id, id as CVarArg)
            request.fetchLimit = 1

            if let object = try context.fetch(request).first {
                context.delete(object)
                try context.save()
            }
        }
    }

    func saveWorldMap(data: Data) async throws {
        let context = container.newBackgroundContext()

        try await context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: Entity.worldMap)
            request.fetchLimit = 1

            let object = try context.fetch(request).first
                ?? NSEntityDescription.insertNewObject(forEntityName: Entity.worldMap, into: context)

            object.setValue(UUID(), forKey: Field.id)
            object.setValue(data, forKey: Field.worldMapData)
            object.setValue(Date(), forKey: Field.savedAt)
            try context.save()
        }
    }

    func loadWorldMapData() async throws -> Data? {
        let context = container.newBackgroundContext()

        return try await context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: Entity.worldMap)
            request.fetchLimit = 1
            request.sortDescriptors = [NSSortDescriptor(key: Field.savedAt, ascending: false)]

            return try context.fetch(request).first?.value(forKey: Field.worldMapData) as? Data
        }
    }
}
