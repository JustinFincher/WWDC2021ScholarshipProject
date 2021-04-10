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
        self.firstMaterial?.isDoubleSided = true
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
    
    func withIndependentMaterial() -> SCNGeometry {
        self.firstMaterial = SCNMaterial()
        return self
    }
    
    func withBlankDiffuseContent() -> SCNGeometry {
        UIGraphicsBeginImageContextWithOptions(CGSize.init(width: 128, height: 128), false, 1)
        let image : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.firstMaterial?.diffuse.contents = image
        return self
    }
    
    func applyDiffuseContent(list:  [(CGPoint, CGColor)]) -> Void {
        guard let uiImage = (self.firstMaterial?.diffuse.contents) as? UIImage,
              let cgImage = uiImage.cgImage else { return }
        let imageRect : CGRect = CGRect.init(x: 0, y: 0, width: cgImage.width, height: cgImage.height)
        UIGraphicsBeginImageContextWithOptions(CGSize.init(width: cgImage.width, height: cgImage.height), false, 1.0)
        guard let context : CGContext = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        context.draw(cgImage, in: imageRect)
        list.forEach { (i : (CGPoint, CGColor)) in
            context.setFillColor(i.1)
            context.fill(CGRect.init(x: i.0.x * CGFloat(cgImage.width), y: i.0.y * CGFloat(cgImage.height), width: 1.0, height: 1.0))
        }
        context.restoreGState()
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return }
        UIGraphicsEndImageContext()
        self.firstMaterial?.diffuse.contents = image
    }
    
//    func applyDiffuseContent(position: CGPoint, color: CGColor) -> Void {
//        guard let uiImage = (self.firstMaterial?.diffuse.contents) as? UIImage,
//              let cgImage = uiImage.cgImage else { return }
//        let imageRect : CGRect = CGRect.init(x: 0, y: 0, width: cgImage.width, height: cgImage.height)
//        UIGraphicsBeginImageContextWithOptions(CGSize.init(width: cgImage.width, height: cgImage.height), false, 1.0)
//        guard let context : CGContext = UIGraphicsGetCurrentContext() else { return }
//        context.saveGState()
//        context.draw(cgImage, in: imageRect)
//        context.setFillColor(color)
//        context.fill(CGRect.init(x: position.x, y: position.y, width: 1, height: 1))
//        context.restoreGState()
//        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return }
//        UIGraphicsEndImageContext()
//        self.firstMaterial?.diffuse.contents = image
//    }
    
    func withUVDebugMaterial() -> SCNGeometry {
        self.firstMaterial?.fillMode = .fill
        self.firstMaterial?.lightingModel = .constant
        self.firstMaterial?.isDoubleSided = false
        self.firstMaterial?.shaderModifiers = [
            SCNShaderModifierEntryPoint.fragment : """
                float2 uv = _surface.diffuseTexcoord;
                float4 color = _surface.diffuse;
                if (uv.x < 0 || uv.y < 0 || uv.x > 1 || uv.y > 1)
                {
                _output.color.rgba = float4(0,0,1,0.4);
                }
                else if (color.w < 0.5)
                {
                _output.color.rgba = float4(uv.x,uv.y,0,0.4);
                }
                else
                {
                _output.color.rgba = float4(color.x,color.y,color.z,0.8);
                }
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
                if (uv.x < 0 || uv.y < 0 || uv.x > 1 || uv.y > 1) {
                _output.color.rgba = float4(0,0,1,0.5);
                } else {
                _output.color.rgba = float4(uv.x,uv.y,0,0.5); }
                """
        ]
        return self
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
