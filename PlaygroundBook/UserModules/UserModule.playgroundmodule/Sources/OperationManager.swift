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
    private let ciContext = CIContext(options: nil)
    
    let session: ARSession = ARSession()
    let scene: SCNScene = SCNScene()
    let scanNode : SCNNode = SCNNode()
    let humanNode : HumanNode = HumanNode()
    let boundingBoxNode : SCNNode = SCNNode()
    let device: MTLDevice = MTLCreateSystemDefaultDevice()!
    var pointCloudCollector: PointCloudCollector?
    
    static let shared: OperationManager = {
        let instance = OperationManager()
        return instance
    }()
    
    private override init() {
        scene.rootNode.addChildNode(scanNode.withName(name: "scan"))
        scene.rootNode.addChildNode(humanNode)
        scene.rootNode.addChildNode(boundingBoxNode.withName(name: "boundingBox"))
    }
    
    deinit {
        cancellable?.cancel()
    }
    
    override class func setup() {
        print("OperationManager.setup")
        let manager = OperationManager.shared
        manager.pointCloudCollector = PointCloudCollector(session: manager.session, metalDevice: manager.device)
        manager.pointCloudCollector?.pointCloudsUpdated = {() in
            if let pointCloudCollector = manager.pointCloudCollector {
                manager.scanNode.geometry = SCNGeometry(buffer: pointCloudCollector.particlesBuffer).withAlphaMaterial()
            }
        }
        OperationManager.shared.cancellable = EnvironmentManager.shared.env.$arOperationMode
            .sink(receiveValue: { mode in
                    print("mode now \(mode)")
                    switch mode {
                    case .attachPointCloud:
                        OperationManager.shared.scene.background.intensity = 0.01
                        let configuration = ARWorldTrackingConfiguration()
                        configuration.frameSemantics = .sceneDepth
                        manager.session.run(configuration)
                        break
                    case .captureSekeleton:
                        OperationManager.shared.scene.background.intensity = 0.2
                        let configuration = ARBodyTrackingConfiguration()
                        configuration.frameSemantics = [.bodyDetection]
                        manager.session.run(configuration)
                        break
                    case .setBoundingBox:
                        break
                    case .rigAnimation:
                        break
                    }})
        OperationManager.shared.session.delegate = OperationManager.shared
    }
    
    
    //MARK: - ARSessionDelegate
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        pointCloudCollector?.drawRectResized(size: frame.camera.imageResolution)
        switch EnvironmentManager.shared.env.arOperationMode {
        case .attachPointCloud:
            pointCloudCollector?.draw()
            break
        case .captureSekeleton:
            break
        case .setBoundingBox:
            break
        case .rigAnimation:
            break
        }
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        let bodies : [ARBodyAnchor] = anchors.compactMap { anchor -> ARBodyAnchor? in
            anchor as? ARBodyAnchor
        }
        if let body = bodies.first {
            print("add body \(body)")
            humanNode.update(bodyAnchor: body)
        }
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        let bodies : [ARBodyAnchor] = anchors.compactMap { anchor -> ARBodyAnchor? in
            anchor as? ARBodyAnchor
        }
        if let body = bodies.first {
            print("add body \(body)")
            humanNode.update(bodyAnchor: body)
        }
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {

    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        
    }
    
    //MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    }
}
