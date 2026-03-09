import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    let memories: [MemoryAnchorModel]
    let pendingPlacement: PendingMemoryPlacement?
    let restoredWorldMap: ARWorldMap?
    let arSessionManager: ARSessionManaging
    let onSurfaceTap: (String, simd_float4x4) -> Void
    let onMemoryTap: (String) -> Void
    let onSessionAvailable: (ARSession) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onSurfaceTap: onSurfaceTap, onMemoryTap: onMemoryTap)
    }

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        context.coordinator.attach(to: arView)

        arSessionManager.configureARView(arView)
        arSessionManager.runSession(with: restoredWorldMap)
        context.coordinator.didRunWorldMap = restoredWorldMap != nil

        onSessionAvailable(arView.session)
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        if restoredWorldMap != nil && !context.coordinator.didRunWorldMap {
            arSessionManager.runSession(with: restoredWorldMap)
            context.coordinator.didRunWorldMap = true
        }

        if restoredWorldMap == nil {
            context.coordinator.didRunWorldMap = false
        }

        context.coordinator.syncMemories(memories, in: uiView)
        context.coordinator.syncPendingPlacement(pendingPlacement, in: uiView)
    }

    final class Coordinator: NSObject {
        private let onSurfaceTap: (String, simd_float4x4) -> Void
        private let onMemoryTap: (String) -> Void

        private weak var arView: ARView?
        fileprivate var didRunWorldMap = false

        private var placedMemoryAnchors = Set<String>()
        private var pendingAnchorName: String?

        init(onSurfaceTap: @escaping (String, simd_float4x4) -> Void, onMemoryTap: @escaping (String) -> Void) {
            self.onSurfaceTap = onSurfaceTap
            self.onMemoryTap = onMemoryTap
        }

        func attach(to arView: ARView) {
            self.arView = arView
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            arView.addGestureRecognizer(tapGesture)
        }

        func syncMemories(_ memories: [MemoryAnchorModel], in arView: ARView) {
            let currentNames = Set(memories.map(\.anchorName))

            for existingName in placedMemoryAnchors where !currentNames.contains(existingName) {
                removeAnchor(named: existingName, from: arView)
            }

            for memory in memories where !placedMemoryAnchors.contains(memory.anchorName) {
                guard let transform = MatrixTransformCoder.decode(memory.transformData) else {
                    continue
                }
                addAnchor(named: memory.anchorName, transform: transform, color: .systemTeal, to: arView)
                placedMemoryAnchors.insert(memory.anchorName)
            }
        }

        func syncPendingPlacement(_ pending: PendingMemoryPlacement?, in arView: ARView) {
            if let pending {
                if pendingAnchorName != pending.anchorName {
                    if let oldPending = pendingAnchorName {
                        removeAnchor(named: oldPending, from: arView)
                    }
                    addAnchor(named: pending.anchorName, transform: pending.transform, color: .systemGray, to: arView)
                    pendingAnchorName = pending.anchorName
                }
            } else if let pendingAnchorName {
                removeAnchor(named: pendingAnchorName, from: arView)
                self.pendingAnchorName = nil
            }
        }

        @objc private func handleTap(_ recognizer: UITapGestureRecognizer) {
            guard let arView else {
                return
            }

            let location = recognizer.location(in: arView)

            if let entity = arView.entity(at: location), !entity.name.isEmpty {
                onMemoryTap(entity.name)
                return
            }

            guard
                let query = arView.makeRaycastQuery(
                    from: location,
                    allowing: .existingPlaneGeometry,
                    alignment: .horizontal
                ) ?? arView.makeRaycastQuery(
                    from: location,
                    allowing: .estimatedPlane,
                    alignment: .horizontal
                ),
                let result = arView.session.raycast(query).first
            else {
                return
            }

            let anchorName = "anchor-\(UUID().uuidString)"
            onSurfaceTap(anchorName, result.worldTransform)
        }

        private func addAnchor(named name: String, transform: simd_float4x4, color: UIColor, to arView: ARView) {
            let arAnchor = ARAnchor(name: name, transform: transform)
            let anchorEntity = AnchorEntity(anchor: arAnchor)

            let sphere = ModelEntity(
                mesh: .generateSphere(radius: 0.05),
                materials: [SimpleMaterial(color: color.withAlphaComponent(0.85), roughness: 0.2, isMetallic: false)]
            )
            sphere.name = name
            sphere.position.y = 0.08
            sphere.generateCollisionShapes(recursive: true)

            anchorEntity.addChild(sphere)
            arView.scene.addAnchor(anchorEntity)
        }

        private func removeAnchor(named name: String, from arView: ARView) {
            let matches = arView.scene.anchors.filter { anchor in
                anchor.children.contains(where: { $0.name == name })
            }
            matches.forEach(arView.scene.removeAnchor)
            placedMemoryAnchors.remove(name)
        }
    }
}
