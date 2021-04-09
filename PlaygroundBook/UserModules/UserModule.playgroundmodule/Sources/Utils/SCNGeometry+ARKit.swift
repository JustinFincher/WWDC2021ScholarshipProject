//
//  SCNGeometry+ARKit.swift
//  UserModuleFramework
//
//  Created by fincher on 4/6/21.
//

import Foundation
import ARKit
import ModelIO
import SceneKit
import SceneKit.ModelIO

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
    
    func withConstant() -> SCNGeometry {
        self.firstMaterial?.fillMode = .fill
        self.firstMaterial?.lightingModel = .constant
        self.firstMaterial?.isDoubleSided = false
        return self
    }
    
    func withGrid() -> SCNGeometry {
        self.firstMaterial?.fillMode = .fill
        self.firstMaterial?.lightingModel = .constant
        self.firstMaterial?.diffuse.contents = UIImage(named: "grid")
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
    
    func withUV() -> SCNGeometry {
        let mesh = MDLMesh.init(scnGeometry: self)
        do {
            try mesh.makeVerticesUniqueAndReturnError()
        } catch let err {
            print(err)
        }
        let scnGeometry = SCNGeometry(mdlMesh: mesh)
        
        if scnGeometry.sources(for: .texcoord).count == 0 {
            var sources = scnGeometry.sources
            var vertexs = scnGeometry.sources(for: .vertex)
            var elements = scnGeometry.elements
            if let element = scnGeometry.elements.first,
               let vertex = vertexs.first
            {
                var uvList:[Float] = []
                let vertexArray = vertex.data.withUnsafeBytes { (pointer:UnsafeRawBufferPointer) -> [SCNVector3] in
                    return Array(pointer.bindMemory(to: SCNVector3.self))
                }
                let elementArray = element.data.withUnsafeBytes { (pointer:UnsafeRawBufferPointer) -> [SCNVector3] in
                    return Array(pointer.bindMemory(to: SCNVector3.self))
                }
                for i in 0..<elementArray.count {
                    let a : simd_float3 = simd_float3.init(vertexArray[3*i])
                    let b : simd_float3 = simd_float3.init(vertexArray[3*i+1])
                    let c : simd_float3 = simd_float3.init(vertexArray[3*i+2])
                    let side1 = b - a
                    let side2 = c - a
                    var n = simd_cross(side1, side2)
                    n = simd_normalize(simd_abs(n))
                    
                    if (n.x > n.y && n.x > n.z)
                    {
                        uvList.append(a.z)
                        uvList.append(a.y)
                        uvList.append(b.z)
                        uvList.append(b.y)
                        uvList.append(c.z)
                        uvList.append(c.y)
                    }
                    else if (n.y > n.x && n.y > n.z)
                    {
                        uvList.append(a.x)
                        uvList.append(a.z)
                        uvList.append(b.x)
                        uvList.append(b.z)
                        uvList.append(c.x)
                        uvList.append(c.z)
                    }
                    else if (n.z > n.x && n.z > n.y)
                    {
                        uvList.append(a.x)
                        uvList.append(a.y)
                        uvList.append(b.x)
                        uvList.append(b.y)
                        uvList.append(c.x)
                        uvList.append(c.y)
                    }
                }
                let uvData = uvList.withUnsafeMutableBufferPointer { (pointer) -> Data in
                    Data(buffer: pointer)
                }
//                let uvData = NSData(bytes: uvList, length: uvList.count * MemoryLayout.size(ofValue: simd_float2.self))
                let uv = SCNGeometrySource(data: uvData, semantic: .texcoord, vectorCount: vertex.vectorCount, usesFloatComponents: true, componentsPerVector: 2, bytesPerComponent: 4, dataOffset: 0, dataStride: 4 * 2)
                sources.append(uv)
                let mesh = SCNGeometry(sources: sources, elements: elements)
                return mesh
            }
        }
        return scnGeometry
    }
    
    func subdivide(level: Int) -> SCNGeometry {
        let mesh = MDLMesh.init(scnGeometry: self)
        if let subdivideMesh = MDLMesh.newSubdividedMesh(mesh, submeshIndex: 0, subdivisionLevels: level)
        {
            return SCNGeometry(mdlMesh: subdivideMesh)
        }
        return self
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
