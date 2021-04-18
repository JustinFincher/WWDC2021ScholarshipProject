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
    let humanNode : HumanNode = HumanNode()
    var scanNode : SCNNode? = nil
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
        OperationManager.shared.scene.rootNode.addChildNode(OperationManager.shared.humanNode)
    }
    
    func loadScene(ls: SCNScene) -> Void {
        humanNode.reset()
        let loadHumanNode = ls.rootNode.childNode(withName: "human", recursively: false)!
        humanNode.simdWorldTransform = loadHumanNode.simdWorldTransform
        loadHumanNode.childNodes.forEach { (child:SCNNode) in
            humanNode.addChildNode(child)
        }
        humanNode.setup()
        
        scanNode?.removeFromParentNode()
        scanNode = ls.rootNode.childNode(withName: "scan", recursively: false)!
        scanNode?.geometry = scanNode?.geometry!.withPointSize(size: 15)
        scene.rootNode.addChildNode(scanNode!)
    }
    
    func loadScene(url: URL) -> Void {
        var ls : SCNScene? = nil
        do {
            ls = try SCNScene(url: url, options: nil)
        } catch let err {
            print(err)
        }
        if let ls = ls {
            loadScene(ls: ls)
        }
    }
    
    func filterPoints(callback: @escaping ()->Void) -> Void {
        DispatchQueue.global(qos: .userInteractive).async {
            self.humanNode.filterPoints(cloudPointNode: self.scanNode!)
            DispatchQueue.main.async {
                callback()
            }
        }
    }
    
    func animate(animation: ARKitSkeletonAnimation) -> Void {
        self.animation = animation
    }
    
    func rig() -> Void {
        humanNode.name = "human"
        humanNode.rig(cloudPointNode: scanNode!)
        let sceneData = NSKeyedArchiver.archivedData(withRootObject: scene)
        let source = SCNSceneSource(data: sceneData, options: nil)!
        let newScene = source.scene(options: nil)!
        loadScene(ls: newScene)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
        if animation?.frames.count ?? 0 > 0 {
            print("frame \(animation?.frames.count ?? 0)")
            humanNode.setPose(frame: (animation?.frames[0])!)
            animation?.removeFirstFrame()
        }
    }
}
