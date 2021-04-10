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
    
    func withWireframeMaterial() -> SCNGeometry {
        self.firstMaterial?.fillMode = .lines
        self.firstMaterial?.isDoubleSided = false
        return self
    }
    
    func withConstantMaterial() -> SCNGeometry {
        self.firstMaterial?.fillMode = .fill
        self.firstMaterial?.lightingModel = .constant
        self.firstMaterial?.isDoubleSided = false
        return self
    }
    
    func withGridMaterial() -> SCNGeometry {
        self.firstMaterial?.fillMode = .fill
        self.firstMaterial?.lightingModel = .constant
        let image = UIImage(named: "grid.jpeg" )
        self.firstMaterial?.diffuse.contents = image
        self.firstMaterial?.emission.contents = image
        self.firstMaterial?.isDoubleSided = true
        return self
    }
    
    func withNormalMaterial() -> SCNGeometry {
        self.firstMaterial?.fillMode = .fill
        self.firstMaterial?.lightingModel = .constant
        self.firstMaterial?.shaderModifiers = [
            SCNShaderModifierEntryPoint.fragment : """
                float3 normal = _surface.normal;
                _output.color.rgba = float4(normal.x,normal.y,normal.z,0.5);
                """
        ]
        return self
    }
    
    func withUVMaterial() -> SCNGeometry {
        self.firstMaterial?.fillMode = .fill
        self.firstMaterial?.lightingModel = .constant
        self.firstMaterial?.shaderModifiers = [
            SCNShaderModifierEntryPoint.fragment : """
                float2 uv = _surface.diffuseTexcoord;
                if (uv.x < 0 || uv.y < 0) {
                _output.color.rgba = float4(0,0,1,0.5);
                } else {
                _output.color.rgba = float4(uv.x,uv.y,0,0.5); }
                """
        ]
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
        mesh.addNormals(withAttributeNamed: MDLVertexAttributeNormal, creaseThreshold: 0.0)
        let scnGeometry = SCNGeometry(mdlMesh: mesh)
        
        if scnGeometry.sources(for: .texcoord).count == 0 {
            var sources = scnGeometry.sources
            let vertexs = scnGeometry.sources(for: .vertex)
            let elements = scnGeometry.elements
            if let element = scnGeometry.elements.first,
               let vertex = vertexs.first
            {
                var uvList:[Float] = []
                let elementArray = element.data.withUnsafeBytes { (pointer:UnsafeRawBufferPointer) -> [SCNVector3] in
                    return Array(pointer.bindMemory(to: SCNVector3.self))
                }
                let sqrt : Float = sqrtf(Float(elementArray.count))
                let width : Int = Int(ceilf(sqrt))
                let height : Int = Int(floorf(sqrt))
                for i in 0..<elementArray.count {
                    let y : Int = i / width
                    let x : Int = i % width
                    uvList.append(Float(x) / Float(width))
                    uvList.append(Float(y) / Float(height))
                    uvList.append((Float(x) + 1) / Float(width))
                    uvList.append(Float(y) / Float(height))
                    uvList.append((Float(x)  + 0.5) / Float(width))
                    uvList.append((Float(y) + 1) / Float(height))
                }
                let uvData = uvList.withUnsafeMutableBufferPointer { (pointer) -> Data in
                    Data(buffer: pointer)
                }
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
