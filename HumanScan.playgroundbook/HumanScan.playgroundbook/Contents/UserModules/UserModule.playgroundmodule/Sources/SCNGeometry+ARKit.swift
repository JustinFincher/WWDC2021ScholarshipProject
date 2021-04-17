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
    
    func withWhiteMaterial() -> SCNGeometry {
        self.firstMaterial?.fillMode = .fill
        self.firstMaterial?.lightingModel = .constant
        self.firstMaterial?.diffuse.contents = UIColor.white
        return self
    }
    
    func withAlphaMaterial() -> SCNGeometry {
        self.firstMaterial?.fillMode = .fill
        self.firstMaterial?.lightingModel = .constant
        self.firstMaterial?.shaderModifiers = [
            SCNShaderModifierEntryPoint.fragment : """
                float4 color = _surface.diffuse;
                if (color.a == 0)
                {
                    discard_fragment();
                }
                _output.color.rgba = color;
                """
        ]
        return self
    }
    
    func withPointSize(size: CGFloat) -> SCNGeometry {
        let sources = self.sources
        let elements = self.elements
        elements.forEach { (ele:SCNGeometryElement) in
            ele.pointSize = size
            ele.maximumPointScreenSpaceRadius = size
        }
        
        let geo = SCNGeometry(sources: sources, elements: elements)
        geo.firstMaterial?.fillMode = .fill
        geo.firstMaterial?.cullMode = .back
        geo.firstMaterial?.isDoubleSided = true
        geo.firstMaterial?.lightingModel = .constant
        geo.firstMaterial?.diffuse.contents = UIColor.white
        return geo
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
