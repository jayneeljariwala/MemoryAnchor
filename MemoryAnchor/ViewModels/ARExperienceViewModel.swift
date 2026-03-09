import Foundation
import Combine
import RealityKit
import ARKit

@MainActor
final class ARExperienceViewModel: ObservableObject {
    @Published private(set) var memories: [MemoryAnchorModel] = []
    @Published var pendingPlacement: PendingMemoryPlacement?
    @Published var isCreationSheetPresented = false
    @Published var selectedMemory: MemoryAnchorModel?
    @Published var errorMessage: String?

    private let memoryManager: MemoryManaging
    private let arSessionManager: ARSessionManaging

    private(set) var restoredWorldMap: ARWorldMap?

    init(memoryManager: MemoryManaging, arSessionManager: ARSessionManaging) {
        self.memoryManager = memoryManager
        self.arSessionManager = arSessionManager
    }

    func bootstrap() async {
        await loadMemories()
        await loadWorldMap()
    }

    func loadMemories() async {
        do {
            memories = try await memoryManager.fetchMemories()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadWorldMap() async {
        do {
            guard let data = try await memoryManager.loadWorldMapData() else {
                restoredWorldMap = nil
                return
            }
            restoredWorldMap = try arSessionManager.decodeWorldMap(from: data)
        } catch {
            restoredWorldMap = nil
            errorMessage = error.localizedDescription
        }
    }

    func beginMemoryPlacement(anchorName: String, transform: simd_float4x4) {
        pendingPlacement = PendingMemoryPlacement(id: UUID(), anchorName: anchorName, transform: transform)
        isCreationSheetPresented = true
    }

    func cancelMemoryPlacement() {
        pendingPlacement = nil
        isCreationSheetPresented = false
    }

    func saveMemory(note: String, imageData: Data?, audioFileName: String?) async {
        guard let pendingPlacement else {
            return
        }

        do {
            let newMemoryID = UUID()
            let transformData = MatrixTransformCoder.encode(pendingPlacement.transform)

            try await memoryManager.saveMemory(
                id: newMemoryID,
                anchorName: pendingPlacement.anchorName,
                note: note,
                imageData: imageData,
                audioFileName: audioFileName,
                transformData: transformData
            )

            isCreationSheetPresented = false
            self.pendingPlacement = nil
            await loadMemories()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveWorldMap(using session: ARSession) async {
        do {
            let data = try await arSessionManager.encodeWorldMap(from: session)
            try await memoryManager.saveWorldMap(data: data)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func selectMemory(with anchorName: String) {
        selectedMemory = memories.first(where: { $0.anchorName == anchorName })
    }

    func clearSelection() {
        selectedMemory = nil
    }

    func deleteMemory(_ memory: MemoryAnchorModel) async {
        do {
            try await memoryManager.deleteMemory(id: memory.id)
            await loadMemories()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
