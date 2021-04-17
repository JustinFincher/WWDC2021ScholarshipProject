//
//  OperationManager.swift
//  DesktopTestBed
//
//  Created by fincher on 4/14/21.
//

import SceneKit
import Combine

class OperationManager: RuntimeManagableSingleton, SCNSceneRendererDelegate
{
    private var sceneLoadCancellable: AnyCancellable?
    let loadSceneNode : SCNReferenceNode = SCNReferenceNode()
    let humanNode : HumanNode = HumanNode()
    let scanNode : SCNNode = SCNNode()
    let scene: SCNScene = SCNScene()
    var animation : ARKitSkeletonAnimation? = nil
    
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
        OperationManager.shared.loadSceneNode.loadingPolicy = .onDemand
        OperationManager.shared.scene.rootNode.addChildNode(OperationManager.shared.loadSceneNode)
        OperationManager.shared.scene.rootNode.addChildNode(OperationManager.shared.humanNode)
        OperationManager.shared.scene.rootNode.addChildNode(OperationManager.shared.scanNode.withName(name: "scan"))
    }
    
    func loadScene(url: URL) -> Void {
        loadSceneNode.isHidden = true
        loadSceneNode.unload()
        loadSceneNode.referenceURL = url
        loadSceneNode.load()
        humanNode.cloneNode(anotherHuman: loadSceneNode.childNode(withName: "human", recursively: false)!)
        
        let targetScan = loadSceneNode.childNode(withName: "scan", recursively: false)!
        scanNode.simdWorldTransform = targetScan.simdWorldTransform
        scanNode.geometry = targetScan.geometry?.withPointSize(size: 50)
        if let skinner = targetScan.skinner {
            let newSkinner = SCNSkinner(baseGeometry: skinner.baseGeometry, bones: humanNode.getBones(), boneInverseBindTransforms: skinner.boneInverseBindTransforms, boneWeights: skinner.boneWeights, boneIndices: skinner.boneIndices)
            newSkinner.skeleton = humanNode.joints["root"]
            scanNode.skinner = newSkinner
        } else {
        }
        
        loadSceneNode.unload()
    }
    
    func filterPoints(callback: @escaping ()->Void) -> Void {
        DispatchQueue.global(qos: .userInteractive).async {
            self.humanNode.filterPoints(cloudPointNode: self.scanNode)
            DispatchQueue.main.async {
                callback()
            }
        }
    }
    
    func animate(animation: ARKitSkeletonAnimation) -> Void {
        self.animation = animation
    }
    
    func rig() -> Void {
        humanNode.rig(cloudPointNode: scanNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
        if animation?.frames.count ?? 0 > 0 {
            print("frame \(animation?.frames.count ?? 0)")
            humanNode.apply(frame: (animation?.frames[0])!)
            animation?.removeFirstFrame()
        }
    }
}
