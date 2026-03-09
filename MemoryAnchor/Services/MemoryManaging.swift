import Foundation
import ARKit

protocol MemoryManaging {
    func saveMemory(
        id: UUID,
        anchorName: String,
        note: String,
        imageData: Data?,
        audioFileName: String?,
        transformData: Data
    ) async throws

    func fetchMemories() async throws -> [MemoryAnchorModel]
    func deleteMemory(id: UUID) async throws
    func saveWorldMap(data: Data) async throws
    func loadWorldMapData() async throws -> Data?
}
