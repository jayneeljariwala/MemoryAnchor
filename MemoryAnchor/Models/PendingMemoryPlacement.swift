import Foundation
import simd

struct PendingMemoryPlacement: Identifiable {
    let id: UUID
    let anchorName: String
    let transform: simd_float4x4
}
