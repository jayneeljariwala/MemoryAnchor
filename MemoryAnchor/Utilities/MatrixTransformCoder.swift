import Foundation
import simd

enum MatrixTransformCoder {
    static func encode(_ transform: simd_float4x4) -> Data {
        var mutable = transform
        return Data(bytes: &mutable, count: MemoryLayout<simd_float4x4>.size)
    }

    static func decode(_ data: Data) -> simd_float4x4? {
        guard data.count == MemoryLayout<simd_float4x4>.size else {
            return nil
        }

        return data.withUnsafeBytes { rawBuffer in
            rawBuffer.baseAddress?.assumingMemoryBound(to: simd_float4x4.self).pointee
        }
    }
}
