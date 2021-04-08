//
//  AREventsManager.swift
//  UserModuleFramework
//
//  Created by fincher on 4/7/21.
//

import Foundation
import ARKit
import Combine
import SceneKit

class OperationManager: RuntimeManagableSingleton, ARSCNViewDelegate, ARSessionDelegate
{
    private var cancellable: AnyCancellable?
    let session: ARSession = ARSession()
    
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
                OperationManager.shared.session.run(configuration, options: [])
                break
            case .colorize:
                // copy all nodes here?
                
                let configuration = ARWorldTrackingConfiguration()
                configuration.appClipCodeTrackingEnabled = false
                configuration.environmentTexturing = .automatic
                configuration.isLightEstimationEnabled = true
                configuration.isCollaborationEnabled = false
                OperationManager.shared.session.run(configuration, options: [])
                break
            case .rigging:
                let configuration = ARBodyTrackingConfiguration()
                configuration.appClipCodeTrackingEnabled = false
                configuration.environmentTexturing = .automatic
                configuration.isLightEstimationEnabled = true
                OperationManager.shared.session.run(configuration, options: [])
                break
            case .export:
                break
            }
        })
        OperationManager.shared.session.delegate = OperationManager.shared
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
            return node
        }
        return nil
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let meshAnchor : ARMeshAnchor = anchor as? ARMeshAnchor {
            let geometry = SCNGeometry(arGeometry: meshAnchor.geometry)
            node.geometry = geometry.withWireframe()
        }
        EnvironmentManager.shared.triggerUpdate { env in }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        EnvironmentManager.shared.triggerUpdate { env in
            env.arMeshNodes.append(node)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        EnvironmentManager.shared.triggerUpdate { env in
            env.arMeshNodes.removeAll { n -> Bool in
                n.name == node.name
            }
        }
    }
}
