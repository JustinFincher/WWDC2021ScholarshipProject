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
    var mixamoNamePair = [
        "hips_joint": "hips_joint",
        
        "left_upLeg_joint": "left_upLeg_joint",
        "mixamorig_LeftLeg" : "left_leg_joint",
        "mixamorig_LeftFoot" : "left_foot_joint",
        "mixamorig_LeftToeBase" : "left_toes_joint",
        "mixamorig_LeftToe_End" : "left_toesEnd_joint",
        
        "right_upLeg_joint": "right_upLeg_joint",
        "mixamorig_RightLeg" : "right_leg_joint",
        "mixamorig_RightFoot" : "right_foot_joint",
        "mixamorig_RightToeBase" : "right_toes_joint",
        "mixamorig_RightToe_End" : "right_toesEnd_joint",
        
        "spine_1_joint": "spine_1_joint",
        "mixamorig_Spine1": "spine_4_joint",
        "mixamorig_Spine2": "spine_7_joint",
        "mixamorig_Neck": "neck_3_joint",
        "mixamorig_Head": "head_joint",
        
        "mixamorig_LeftEye" : "left_eye_joint",
        "mixamorig_RightEye" : "right_eye_joint",
        
        "mixamorig_LeftShoulder" : "left_shoulder_1_joint",
        "mixamorig_LeftArm" : "left_arm_joint",
        "mixamorig_LeftForeArm" : "left_forearm_joint",
        "mixamorig_LeftHand" : "left_hand_joint",
        
        "mixamorig_RightShoulder" : "right_shoulder_1_joint",
        "mixamorig_RightArm" : "right_arm_joint",
        "mixamorig_RightForeArm" : "right_forearm_joint",
        "mixamorig_RightHand" : "right_hand_joint"
    ]
    
    
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
        if let hipNode : SCNNode = loadSceneNode.childNode(withName: "hips_joint", recursively: false)?.presentation,
           animationRecordCount > 0 {
            print("\(animationRecordCount) - \(time)")
            animationRecordCount -= 1
            var dict = Dictionary<String, simd_float4x4>()
            loadSceneNode.enumerateChildNodes { (child:SCNNode, stop:UnsafeMutablePointer<ObjCBool>) in
                if let name = child.name {
                    if mixamoNamePair.keys.contains(name),
                       let arKitName = mixamoNamePair[name]
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
        }
    }
}
