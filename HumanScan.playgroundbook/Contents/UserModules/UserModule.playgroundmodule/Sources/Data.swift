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
    var joints : Dictionary<Int, simd_float4x4> = Dictionary<Int, simd_float4x4>()
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
    
    (0, 9, 0.5), // hips_joint to spine_7_joint
    (9, 14, 0.2), // spine_7_joint to head_joint
    (14, 14, 0.35), // spine_7_joint to head_joint
    
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
    (0, 9, 0.3), // "hips_joint" to "spine_7_joint"
    (9, 9, 0.3), // "spine_7_joint" sphere
    (9, 14, 0.3), // "spine_7_joint" to "head_joint"
    (14, 14, 0.15), // "head_joint" sphere
    (10, 13, 0.15), // "left_shoulder_1_joint" to "left_hand_joint"
    (13, 13, 0.12), // "left_hand_joint" sphere
    (15, 18, 0.15), // "right_shoulder_1_joint" to "right_hand_joint"
    (18, 18, 0.12), // "right_hand_joint" sphere
    (1, 2, 0.2), // "left_upLeg_joint" to "left_leg_joint"
    (2, 3, 0.12), // "left_leg_joint" to "left_foot_joint"
    (3, 4, 0.1), // ""left_foot_joint"" to "left_toesEnd_joint"
    (5, 6, 0.2), // "right_upLeg_joint" to "right_leg_joint"
    (6, 7, 0.12), // "right_leg_joint" to "right_foot_joint"
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

let metalShaders = """
#include <metal_stdlib>
#include <simd/simd.h>

enum TextureIndices {
    kTextureY = 0,
    kTextureCbCr = 1,
    kTextureDepth = 2,
    kTextureConfidence = 3
};

enum BufferIndices {
    kPointCloudUniforms = 0,
    kParticleUniforms = 1,
    kGridPoints = 2,
};

struct PointCloudUniforms {
    matrix_float4x4 viewProjectionMatrix;
    matrix_float4x4 localToWorld;
    matrix_float3x3 cameraIntrinsicsInversed;
    simd_float2 cameraResolution;
    
    float particleSize;
    int maxPoints;
    int pointCloudCurrentIndex;
};

struct ParticleUniforms {
    simd_float3 position;
    simd_float3 color;
    float confidence;
};

using namespace metal;

constexpr sampler colorSampler(mip_filter::linear, mag_filter::linear, min_filter::linear);
constant auto yCbCrToRGB = float4x4(float4(+1.0000f, +1.0000f, +1.0000f, +0.0000f),
                                    float4(+0.0000f, -0.3441f, +1.7720f, +0.0000f),
                                    float4(+1.4020f, -0.7141f, +0.0000f, +0.0000f),
                                    float4(-0.7010f, +0.5291f, -0.8860f, +1.0000f));

/// Retrieves the world position of a specified camera point with depth
static simd_float4 worldPoint(simd_float2 cameraPoint, float depth, matrix_float3x3 cameraIntrinsicsInversed, matrix_float4x4 localToWorld) {
    const auto localPoint = cameraIntrinsicsInversed * simd_float3(cameraPoint, 1) * depth;
    const auto worldPoint = localToWorld * simd_float4(localPoint, 1);
    
    return worldPoint / worldPoint.w;
}

///  Vertex shader that takes in a 2D grid-point and infers its 3D position in world-space, along with RGB and confidence
vertex void unprojectVertex(uint vertexID [[vertex_id]],
                            constant PointCloudUniforms &uniforms [[buffer(kPointCloudUniforms)]],
                            device ParticleUniforms *particleUniforms [[buffer(kParticleUniforms)]],
                            constant float2 *gridPoints [[buffer(kGridPoints)]],
                            texture2d<float, access::sample> capturedImageTextureY [[texture(kTextureY)]],
                            texture2d<float, access::sample> capturedImageTextureCbCr [[texture(kTextureCbCr)]],
                            texture2d<float, access::sample> depthTexture [[texture(kTextureDepth)]],
                            texture2d<unsigned int, access::sample> confidenceTexture [[texture(kTextureConfidence)]]) {
    
    const auto gridPoint = gridPoints[vertexID];
    const auto currentPointIndex = (uniforms.pointCloudCurrentIndex + vertexID) % uniforms.maxPoints;
    const auto texCoord = gridPoint / uniforms.cameraResolution;
    // Sample the depth map to get the depth value
    const auto depth = depthTexture.sample(colorSampler, texCoord).r;
    // With a 2D point plus depth, we can now get its 3D position
    const auto position = worldPoint(gridPoint, depth, uniforms.cameraIntrinsicsInversed, uniforms.localToWorld);
    
    // Sample Y and CbCr textures to get the YCbCr color at the given texture coordinate
    const auto ycbcr = float4(capturedImageTextureY.sample(colorSampler, texCoord).r, capturedImageTextureCbCr.sample(colorSampler, texCoord.xy).rg, 1);
    const auto sampledColor = (yCbCrToRGB * ycbcr).rgb;
    // Sample the confidence map to get the confidence value
    const auto confidence = confidenceTexture.sample(colorSampler, texCoord).r;
    
    // Write the data to the buffer
    particleUniforms[currentPointIndex].position = position.xyz;
    particleUniforms[currentPointIndex].color = sampledColor;
    particleUniforms[currentPointIndex].confidence = confidence;
}
"""
