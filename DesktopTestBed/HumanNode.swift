//
//  HumanNode.swift
//  UserModuleFramework
//
//  Created by fincher on 4/13/21.
//

import Foundation
import SceneKit
import SwiftUI

class HumanNode: SCNNode
{
    var jointCount = 91
    var jointNames : [String] = [
        "root","hips_joint","left_upLeg_joint","left_leg_joint","left_foot_joint","left_toes_joint","left_toesEnd_joint","right_upLeg_joint","right_leg_joint","right_foot_joint","right_toes_joint","right_toesEnd_joint","spine_1_joint","spine_2_joint","spine_3_joint","spine_4_joint","spine_5_joint","spine_6_joint","spine_7_joint","left_shoulder_1_joint","left_arm_joint","left_forearm_joint","left_hand_joint","left_handIndexStart_joint","left_handIndex_1_joint","left_handIndex_2_joint","left_handIndex_3_joint","left_handIndexEnd_joint","left_handMidStart_joint","left_handMid_1_joint","left_handMid_2_joint","left_handMid_3_joint","left_handMidEnd_joint","left_handPinkyStart_joint","left_handPinky_1_joint","left_handPinky_2_joint","left_handPinky_3_joint","left_handPinkyEnd_joint","left_handRingStart_joint","left_handRing_1_joint","left_handRing_2_joint","left_handRing_3_joint","left_handRingEnd_joint","left_handThumbStart_joint","left_handThumb_1_joint","left_handThumb_2_joint","left_handThumbEnd_joint","neck_1_joint","neck_2_joint","neck_3_joint","neck_4_joint","head_joint","jaw_joint","chin_joint","left_eye_joint","left_eyeLowerLid_joint","left_eyeUpperLid_joint","left_eyeball_joint","nose_joint","right_eye_joint","right_eyeLowerLid_joint","right_eyeUpperLid_joint","right_eyeball_joint","right_shoulder_1_joint","right_arm_joint","right_forearm_joint","right_hand_joint","right_handIndexStart_joint","right_handIndex_1_joint","right_handIndex_2_joint","right_handIndex_3_joint","right_handIndexEnd_joint","right_handMidStart_joint","right_handMid_1_joint","right_handMid_2_joint","right_handMid_3_joint","right_handMidEnd_joint","right_handPinkyStart_joint","right_handPinky_1_joint","right_handPinky_2_joint","right_handPinky_3_joint","right_handPinkyEnd_joint","right_handRingStart_joint","right_handRing_1_joint","right_handRing_2_joint","right_handRing_3_joint","right_handRingEnd_joint","right_handThumbStart_joint","right_handThumb_1_joint","right_handThumb_2_joint","right_handThumbEnd_joint"
    ]
    
    var parentIndices : [Int] = [
        -1,0,1,2,3,4,5,1,7,8,9,10,1,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,22,28,29,30,31,22,33,34,35,36,22,38,39,40,41,22,43,44,45,18,47,48,49,50,51,52,51,54,54,54,51,51,59,59,59,18,63,64,65,66,67,68,69,70,66,72,73,74,75,66,77,78,79,80,66,82,83,84,85,66,87,88,89
    ]
    
    var skeleton : SCNNode? = nil
    var boundingBoxNode : SCNNode? = nil
    var headsUp : SCNNode? = nil
    var joints: [String:SCNNode] = [String:SCNNode]()
    var jointsParentalPath: [Int32: (indice:simd_int4, weight:simd_float4)] = [Int32: (indice:simd_int4, weight:simd_float4)]()
    let riggingJointIndex : [Int] = [
        0, //"root"
    ]
    let boundingBoxIndex : [(startJoint: Int, endJoint: Int, radius: Float)] = [
        (1, 47, 0.5), // "hips_joint" to "neck_1_joint"
        (47, 51, 0.25), // "neck_1_joint" to "head_joint"
        (51, 51, 0.2), // "head_joint" sphere
        (19, 22, 0.25), // "left_shoulder_1_joint" to "left_hand_joint"
        (29, 29, 0.16), // "left_handMid_1_joint" sphere
        (63, 66, 0.25), // "right_shoulder_1_joint" to "right_hand_joint"
        (73, 73, 0.16), // "right_handMid_1_joint" sphere
        (2, 4, 0.4), // "left_upLeg_joint" to "left_foot_joint"
        (4, 6, 0.2), // ""left_foot_joint"" to "left_toesEnd_joint"
        (7, 9, 0.4), // "right_upLeg_joint" to "right_foot_joint"
        (9, 11, 0.2), // ""right_foot_joint"" to "right_toesEnd_joint"
    ]
    
    func cloneNode(anotherHuman: SCNNode) -> Void {
        simdTransform = anotherHuman.simdTransform
        joints.removeAll()
        childNodes.forEach { (child: SCNNode) in
            child.removeFromParentNode()
        }
        anotherHuman.childNodes.forEach { (child: SCNNode) in
            addChildNode(child.clone())
        }
        name = "human"
        skeleton = self.childNode(withName: "skeleton", recursively: true)
        headsUp = self.childNode(withName: "headsUp", recursively: true)
        boundingBoxNode = self.childNode(withName: "boundingBox", recursively: true)
        generateLookupTable()
        for jointIndex in 0..<jointCount {
            let jointName = jointNames[jointIndex]
            let node = skeleton?.childNode(withName: jointName, recursively: true)!
            joints[jointName] = node
        }
    }
    
    func setup() {
        name = "human"
        
        skeleton = SCNNode()
        if let skeleton = skeleton {
            skeleton.name = "skeleton"
            skeleton.renderingOrder = Int.max
            addChildNode(skeleton)
        }
        
        headsUp = SCNNode()
        if let headsUp = headsUp {
            headsUp.name = "headsUp"
            let view : UIView = UIHostingController(rootView: HumanHeadFloatingView().environmentObject(EnvironmentManager.shared.env)).view
            view.backgroundColor = UIColor.clear
            view.frame = CGRect.init(x: 0, y: 0, width: 600, height: 300)
            let parentView = UIView(frame: view.bounds)
            view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            parentView.addSubview(view)
            headsUp.geometry = SCNPlane(width: 0.3, height: 0.15)
            headsUp.geometry?.firstMaterial?.diffuse.contents = parentView
            headsUp.geometry?.firstMaterial?.isDoubleSided = true
            headsUp.isHidden = true
            addChildNode(headsUp)
        }
        
        boundingBoxNode = SCNNode()
        if let boundingBoxNode = boundingBoxNode {
            boundingBoxNode.name = "boundingBox"
            addChildNode(boundingBoxNode)
        }
        
        generateLookupTable()
    }
    
    func generateLookupTable() -> Void {
        for jointIndex in Int32(1)..<Int32(jointCount) {
            var currentJointIndex = jointIndex
            var indiceArray : [Int32] = [currentJointIndex]
            var weightArray : [Float] = []
            for _ in Int32(1)..<Int32(4) {
                currentJointIndex = currentJointIndex >= 0 ? Int32(getParentIndexOfJoint(index: Int(currentJointIndex))) : -1
                indiceArray.append(currentJointIndex)
            }
            switch indiceArray.filter({ index -> Bool in index == -1 }).count { // get count for no parent
            case 0:
                weightArray = [0.7,0.2,0.06,0.04] // joint, joint, joint, joint or root
                break
            case 1:
                weightArray = [0.7,0.2,0.1,0.0] // joint, joint, root
                break
            case 2:
                weightArray = [0.7,0.3,0,0] // joint, root
                break
            case 3:
                weightArray = [1.0,0,0,0] // root
                break
            default:
                break
            }
            let indice : simd_int4 = simd_int4(indiceArray[0], indiceArray[1], indiceArray[2], indiceArray[3])
            let weight : simd_float4 = simd_float4(weightArray[0], weightArray[1], weightArray[2], weightArray[3])
            jointsParentalPath[jointIndex] = (indice, weight)
        }
    }
    
    func getParentIndexOfJoint(index: Int) -> Int {
        return parentIndices[index]
    }
    
    func generateBoundingBoxes() -> Void {
        if let boundingBoxNode = boundingBoxNode {
            boundingBoxNode.childNodes.forEach { (child: SCNNode) in
                child.removeFromParentNode()
            }
            
            boundingBoxIndex.forEach { (item: (startJoint: Int, endJoint: Int, radius: Float)) in
                let startJointName : String = jointNames[item.startJoint]
                let endJointName : String = jointNames[item.endJoint]
                let startJointNode : SCNNode = joints[startJointName]!
                let endJointNode : SCNNode = joints[endJointName]!
                let boxNode = SCNNode()
                boundingBoxNode.addChildNode(boxNode)
                if (item.startJoint == item.endJoint)
                {
                    boxNode.geometry = SCNSphere(radius: CGFloat(item.radius))
                    boxNode.simdWorldPosition = startJointNode.simdWorldPosition
                } else {
                    let distance = simd_distance(startJointNode.simdWorldPosition, endJointNode.simdWorldPosition) + 0.1
                    boxNode.geometry = SCNBox(width: CGFloat(item.radius), height: CGFloat(item.radius), length: CGFloat(distance), chamferRadius: 0)
                    boxNode.simdWorldPosition = (startJointNode.simdWorldPosition + endJointNode.simdWorldPosition) / 2.0
                    boxNode.simdLook(at: endJointNode.simdWorldPosition)
                }
                boxNode.opacity = 0.1
            }
        }
    }
    
    func filterPoints(cloudPointNode: SCNNode) -> Void {
        generateBoundingBoxes()
        if let geometry = cloudPointNode.geometry
        {
            
        }
    }
    
    func rig(cloudPointNode: SCNNode) -> Void
    {
        guard let geometry = cloudPointNode.geometry else {
            return
        }
        let vertex = geometry.sources(for: .vertex).first!
        let vertexCount = vertex.vectorCount
        let data = vertex.data
        var vertexArray = Array<simd_float3>(repeating: simd_float3(0, 0, 0), count: data.count/MemoryLayout<simd_float3>.stride)
        vertexArray.withUnsafeMutableBytes { (pointer: UnsafeMutableRawBufferPointer) -> Void in
            data.copyBytes(to: pointer)
        }
        assert(vertexArray.count == vertexCount)
        var boneWeightsArray : [simd_float4] = []
        var boneIndicesArray : [simd_int4] = []
        
        var jointsDistanceDict : [Int : Float] = [Int : Float]()
        for vertexIndex in 0..<vertexCount {
            jointsDistanceDict.removeAll()
            
            let vertexPos : simd_float3 = vertexArray[vertexIndex]
            let vertexLocalPos = self.simdConvertPosition(vertexPos, from: cloudPointNode)
            for jointIndex in riggingJointIndex {
                let jointName = jointNames[jointIndex]
                let jointNode = joints[jointName]
                let jointLocalPos : simd_float3 = jointNode!.simdConvertPosition(simd_float3(0, 0, 0), to: self)
                let distance = simd_distance(vertexLocalPos, jointLocalPos)
                jointsDistanceDict[jointIndex] = distance
            }
            
            let jointsDistanceDictSorted = jointsDistanceDict.sorted { (p1:(key: Int, value: Float), p2:(key: Int, value: Float)) -> Bool in
                p1.value < p2.value
            }
            let skinJointIndex : Int = jointsDistanceDictSorted.first!.key
            let boneIndice : simd_int4 = jointsParentalPath[Int32(skinJointIndex)]!.indice
            let boneWeight : simd_float4 = jointsParentalPath[Int32(skinJointIndex)]!.weight
            boneIndicesArray.append(boneIndice)
            boneWeightsArray.append(boneWeight)
        }
        
        let boneWeightsData = boneWeightsArray.withUnsafeMutableBufferPointer({ (pointer: inout UnsafeMutableBufferPointer<simd_float4>) -> Data in
            Data(buffer: pointer)
        })
        let boneIndicesData = boneIndicesArray.withUnsafeMutableBufferPointer({ (pointer: inout UnsafeMutableBufferPointer<simd_int4>) -> Data in
            Data(buffer: pointer)
        })
        
        let boneWeightsSource = SCNGeometrySource(data: boneWeightsData, semantic: .boneWeights, vectorCount: vertexCount, usesFloatComponents: true, componentsPerVector: 4, bytesPerComponent: MemoryLayout<Float>.size, dataOffset: 0, dataStride: MemoryLayout<simd_float4>.size)
        let boneIndicesSource = SCNGeometrySource(data: boneIndicesData, semantic: .boneIndices, vectorCount: vertexCount, usesFloatComponents: true, componentsPerVector: 4, bytesPerComponent: MemoryLayout<Int32>.size, dataOffset: 0, dataStride: MemoryLayout<simd_int4>.size)
        let skinner = SCNSkinner(baseGeometry: geometry, bones: Array(joints.values), boneInverseBindTransforms: nil, boneWeights: boneWeightsSource, boneIndices: boneIndicesSource)
        self.geometry = cloudPointNode.geometry
        self.skinner = skinner
    }
    
    func animate(animation: SCNAnimation) -> Void {
        
    }
}
