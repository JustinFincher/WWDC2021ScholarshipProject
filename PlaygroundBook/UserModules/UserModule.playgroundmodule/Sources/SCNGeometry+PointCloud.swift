//
//  SCNGeometry+PointCloud.swift
//  UserModuleFramework
//
//  Created by fincher on 4/10/21.
//

import Foundation
import SceneKit

extension SCNGeometry {
    convenience init(buffer : MetalBuffer<ParticleUniforms>)
    {
        let positionOffset : Int = MemoryLayout.offset(of: \ParticleUniforms.position) ?? 0
        let vertexSource : SCNGeometrySource = SCNGeometrySource(buffer: buffer.getMTLBuffer(),
                                                           vertexFormat: .float3,
                                                           semantic: .vertex,
                                                           vertexCount: buffer.count,
                                                           dataOffset: positionOffset,
                                                           dataStride: buffer.stride)
        let colorOffset : Int = MemoryLayout.offset(of: \ParticleUniforms.color) ?? 12
        let colorSource : SCNGeometrySource = SCNGeometrySource(buffer: buffer.getMTLBuffer(),
                                                           vertexFormat: .float3,
                                                           semantic: .color,
                                                           vertexCount: buffer.count,
                                                           dataOffset: colorOffset,
                                                           dataStride: buffer.stride)
        let indices = Array(ClosedRange<Int32>.init(0..<Int32(buffer.count)))
        let indiceData = indices.withUnsafeBufferPointer { Data(buffer: $0) }
        let element = SCNGeometryElement(data: indiceData, primitiveType: .point, primitiveCount: buffer.count, bytesPerIndex: MemoryLayout.size(ofValue: Int32(0)))
        element.pointSize = 15
        element.minimumPointScreenSpaceRadius = 2
        element.maximumPointScreenSpaceRadius = 15
            
        self.init(sources: [vertexSource, colorSource], elements: [element])
    }
}
