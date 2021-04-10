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
    let scanNode : SCNNode = SCNNode()
    let scene: SCNScene = SCNScene()
    
    static let shared: OperationManager = {
        let instance = OperationManager()
        return instance
    }()
    
    private override init() {
        scene.rootNode.addChildNode(scanNode)
    }
    
    deinit {
        cancellable?.cancel()
    }
    
    override class func setup() {
        print("OperationManager.setup")
        OperationManager.shared.cancellable = EnvironmentManager.shared.env.$arOperationMode.sink(receiveValue: { mode in
            print("mode now \(mode)")
            switch mode {
            case .pointCloud:
                break
            case .skeletonRig:
                break
            case .presentHuman:
                break
            }})
        OperationManager.shared.session.delegate = OperationManager.shared
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        switch EnvironmentManager.shared.env.arOperationMode {
        case .pointCloud:
            break
        case .skeletonRig:
            break
        case .presentHuman:
            break
        }
    }
}
