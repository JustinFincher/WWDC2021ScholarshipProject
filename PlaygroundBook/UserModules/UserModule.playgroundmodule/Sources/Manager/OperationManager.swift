//
//  AREventsManager.swift
//  UserModuleFramework
//
//  Created by fincher on 4/7/21.
//

import Foundation
import ARKit
import Combine
import GameplayKit
import SceneKit

class OperationManager: RuntimeManagableSingleton, ARSCNViewDelegate, ARSessionDelegate
{
    private var cancellable: AnyCancellable?
    private let ciContext = CIContext(options: nil)
    
    let session: ARSession = ARSession()
    let scene: SCNScene = SCNScene()
    var frameCGImage: CGImage? = nil
    var frameColorizeBudget = 0
    
    private let texturingSystem = GKComponentSystem(componentClass: TexturingComponent.self)
    
    static let shared: OperationManager = {
        let instance = OperationManager()
        return instance
    }()
    
    private override init() {
        
    }
    
    override class func setup() {
        print("OperationManager.setup")
        OperationManager.shared.cancellable = EnvironmentManager.shared.env.$arOperationMode.sink(receiveValue: { mode in
            print("mode now \(mode)")
            switch mode {
            case .polygon:
                let configuration = ARWorldTrackingConfiguration()
                configuration.appClipCodeTrackingEnabled = false
                configuration.environmentTexturing = .automatic
                configuration.isLightEstimationEnabled = true
                configuration.isCollaborationEnabled = false
                configuration.sceneReconstruction = .mesh
                OperationManager.shared.scene.background.intensity = 0.02
                OperationManager.shared.session.run(configuration, options: [.removeExistingAnchors])
                break
            case .colorize:
                let configuration = ARWorldTrackingConfiguration()
                configuration.appClipCodeTrackingEnabled = false
                configuration.environmentTexturing = .automatic
                configuration.isLightEstimationEnabled = true
                configuration.isCollaborationEnabled = false
                OperationManager.shared.scene.background.intensity = 0.1
                OperationManager.shared.session.run(configuration, options: [])
                EnvironmentManager.shared.env.arEntities.forEach { entity in
                    if let node = entity.component(ofType: GKSCNNodeComponent.self)?.node
                    {
                        node.geometry = node.geometry?.withUV()
                    }
                }
                break
            case .rigging:
                let configuration = ARBodyTrackingConfiguration()
                configuration.appClipCodeTrackingEnabled = false
                configuration.environmentTexturing = .automatic
                configuration.isLightEstimationEnabled = true
                OperationManager.shared.scene.background.intensity = 1.0
                OperationManager.shared.session.run(configuration, options: [])
                break
            case .export:
                let configuration = ARWorldTrackingConfiguration()
                configuration.appClipCodeTrackingEnabled = false
                configuration.environmentTexturing = .automatic
                configuration.isLightEstimationEnabled = true
                configuration.isCollaborationEnabled = true
                OperationManager.shared.scene.background.intensity = 1.0
                OperationManager.shared.session.run(configuration, options: [])
                break
            }
        })
        OperationManager.shared.session.delegate = OperationManager.shared
    }
    
    func getPixelColorAt(x: CGFloat, y: CGFloat, fromWidth: CGFloat, fromHeight: CGFloat) -> SCNVector4? {
        if let frameCGImage = frameCGImage
        {
            let xP : CGFloat = x / fromWidth
            let yP : CGFloat = y / fromHeight
            var transformedX : Int = 0
            var transformedY : Int = 0
            if CGFloat(frameCGImage.width) / CGFloat(frameCGImage.height) > fromWidth / fromHeight
            {
                // crop left and right
                let targetWidth = CGFloat(fromWidth) / CGFloat(fromHeight) * CGFloat(frameCGImage.height)
                let leftPad = (targetWidth - CGFloat(frameCGImage.width)) / 2.0
                transformedX = Int(CGFloat(frameCGImage.width) * xP + leftPad)
                transformedY = Int(CGFloat(frameCGImage.height) * yP)
            } else if CGFloat(frameCGImage.width) / CGFloat(frameCGImage.height) < fromWidth / fromHeight
            {
                // crop top and bottom
                let targetHeight = CGFloat(fromHeight) / CGFloat(fromWidth) * CGFloat(frameCGImage.width)
                let topPad = (targetHeight - CGFloat(frameCGImage.height)) / 2.0
                transformedX = Int(CGFloat(frameCGImage.width) * xP)
                transformedY = Int(CGFloat(frameCGImage.height) * yP + topPad)
            } else {
                transformedX = Int(CGFloat(frameCGImage.width) * xP)
                transformedY = Int(CGFloat(frameCGImage.height) * yP)
            }
            if (transformedY < 0 || transformedX < 0 || transformedX > frameCGImage.width || transformedY > frameCGImage.height)
            {
                return nil
            }
            let bytesPerPixel = frameCGImage.bitsPerPixel / frameCGImage.bitsPerComponent
            let offset = (transformedY * frameCGImage.bytesPerRow) + (transformedX * bytesPerPixel)
            if let data = frameCGImage.dataProvider?.data,
               let frameImageData = CFDataGetBytePtr(data) {
                let r = CGFloat(frameImageData[offset]) / CGFloat(255.0)
                let g = CGFloat(frameImageData[offset+1]) / CGFloat(255.0)
                let b = CGFloat(frameImageData[offset+2]) / CGFloat(255.0)
                return SCNVector4(r, g, b, 1)
            }
        }
        return nil
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        frameColorizeBudget = 200
        if let frame = session.currentFrame {
            let ciImage = CIImage(cvPixelBuffer: frame.capturedImage)
            frameCGImage = ciContext.createCGImage(ciImage, from: ciImage.extent)
        }
        EnvironmentManager.shared.env.arEntities.forEach { entity in
            entity.components.forEach { comp in
                comp.update(deltaTime: time)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if EnvironmentManager.shared.env.arOperationMode != .polygon {
            return nil
        }
        if let meshAnchor : ARMeshAnchor = anchor as? ARMeshAnchor {
            let geometry = SCNGeometry(arGeometry: meshAnchor.geometry)
            let node = SCNNode()
            node.geometry = geometry.withWireframe()
            node.name = UUID().uuidString
            node.simdTransform = anchor.transform
            return node
        }
        return nil
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let meshAnchor : ARMeshAnchor = anchor as? ARMeshAnchor {
            let geometry = SCNGeometry(arGeometry: meshAnchor.geometry)
            node.geometry = geometry.withWireframe()
            node.simdTransform = anchor.transform
        }
        EnvironmentManager.shared.env.triggerUpdate { env in }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        let entity = GKEntity()
        entity.addComponent(GKSCNNodeComponent(node: node))
        entity.addComponent(TexturingComponent(renderer: renderer))
        node.entity = entity
        EnvironmentManager.shared.env.triggerUpdate { env in
            env.arEntities.append(entity)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        if let entity = node.entity {
            EnvironmentManager.shared.env.triggerUpdate { env in
                env.arEntities.removeAll { e -> Bool in
                    e == entity
                }
            }
        }
    }
}
