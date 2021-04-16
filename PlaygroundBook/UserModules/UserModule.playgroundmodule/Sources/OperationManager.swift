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
import MetalKit

class OperationManager: RuntimeManagableSingleton, ARSCNViewDelegate, ARSessionDelegate
{
    private var cancellable: AnyCancellable?
    
    let session: ARSession = ARSession()
    let scene: SCNScene = SCNScene()
    let scanNode : ScanNode = ScanNode()
    let humanNode : HumanNode = HumanNode()
    let device: MTLDevice = MTLCreateSystemDefaultDevice()!
    
    static let shared: OperationManager = {
        let instance = OperationManager()
        return instance
    }()
    
    private override init() {
        scene.rootNode.addChildNode(scanNode)
        scene.rootNode.addChildNode(humanNode)
    }
    
    deinit {
        cancellable?.cancel()
    }
    
    override class func setup() {
        print("OperationManager.setup")
        let manager = OperationManager.shared
        manager.cancellable = EnvironmentManager.shared.env.$arOperationMode
            .sink(receiveValue: { mode in
                    print("mode now \(mode)")
                    switch mode {
                    case .attachPointCloud:
                        manager.scene.background.intensity = 0.01
                        let configuration = ARWorldTrackingConfiguration()
                        configuration.frameSemantics = .sceneDepth
                        manager.session.run(configuration)
                        manager.scanNode.setAlpha(alpha: 1.0)
                        break
                    case .captureSekeleton:
                        manager.scene.background.intensity = 0.2
                        let configuration = ARBodyTrackingConfiguration()
                        configuration.frameSemantics = [.bodyDetection]
                        manager.session.run(configuration)
                        manager.scanNode.setAlpha(alpha: 0.5)
                        break
                    case .recordAnimation:
                        manager.scene.background.intensity = 0.2
                        let configuration = ARBodyTrackingConfiguration()
                        configuration.frameSemantics = [.bodyDetection]
                        manager.session.run(configuration)
                        manager.scanNode.setAlpha(alpha: 0.5)
                        break
                    case .removeBgAndRig:
                        manager.scanNode.setAlpha(alpha: 1.0)
                        break
                    case .animateSkeleton:
                        manager.scanNode.setAlpha(alpha: 1.0)
                        break
                    case .positionSekeleton:
                        manager.scene.background.intensity = 0.05
                        manager.scanNode.setAlpha(alpha: 0.9)
                        break
                    }})
        manager.session.delegate = manager
        manager.scanNode.setup()
        manager.humanNode.setup()
    }
    
    
    
    //MARK: - ARSessionDelegate
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        scanNode.session(session, didUpdate: frame)
        humanNode.session(session, didUpdate: frame)
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        humanNode.session(session, didAdd: anchors)
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        humanNode.session(session, didUpdate: anchors)
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        
    }
    
    //MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        scanNode.renderer(renderer, updateAtTime: time)
        humanNode.renderer(renderer, updateAtTime: time)
    }
}
