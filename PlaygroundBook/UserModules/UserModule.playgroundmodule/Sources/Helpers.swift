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

extension MTKView: RenderDestinationProvider {
    
}
