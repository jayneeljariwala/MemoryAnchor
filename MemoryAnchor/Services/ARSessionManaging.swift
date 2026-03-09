import Foundation
import ARKit
import RealityKit

protocol ARSessionManaging: AnyObject {
    func configureARView(_ arView: ARView)
    func runSession(with worldMap: ARWorldMap?)
    func pauseSession()
    func encodeWorldMap(from session: ARSession) async throws -> Data
    func decodeWorldMap(from data: Data) throws -> ARWorldMap
}
