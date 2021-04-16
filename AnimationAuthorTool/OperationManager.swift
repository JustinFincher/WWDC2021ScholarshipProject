//
//  OperationManager.swift
//  DesktopTestBed
//
//  Created by fincher on 4/14/21.
//

import SceneKit
import MobileCoreServices
import Combine

class OperationManager: RuntimeManagableSingleton, SCNSceneRendererDelegate
{
    private var sceneLoadCancellable: AnyCancellable?
    let loadSceneNode : SCNReferenceNode = SCNReferenceNode()
    let scene: SCNScene = SCNScene()
    var animationRecordCount = 0
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
        OperationManager.shared.scene.rootNode.addChildNode(OperationManager.shared.loadSceneNode)
    }
    
    func loadScene(url: URL) -> Void {
        loadSceneNode.unload()
        loadSceneNode.referenceURL = url
        loadSceneNode.load()
        scene.isPaused = false
    }
    
    // MARK: - SCNSceneRendererDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
        
        if let hipNode : SCNNode = loadSceneNode.childNodes.count > 0 ? loadSceneNode.childNodes[0].presentation : nil,
        animationRecordCount > 0 {
            print("\(animationRecordCount) - \(time)")
            animationRecordCount -= 1
            var dict = Dictionary<String, simd_float4x4>()
            loadSceneNode.enumerateChildNodes { (child:SCNNode, stop:UnsafeMutablePointer<ObjCBool>) in
                if let name = child.name {
                    if mixamoJointMatchPair.keys.contains(name),
                       let arKitName = mixamoJointMatchPair[name]
                    {
                        let jointNode = child.presentation
                        dict[arKitName] = hipNode.simdConvertTransform(simd_float4x4(SCNMatrix4Identity), from: jointNode)
                    }
                }
            }
            let frame = ARKitSkeletonAnimationFrame(joints: dict)
            animation?.addFrame(frame: frame)
        }
    }
    
    func recordAnimation(framesCount: Int) -> Void {
        print("recordAnimation \(framesCount)")
        animation = ARKitSkeletonAnimation(frames: [])
        animationRecordCount = framesCount
    }
    
    func exportAnimation() -> Void {
        if let animation = animation {
            do {
                let jsonData = try JSONEncoder().encode(animation)
                let jsonString = String(data: jsonData, encoding: .utf8)!
                print(jsonString)
                UIPasteboard.general.string = jsonString
            } catch { print(error) }
        } else {
            print("error")
        }
    }
}
