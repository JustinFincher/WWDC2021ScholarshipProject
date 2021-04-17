//
//  Data.swift
//  UserModuleFramework
//
//  Created by fincher on 4/7/21.
//

import Foundation
import MetalKit
import SceneKit

let arDebugMode = false

enum AROperationMode {
    case captureSekeleton
    case positionSekeleton
    case attachPointCloud
    case removeBgAndRig
    case animateSkeleton
    case recordAnimation
}

protocol RenderDestinationProvider {
    var currentRenderPassDescriptor: MTLRenderPassDescriptor? { get }
    var currentDrawable: CAMetalDrawable? { get }
    var colorPixelFormat: MTLPixelFormat { get set }
    var depthStencilPixelFormat: MTLPixelFormat { get set }
    var sampleCount: Int { get set }
}

struct ARKitSkeletonAnimationFrame : Codable {
    var joints : Dictionary<String, simd_float4x4> = Dictionary<String, simd_float4x4>()
}

struct ARKitSkeletonAnimation : Codable {
    var frames : [ARKitSkeletonAnimationFrame] = []
    mutating func addFrame(frame: ARKitSkeletonAnimationFrame){
        frames.append(frame)
    }
    mutating func removeFirstFrame() {
        frames.removeFirst()
    }
}

var jointCount = 19
let jointNames : [String] = [
                             "hips_joint", // 0
                             "left_upLeg_joint", // 1
                             "left_leg_joint", // 2
                             "left_foot_joint", // 3
                             "left_toesEnd_joint", // 4
                             "right_upLeg_joint", // 5
                             "right_leg_joint", // 6
                             "right_foot_joint", // 7
                             "right_toesEnd_joint", // 8
                             "spine_7_joint", // 9
                             "left_shoulder_1_joint", // 10
                             "left_arm_joint", // 11
                             "left_forearm_joint", // 12
                             "left_hand_joint", // 13
                             "head_joint", // 14
                             "right_shoulder_1_joint", // 15
                             "right_arm_joint", // 16
                             "right_forearm_joint", // 17
                             "right_hand_joint" // 18
]

var jointParentIndices : [Int] = [
    -1,
    0,
    1,
    2,
    3,
    0,
    5,
    6,
    7,
    0,
    9,
    10,
    11,
    12,
    9,
    9,
    15,
    16,
    17
]

let riggingVolumeIndex : [(startJoint: Int, endJoint: Int, radius: Float)] = [
    
    (1, 1, 0.2), // left_upLeg_joint
    (1, 2, 0.2), // left_upLeg_joint to left_leg_joint
    (2, 3, 0.2), // left_leg_joint to left_foot_joint
    (3, 4, 0.2), // left_foot_joint to left_toesEnd_joint
    
    (5, 5, 0.2), // right_upLeg_joint
    (5, 6, 0.2), // right_upLeg_joint to right_leg_joint
    (6, 7, 0.2), // right_leg_joint to right_foot_joint
    (7, 8, 0.2), // right_foot_joint to right_toesEnd_joint
    
    (0, 9, 0.3), // hips_joint to spine_7_joint
    (9, 14, 0.15), // spine_7_joint to head_joint
    
    (10, 11, 0.2), // left_shoulder_1_joint to left_arm_joint
    (11, 12, 0.18), // left_arm_joint to left_forearm_joint
    (12, 13, 0.16), // left_forearm_joint to left_hand_joint
    (13, 13, 0.2), // left_hand_joint
    
    (15, 16, 0.2), // right_shoulder_1_joint to right_arm_joint
    (16, 17, 0.18), // right_arm_joint to right_forearm_joint
    (17, 18, 0.16), // right_forearm_joint to right_hand_joint
    (18, 18, 0.2), // right_hand_joint
]

let boundingBoxIndex : [(startJoint: Int, endJoint: Int, radius: Float)] = [
    (0, 9, 0.25), // "hips_joint" to "spine_7_joint"
    (9, 14, 0.25), // "spine_7_joint" to "head_joint"
    (14, 14, 0.15), // "head_joint" sphere
    (10, 13, 0.15), // "left_shoulder_1_joint" to "left_hand_joint"
    (13, 13, 0.1), // "left_hand_joint" sphere
    (15, 18, 0.15), // "right_shoulder_1_joint" to "right_hand_joint"
    (18, 18, 0.1), // "right_hand_joint" sphere
    (1, 3, 0.1), // "left_upLeg_joint" to "left_foot_joint"
    (3, 4, 0.1), // ""left_foot_joint"" to "left_toesEnd_joint"
    (5, 7, 0.1), // "right_upLeg_joint" to "right_foot_joint"
    (7, 8, 0.1), // ""right_foot_joint"" to "right_toesEnd_joint"
]

var mixamoJointMatchPair = [
    "mixamorig_Hips": "hips_joint",
    
    "mixamorig_LeftUpLeg": "left_upLeg_joint",
    "mixamorig_LeftLeg" : "left_leg_joint",
    "mixamorig_LeftFoot" : "left_foot_joint",
    "mixamorig_LeftToeBase" : "left_toes_joint",
    "mixamorig_LeftToe_End" : "left_toesEnd_joint",
    
    "mixamorig_RightUpLeg": "right_upLeg_joint",
    "mixamorig_RightLeg" : "right_leg_joint",
    "mixamorig_RightFoot" : "right_foot_joint",
    "mixamorig_RightToeBase" : "right_toes_joint",
    "mixamorig_RightToe_End" : "right_toesEnd_joint",
    
    "mixamorig_Spine": "spine_1_joint",
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
