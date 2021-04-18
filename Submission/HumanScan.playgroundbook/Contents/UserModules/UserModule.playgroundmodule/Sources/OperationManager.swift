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
    var scanNode : SCNNode = SCNNode()
    let humanNode : HumanNode = HumanNode()
    let device: MTLDevice = MTLCreateSystemDefaultDevice()!
    var pointCloudCollector: PointCloudCollector?
    
    static let shared: OperationManager = {
        let instance = OperationManager()
        return instance
    }()
    
    private override init() {
        scene.rootNode.addChildNode(scanNode.withName(name: "scan"))
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
                        manager.scene.background.intensity = 0.1
                        let configuration = ARWorldTrackingConfiguration()
                        configuration.frameSemantics = .sceneDepth
                        manager.session.run(configuration)
                        manager.scanNode.geometry = manager.scanNode.geometry?.withAlphaMaterial(alpha: 1.0)
                        break
                    case .captureSekeleton:
                        manager.scene.background.intensity = 0.4
                        let configuration = ARBodyTrackingConfiguration()
                        configuration.frameSemantics = [.bodyDetection]
                        manager.session.run(configuration)
                        manager.scanNode.geometry = manager.scanNode.geometry?.withAlphaMaterial(alpha: 0.2)
                        break
                    case .recordAnimation:
                        manager.scene.background.intensity = 0.2
                        let configuration = ARBodyTrackingConfiguration()
                        configuration.frameSemantics = [.bodyDetection]
                        manager.session.run(configuration)
                        manager.scanNode.geometry = manager.scanNode.geometry?.withAlphaMaterial(alpha: 0.5)
                        break
                    case .removeBgAndRig:
                        manager.scanNode.geometry = manager.scanNode.geometry?.withAlphaMaterial(alpha: 0.5)
                        manager.scene.background.intensity = 0.2
                        break
                    case .animateSkeleton:
                        manager.scanNode.geometry = manager.scanNode.geometry?.withAlphaMaterial(alpha: 1.0)
                        manager.scene.background.intensity = 1
                        break
                    case .positionSekeleton:
                        manager.scene.background.intensity = 0.3
                        manager.scanNode.geometry = manager.scanNode.geometry?.withAlphaMaterial(alpha: 0.6)
                        break
                    }})
        manager.session.delegate = manager
        manager.pointCloudCollector = PointCloudCollector(session: OperationManager.shared.session, metalDevice: OperationManager.shared.device)
        manager.pointCloudCollector?.pointCloudsUpdated = {() in
            if let pointCloudCollector = manager.pointCloudCollector {
                manager.scanNode.geometry = SCNGeometry(buffer: pointCloudCollector.particlesBuffer).withAlphaMaterial(alpha: 1)
            }
        }
        manager.humanNode.setup()
    }
    
    func applyScene(newScene: SCNScene) -> Void {
        
        if let loadHumanNode = newScene.rootNode.childNode(withName: "human", recursively: false)
        {
            humanNode.reset()
            humanNode.simdWorldTransform = loadHumanNode.simdWorldTransform
            loadHumanNode.childNodes.forEach { (child:SCNNode) in
                humanNode.addChildNode(child)
            }
            humanNode.setup()
        }
        
        if let loadScanNode = newScene.rootNode.childNode(withName: "scan", recursively: false)
        {
            scanNode.removeFromParentNode()
            scanNode = loadScanNode
            scanNode.simdWorldTransform = loadScanNode.simdWorldTransform
            scanNode.geometry = scanNode.geometry?.withPointSize(size: 15)
            scene.rootNode.addChildNode(scanNode)
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
                    self.applyScene(newScene: savedScene)
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
        pointCloudCollector?.drawRectResized(size: frame.camera.imageResolution)
        humanNode.session(session, didUpdate: frame)
        switch EnvironmentManager.shared.env.arOperationMode {
        case .attachPointCloud:
            pointCloudCollector?.draw()
            break
        case .captureSekeleton:
            break
        case .removeBgAndRig:
            break
        case .animateSkeleton:
            break
        case .positionSekeleton:
            break
        case .recordAnimation:
            break
        }
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
        humanNode.renderer(renderer, updateAtTime: time)
    }
}
