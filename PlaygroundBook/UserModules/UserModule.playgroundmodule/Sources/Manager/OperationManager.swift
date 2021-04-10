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
                OperationManager.shared.scene.background.intensity = 0.1
                OperationManager.shared.session.run(configuration, options: [])
                EnvironmentManager.shared.env.arEntities.forEach { entity in
                    if let node = entity.component(ofType: GKSCNNodeComponent.self)?.node {
                        node.geometry = node.geometry?.withUV().withUVMaterial()
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
