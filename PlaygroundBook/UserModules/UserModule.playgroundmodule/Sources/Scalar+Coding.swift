/*
See LICENSE folder for this sample’s licensing information.

Abstract:
General Helper methods and properties
*/

import ARKit
import MetalKit

extension Float {
    static let degreesToRadian = Float.pi / 180
}

extension matrix_float3x3 {
    mutating func copy(from affine: CGAffineTransform) {
        columns.0 = simd_float3(Float(affine.a), Float(affine.c), Float(affine.tx))
        columns.1 = simd_float3(Float(affine.b), Float(affine.d), Float(affine.ty))
        columns.2 = simd_float3(0, 0, 1)
    }
}

extension simd_float4x4: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        try self.init(container.decode([SIMD4<Float>].self))
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode([columns.0,columns.1, columns.2, columns.3])
    }
    func toPos() -> simd_float3 {
        let c = self.columns.0
        return simd_float3(c.x, c.y, c.z)
    }
}

extension MTKView: RenderDestinationProvider {
    
}
