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
import Accelerate

class OperationManager: RuntimeManagableSingleton, ARSCNViewDelegate, ARSessionDelegate
{
    private var cancellable: AnyCancellable?
    private let ciContext = CIContext(options: nil)
    
    let session: ARSession = ARSession()
    let scene: SCNScene = SCNScene()
    
    static let shared: OperationManager = {
        let instance = OperationManager()
        return instance
    }()
    
    private override init() {
        
    }
    
    deinit {
        cancellable?.cancel()
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
                OperationManager.shared.scene.background.intensity = 0.01
                OperationManager.shared.session.run(configuration, options: [])
                EnvironmentManager.shared.env.arEntities.forEach { entity in
                    if let node = entity.component(ofType: GKSCNNodeComponent.self)?.node {
                        node.geometry = node.geometry?
                            .subdivide(level: 1)
                            .withUV()
                            .withIndependentMaterial()
                            .withBlankDiffuseContent()
                            .withConstantMaterial()
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
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        switch EnvironmentManager.shared.env.arOperationMode {
        case .polygon:
            break
        case .colorize:
            autoreleasepool {
                guard let pixelBuffer = session.currentFrame?.capturedImage else {
                    return
                }
                let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
                guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent),
                      let pixelData = cgImage.dataProvider?.data
                else {
                    return
                }
                let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
                let halfWidth = Float(cgImage.width) / 2.0
                let quaterWidth = Float(cgImage.width) / 4.0
                let halfHeight = Float(cgImage.height) / 2.0
                let quaterHeight = Float(cgImage.height) / 4.0
                
                let count : Int = 8
                var hitDict: [SCNNode: [(CGPoint, CGColor)]] = [:]
                for x in Array(0...count).map({ v -> Int in
                    let progress : Float = Float(v)/Float(count)
                    return Int( halfWidth * progress + quaterWidth )
                }) {
                    for y in Array(0...count).map({ v -> Int in
                        let progress : Float = Float(v)/Float(count)
                        return Int( halfHeight * progress + quaterHeight )
                    }) {
                        let offset = 4 * (y * cgImage.width + x)
                        let color : CGColor = CGColor(red: CGFloat(data[offset]) / CGFloat(255.0),
                                                      green: CGFloat(data[offset + 1]) / CGFloat(255.0),
                                                      blue: CGFloat(data[offset + 2]) / CGFloat(255.0),
                                                      alpha: 1.0)
                        let results : [SCNHitTestResult] = renderer.hitTest(CGPoint.init(x: x, y: y), options: [
                            SCNHitTestOption.backFaceCulling : NSNumber.init(value: true),
                            SCNHitTestOption.clipToZRange : NSNumber.init(value: true),
                            SCNHitTestOption.searchMode : NSNumber.init(value: SCNHitTestSearchMode.closest.rawValue)
                        ])
                        results.forEach { result in
                            let uv = result.textureCoordinates(withMappingChannel: 0)
                            print("hit node with uv \(uv)")
                            if uv.x <= 1 && uv.y <= 1 && uv.x >= 0 && uv.y >= 0
                            {
                                var value : [(CGPoint, CGColor)] = hitDict[result.node] ?? []
                                value.append((result.textureCoordinates(withMappingChannel: 0), color))
                                hitDict[result.node] = value
                            }
                        }
                    }
                }
                hitDict.forEach { (key: SCNNode, value: [(CGPoint, CGColor)]) in
                    key.geometry?.applyDiffuseContent(list: value)
                }
            }
            break
        case .rigging:
            break
        case .export:
            break
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if EnvironmentManager.shared.env.arOperationMode != .polygon {
            return nil
        }
        if let meshAnchor : ARMeshAnchor = anchor as? ARMeshAnchor {
            let geometry = SCNGeometry(arGeometry: meshAnchor.geometry)
            let node = SCNNode()
            node.geometry = geometry.withWireframeMaterial()
            node.name = UUID().uuidString
            node.simdTransform = anchor.transform
            return node
        }
        return nil
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let meshAnchor : ARMeshAnchor = anchor as? ARMeshAnchor {
            let geometry = SCNGeometry(arGeometry: meshAnchor.geometry)
            node.geometry = geometry.withWireframeMaterial()
            node.simdTransform = anchor.transform
        }
        EnvironmentManager.shared.env.triggerUpdate { env in }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        let entity = GKEntity()
        entity.addComponent(GKSCNNodeComponent(node: node))
        node.entity = entity
        EnvironmentManager.shared.env.triggerUpdate { env in
            env.arEntities.append(entity)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        EnvironmentManager.shared.env.triggerUpdate { env in
            env.arEntities.removeAll { e -> Bool in
                e == node.entity
            }
        }
    }
}
