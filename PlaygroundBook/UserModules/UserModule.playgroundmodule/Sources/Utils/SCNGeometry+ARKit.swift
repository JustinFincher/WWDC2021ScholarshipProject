//
//  SCNGeometry+ARKit.swift
//  UserModuleFramework
//
//  Created by fincher on 4/6/21.
//

import Foundation
import ARKit
import SceneKit

extension SCNGeometry
{
    convenience init(arGeometry: ARMeshGeometry) {
           let verticesSource = SCNGeometrySource(arGeometry.vertices, semantic: .vertex)
           let normalsSource = SCNGeometrySource(arGeometry.normals, semantic: .normal)
           let faces = SCNGeometryElement(arGeometry.faces)
           self.init(sources: [verticesSource, normalsSource], elements: [faces])
    }
    
    func withWireframe() -> SCNGeometry {
        self.firstMaterial?.fillMode = .lines
        self.firstMaterial?.isDoubleSided = false
        return self
    }
    
    func getVerticesCount() -> Int {
        var count = 0
        self.sources.forEach { source in
            count += source.vectorCount
        }
        return count
    }
}

extension  SCNGeometrySource {
        convenience init(_ source: ARGeometrySource, semantic: Semantic) {
               self.init(buffer: source.buffer, vertexFormat: source.format, semantic: semantic, vertexCount: source.count, dataOffset: source.offset, dataStride: source.stride)
        }
}
extension  SCNGeometryElement {
        convenience init(_ source: ARGeometryElement) {
               let pointer = source.buffer.contents()
               let byteCount = source.count * source.indexCountPerPrimitive * source.bytesPerIndex
               let data = Data(bytesNoCopy: pointer, count: byteCount, deallocator: .none)
               self.init(data: data, primitiveType: .of(source.primitiveType), primitiveCount: source.count, bytesPerIndex: source.bytesPerIndex)
        }
}
extension  SCNGeometryPrimitiveType {
        static  func  of(_ type: ARGeometryPrimitiveType) -> SCNGeometryPrimitiveType {
            switch type {
               case .line:
                return .line
               case .triangle:
                return .triangles
               @unknown default:
                return .triangles
            }
        }
}
