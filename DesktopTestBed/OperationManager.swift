//
//  OperationManager.swift
//  DesktopTestBed
//
//  Created by fincher on 4/14/21.
//

import SceneKit
import Combine

class OperationManager: RuntimeManagableSingleton
{
    private var sceneLoadCancellable: AnyCancellable?
    let loadSceneNode : SCNReferenceNode = SCNReferenceNode()
    let humanNode : HumanNode = HumanNode()
    let scanNode : SCNNode = SCNNode()
    let scene: SCNScene = SCNScene()
    
    static let shared: OperationManager = {
        let instance = OperationManager()
        return instance
    }()
    
    private override init() {
        
    }
    
    deinit {
        sceneLoadCancellable?.cancel()
    }
    
    override class func setup() {
        print("OperationManager.setup")
        OperationManager.shared.sceneLoadCancellable = EnvironmentManager.shared.env.$sceneURL.sink { (url : URL?) in
            if let url = url {
                OperationManager.shared.loadScene(url: url)
            }
        }
        OperationManager.shared.scene.rootNode.addChildNode(OperationManager.shared.loadSceneNode)
        OperationManager.shared.scene.rootNode.addChildNode(OperationManager.shared.humanNode)
        OperationManager.shared.scene.rootNode.addChildNode(OperationManager.shared.scanNode)
    }
    
    func loadScene(url: URL) -> Void {
        loadSceneNode.unload()
        loadSceneNode.referenceURL = url
        loadSceneNode.load()
        humanNode.cloneNode(anotherHuman: loadSceneNode.childNode(withName: "human", recursively: false)!)
        
        let targetScan = loadSceneNode.childNode(withName: "human", recursively: false)!
        scanNode.simdWorldTransform = targetScan.simdWorldTransform
        scanNode.geometry = targetScan.geometry
        
        loadSceneNode.unload()
    }
    
    func filterPoints() -> Void {
        humanNode.filterPoints(cloudPointNode: scanNode)
    }
    
    func rig() -> Void {
        
    }
}
