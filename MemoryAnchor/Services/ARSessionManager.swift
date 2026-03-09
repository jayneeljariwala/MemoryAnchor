import Foundation
import ARKit
import RealityKit

final class ARSessionManager: NSObject, ARSessionManaging {
    private weak var arView: ARView?

    func configureARView(_ arView: ARView) {
        self.arView = arView
        arView.automaticallyConfigureSession = false
    }

    func runSession(with worldMap: ARWorldMap?) {
        guard ARWorldTrackingConfiguration.isSupported, let arView else {
            return
        }

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.environmentTexturing = .automatic

        if let worldMap {
            configuration.initialWorldMap = worldMap
        }

        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    func pauseSession() {
        arView?.session.pause()
    }

    func encodeWorldMap(from session: ARSession) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            session.getCurrentWorldMap { map, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let map else {
                    continuation.resume(throwing: ARSessionError.worldMapUnavailable)
                    return
                }

                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                    continuation.resume(returning: data)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func decodeWorldMap(from data: Data) throws -> ARWorldMap {
        guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) else {
            throw ARSessionError.invalidWorldMapData
        }
        return worldMap
    }
}

enum ARSessionError: LocalizedError {
    case worldMapUnavailable
    case invalidWorldMapData

    var errorDescription: String? {
        switch self {
        case .worldMapUnavailable:
            return "Unable to generate an AR world map from the current session."
        case .invalidWorldMapData:
            return "Saved world map data is invalid or corrupted."
        }
    }
}
