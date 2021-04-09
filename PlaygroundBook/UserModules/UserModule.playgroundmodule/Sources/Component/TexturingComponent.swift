//
//  TexturingComponent.swift
//  UserModuleFramework
//
//  Created by fincher on 4/8/21.
//

import Foundation
import SceneKit
import ARKit
import GameplayKit

class TexturingComponent: GKComponent {
    
    var node : SCNNode?
    var renderer : SCNSceneRenderer?
    
    init(renderer: SCNSceneRenderer) {
        self.renderer = renderer
        super.init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func toEntityDisplayModel() -> EntityDisplayModel {
        let model = EntityDisplayModel(key: String(describing: type(of: self)), value: "", children: [])
        return model
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if OperationManager.shared.frameColorizeBudget < 0 {
            return
        }
        if node == nil, let n = entity?.component(ofType: GKSCNNodeComponent.self)?.node {
            node = n
        }
        let session = OperationManager.shared.session
        if EnvironmentManager.shared.env.arOperationMode == .colorize,
           let node = node,
           let renderer = renderer,
           let geometry = node.geometry,
           let vertex = geometry.sources(for: .vertex).first,
           renderer.isNode(node, insideFrustumOf: renderer.pointOfView!)
        {
            let vectorCount = vertex.vectorCount
            let componentsPerVectorForColor = 4
            let bytesPerComponentForColor = 4
            let dataStrideForColor = bytesPerComponentForColor * componentsPerVectorForColor
            let colorDataLength = vectorCount * dataStrideForColor
            let elements = geometry.elements
            var sources = geometry.sources
            
            var colorData: Data? = nil
            if let existingColor = geometry.sources(for: .color).first,
               existingColor.componentsPerVector == componentsPerVectorForColor {
                colorData = existingColor.data
                sources.removeAll { source -> Bool in
                    source.semantic == .color
                }
            } else {
                colorData = Data(repeating: 0, count: colorDataLength)
            }
            
            var vertexData = vertex.data
            
            let vertexArray = vertexData.withUnsafeMutableBytes { (pointer: UnsafeMutableRawBufferPointer) -> [SCNVector3] in
                return Array(pointer.bindMemory(to: SCNVector3.self))
            }
            var colorArray = colorData!.withUnsafeMutableBytes { (pointer: UnsafeMutableRawBufferPointer) -> [SCNVector4] in
                return Array(pointer.bindMemory(to: SCNVector4.self))
            }
            
            for i in 0..<vectorCount {
                let v : SCNVector3 = vertexArray[i]
                var c : SCNVector4 = colorArray[i]
                if c.w < 0.95 { // not colorized yet
                    let vertexWorldPos = node.convertPosition(v, to: nil)
                    let vertexScreenPos = renderer.projectPoint(vertexWorldPos)
                    if  vertexScreenPos.z > 0,
                        let nc = OperationManager.shared.getPixelColorAt(
                        x: CGFloat(vertexScreenPos.x),
                        y: CGFloat(vertexScreenPos.y),
                        fromWidth: renderer.currentViewport.width,
                        fromHeight: renderer.currentViewport.height
                    ) {
                        c = c.lerp(target: nc, ratio: 0.2)
                        print("\(c)\n\(vertexWorldPos) -> \(vertexScreenPos)\n [\(v)]\n\(renderer.currentViewport)")
                        colorArray[i] = c
                        OperationManager.shared.frameColorizeBudget = OperationManager.shared.frameColorizeBudget - 1
                        if OperationManager.shared.frameColorizeBudget < 0 {
                            break
                        }
                    }
                }
            }
            
            colorData = colorArray.withUnsafeMutableBufferPointer { (pointer) -> Data in
                Data(buffer: pointer)
            }
            let color : SCNGeometrySource = SCNGeometrySource(data: colorData!, semantic: .color, vectorCount: vectorCount, usesFloatComponents: true, componentsPerVector: componentsPerVectorForColor, bytesPerComponent: bytesPerComponentForColor, dataOffset: 0, dataStride: dataStrideForColor)
            sources.append(color)
            node.geometry = SCNGeometry(sources: sources, elements: elements).withConstant()
        }
    }
}
