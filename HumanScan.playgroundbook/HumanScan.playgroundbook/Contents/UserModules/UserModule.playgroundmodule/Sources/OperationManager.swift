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
                        manager.scanNode.setAlpha(alpha: 0.8)
                        break
                    case .animateSkeleton:
                        manager.scanNode.setAlpha(alpha: 1.0)
                        break
                    case .positionSekeleton:
                        manager.scene.background.intensity = 0.05
                        manager.scanNode.setAlpha(alpha: 0.2)
                        break
                    }})
        manager.session.delegate = manager
        manager.scanNode.setup()
        manager.humanNode.setup()
    }
    
    func applyScene(scene: SCNScene) -> Void {
        humanNode.reset()
        if let loadHumanNode = scene.rootNode.childNode(withName: "human", recursively: false)
        {
            humanNode.simdWorldTransform = loadHumanNode.simdWorldTransform
            loadHumanNode.childNodes.forEach { (child:SCNNode) in
                humanNode.addChildNode(child)
            }
            humanNode.setup()
        }
        
        if let loadScanNode = scene.rootNode.childNode(withName: "scan", recursively: false)
        {
            scanNode.simdWorldTransform = loadScanNode.simdWorldTransform
            scanNode.geometry = scanNode.geometry?.withPointSize(size: 15)
            scanNode.setup()
        }
    }
    
    func goTo(mode: AROperationMode, callback: @escaping ()->Void) -> Void {
        switch mode {
        case .attachPointCloud, .captureSekeleton, .recordAnimation, .removeBgAndRig, .positionSekeleton:
            callback()
            EnvironmentManager.shared.env.arOperationMode = mode
            break
        case .animateSkeleton:
            DispatchQueue.global(qos: .userInteractive).async {
                self.humanNode.filterPoints(cloudPointNode: self.scanNode)
                self.humanNode.rig(cloudPointNode: self.scanNode)
                let sceneData = NSKeyedArchiver.archivedData(withRootObject: self.scene)
                if let source = SCNSceneSource(data: sceneData, options: nil),
                   let savedScene = source.scene(options: nil) {
                    self.applyScene(scene: savedScene)
                }
                DispatchQueue.main.async {
                    callback()
                    EnvironmentManager.shared.env.arOperationMode = mode
                }
            }
            break
        }
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
