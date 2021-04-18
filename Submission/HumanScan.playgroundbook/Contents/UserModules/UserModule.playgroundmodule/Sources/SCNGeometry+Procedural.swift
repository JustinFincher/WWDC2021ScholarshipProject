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
        let bufferoCount = buffer.count
        let bufferStride = buffer.stride
        let positionOffset : Int = MemoryLayout.offset(of: \ParticleUniforms.position) ?? 0
        let vertexSource : SCNGeometrySource = SCNGeometrySource(buffer: buffer.getMTLBuffer(),
                                                                 vertexFormat: .float3,
                                                                 semantic: .vertex,
                                                                 vertexCount: bufferoCount,
                                                                 dataOffset: positionOffset,
                                                                 dataStride: bufferStride)
        let colorOffset : Int = MemoryLayout.offset(of: \ParticleUniforms.color) ?? 16 // simd_float3 actually has 4*4
        let colorSource : SCNGeometrySource = SCNGeometrySource(buffer: buffer.getMTLBuffer(),
                                                                vertexFormat: .float3,
                                                                semantic: .color,
                                                                vertexCount: bufferoCount,
                                                                dataOffset: colorOffset,
                                                                dataStride: bufferStride)
        
        let indices = Array(ClosedRange<Int32>.init(0..<Int32(buffer.count)))
        let indiceData = indices.withUnsafeBufferPointer { Data(buffer: $0) }
        let element = SCNGeometryElement(data: indiceData, primitiveType: .point, primitiveCount: buffer.count, bytesPerIndex: MemoryLayout.size(ofValue: Int32(0)))
        element.pointSize = 15
        element.minimumPointScreenSpaceRadius = 2
        element.maximumPointScreenSpaceRadius = 20
        
        self.init(sources: [vertexSource, colorSource], elements: [element])
    }
    
    convenience init(line from: SCNVector3, to: SCNVector3) {
        let indices: [Int32] = [0, 1]
        let source = SCNGeometrySource(vertices: [from, to])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        element.pointSize = 15
        element.minimumPointScreenSpaceRadius = 2
        element.maximumPointScreenSpaceRadius = 15
        self.init(sources: [source], elements: [element])
    }
}
