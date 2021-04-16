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
    
    var skeleton : SCNNode? = nil
    var boundingBoxNode : SCNNode? = nil
    var headsUp : SCNNode? = nil
    
    var jointCount = 91
    var jointNames : [String] = [
        "root","hips_joint","left_upLeg_joint","left_leg_joint","left_foot_joint","left_toes_joint","left_toesEnd_joint","right_upLeg_joint","right_leg_joint","right_foot_joint","right_toes_joint","right_toesEnd_joint","spine_1_joint","spine_2_joint","spine_3_joint","spine_4_joint","spine_5_joint","spine_6_joint","spine_7_joint","left_shoulder_1_joint","left_arm_joint","left_forearm_joint","left_hand_joint","left_handIndexStart_joint","left_handIndex_1_joint","left_handIndex_2_joint","left_handIndex_3_joint","left_handIndexEnd_joint","left_handMidStart_joint","left_handMid_1_joint","left_handMid_2_joint","left_handMid_3_joint","left_handMidEnd_joint","left_handPinkyStart_joint","left_handPinky_1_joint","left_handPinky_2_joint","left_handPinky_3_joint","left_handPinkyEnd_joint","left_handRingStart_joint","left_handRing_1_joint","left_handRing_2_joint","left_handRing_3_joint","left_handRingEnd_joint","left_handThumbStart_joint","left_handThumb_1_joint","left_handThumb_2_joint","left_handThumbEnd_joint","neck_1_joint","neck_2_joint","neck_3_joint","neck_4_joint","head_joint","jaw_joint","chin_joint","left_eye_joint","left_eyeLowerLid_joint","left_eyeUpperLid_joint","left_eyeball_joint","nose_joint","right_eye_joint","right_eyeLowerLid_joint","right_eyeUpperLid_joint","right_eyeball_joint","right_shoulder_1_joint","right_arm_joint","right_forearm_joint","right_hand_joint","right_handIndexStart_joint","right_handIndex_1_joint","right_handIndex_2_joint","right_handIndex_3_joint","right_handIndexEnd_joint","right_handMidStart_joint","right_handMid_1_joint","right_handMid_2_joint","right_handMid_3_joint","right_handMidEnd_joint","right_handPinkyStart_joint","right_handPinky_1_joint","right_handPinky_2_joint","right_handPinky_3_joint","right_handPinkyEnd_joint","right_handRingStart_joint","right_handRing_1_joint","right_handRing_2_joint","right_handRing_3_joint","right_handRingEnd_joint","right_handThumbStart_joint","right_handThumb_1_joint","right_handThumb_2_joint","right_handThumbEnd_joint"
    ]
    
    var parentIndices : [Int] = [
        -1,0,1,2,3,4,5,1,7,8,9,10,1,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,22,28,29,30,31,22,33,34,35,36,22,38,39,40,41,22,43,44,45,18,47,48,49,50,51,52,51,54,54,54,51,51,59,59,59,18,63,64,65,66,67,68,69,70,66,72,73,74,75,66,77,78,79,80,66,82,83,84,85,66,87,88,89
    ]
    
    var joints: [String:SCNNode] = [String:SCNNode]()
    let riggingVolumeIndex : [(startJoint: Int, endJoint: Int, radius: Float)] = [
        (1, 1, 0.3), // hips_joint
        
        (2, 2, 0.25), // left_upLeg_joint
        (2, 3, 0.2), // left_upLeg_joint to left_leg_joint
        (3, 4, 0.2), // left_leg_joint to left_foot_joint
        (4, 5, 0.2), // left_foot_joint to left_toes_joint
        (5, 6, 0.15), // left_toes_joint to left_toesEnd_joint
        
        (7, 7, 0.25), // right_upLeg_joint
        (7, 8, 0.2), // right_upLeg_joint to right_leg_joint
        (8, 9, 0.2), // right_leg_joint to right_foot_joint
        (9, 10, 0.2), // right_foot_joint to right_toes_joint
        (10, 11, 0.15), // right_toes_joint to right_toesEnd_joint
        
        (12, 15, 0.25), // spine_1_joint to spine_4_joint
        (15, 18, 0.2), // spine_4_joint to spine_7_joint
        (18, 47, 0.15), // spine_7_joint to neck_1_joint
        
        (47, 49, 0.12), // neck_1_joint to neck_3_joint
        (49, 51, 0.12), // neck_3_joint to head_joint
        (51, 51, 0.15), // head_joint
        
        (19, 20, 0.2), // left_shoulder_1_joint to left_arm_joint
        (20, 21, 0.18), // left_arm_joint to left_forearm_joint
        (21, 22, 0.16), // left_forearm_joint to left_hand_joint
        (22, 22, 0.2), // left_hand_joint
        
        (63, 64, 0.2), // right_shoulder_1_joint to right_arm_joint
        (64, 65, 0.18), // right_arm_joint to right_forearm_joint
        (65, 66, 0.16), // right_forearm_joint to right_hand_joint
        (66, 66, 0.2), // right_hand_joint
    ]
    let boundingBoxIndex : [(startJoint: Int, endJoint: Int, radius: Float)] = [
        (1, 47, 0.5), // "hips_joint" to "neck_1_joint"
        (47, 51, 0.25), // "neck_1_joint" to "head_joint"
        (51, 51, 0.2), // "head_joint" sphere
        (19, 22, 0.25), // "left_shoulder_1_joint" to "left_hand_joint"
        (29, 29, 0.16), // "left_handMid_1_joint" sphere
        (63, 66, 0.25), // "right_shoulder_1_joint" to "right_hand_joint"
        (73, 73, 0.16), // "right_handMid_1_joint" sphere
        (2, 4, 0.1), // "left_upLeg_joint" to "left_foot_joint"
        (4, 6, 0.1), // ""left_foot_joint"" to "left_toesEnd_joint"
        (7, 9, 0.1), // "right_upLeg_joint" to "right_foot_joint"
        (9, 11, 0.1), // ""right_foot_joint"" to "right_toesEnd_joint"
    ]
    
    func cloneNode(anotherHuman: SCNNode) -> Void {
        simdTransform = anotherHuman.simdTransform
        joints.removeAll()
        childNodes.forEach { (child: SCNNode) in
            child.removeFromParentNode()
        }
        anotherHuman.childNodes.forEach { (child: SCNNode) in
            let clone = child.clone()
            addChildNode(clone)
            clone.simdWorldTransform = child.simdWorldTransform
        }
        name = "human"
        skeleton = self.childNode(withName: "skeleton", recursively: true)
        headsUp = self.childNode(withName: "headsUp", recursively: true)
        boundingBoxNode = self.childNode(withName: "boundingBox", recursively: true)
        for jointIndex in 0..<jointCount {
            let jointName = jointNames[jointIndex]
            let node = self.childNode(withName: jointName, recursively: true)!
            joints[jointName] = node
        }
        renderingOrder = Int.max
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
        
        renderingOrder = Int.max
    }
    
    func getParentIndexOfJoint(index: Int) -> Int {
        return parentIndices[index]
    }
    
    func filterPoints(cloudPointNode: SCNNode) -> Void {
        guard let geometry = cloudPointNode.geometry else {
            print("error")
            return
        }
        var color = geometry.sources(for: .color).first!
        var colorData = color.data
        var vertex = geometry.sources(for: .vertex).first!
        var vertexData = vertex.data
        
        let initialCount : Int = vertex.vectorCount
        var finalCount : Int  = 0
        
        assert(vertex.vectorCount == color.vectorCount)
        
        var vertexArray : [SCNVector3] = []
        vertexData.withUnsafeMutableBytes { (pointer : UnsafeMutableRawBufferPointer) -> Void in
            for i in 0..<vertex.vectorCount
            {
                vertexArray.append(pointer.load(fromByteOffset: i * vertex.dataStride + vertex.dataOffset, as: SCNVector3.self))
            }
        }
        assert(vertexArray.count == vertex.vectorCount)
        
        var colorArray : [SCNVector3] = []
        colorData.withUnsafeMutableBytes { (pointer : UnsafeMutableRawBufferPointer) -> Void in
            for i in 0..<color.vectorCount
            {
                colorArray.append(pointer.load(fromByteOffset: i * color.dataStride + color.dataOffset, as: SCNVector3.self))
            }
        }
        assert(colorArray.count == color.vectorCount)
        
        var newVertexArray : [SCNVector3] = []
        var newColorArray : [SCNVector3] = []
        
        for i in 0..<initialCount {
            var withInSDF = false
            let vertexWorldPosition : simd_float3 = cloudPointNode.simdConvertPosition(simd_float3(vertexArray[i]), to: nil)
            for b in 0..<boundingBoxIndex.count {
                let bounding : (startJoint: Int, endJoint: Int, radius: Float) = boundingBoxIndex[b]
                let startJointName : String = jointNames[bounding.startJoint]
                let startJointNode : SCNNode = joints[startJointName]!
                let startJointWorldPosition = startJointNode.simdConvertPosition(simd_float3(0,0,0), to: nil)
                if (bounding.startJoint == bounding.endJoint)
                {
                    // sdf sphere
                    withInSDF = withInSDF || (sdSphere(p: vertexWorldPosition, c: startJointWorldPosition, r: bounding.radius) <= 0)
                } else {
                    // sdf cone
                    let endJointName : String = jointNames[bounding.endJoint]
                    let endJointNode : SCNNode = joints[endJointName]!
                    let endJointWorldPosition = endJointNode.simdConvertPosition(simd_float3(0,0,0), to: nil)
                    withInSDF = withInSDF || (sdCapsule(p: vertexWorldPosition, a: startJointWorldPosition, b: endJointWorldPosition, r: bounding.radius) <= 0)
                }
                if withInSDF { break }
            }
            if withInSDF {
                newVertexArray.append(self.convertPosition(vertexArray[i], from: cloudPointNode))
                newColorArray.append(colorArray[i])
            }
        }
        
        assert(newVertexArray.count == newColorArray.count)
        finalCount = newVertexArray.count
        
        color = SCNGeometrySource(data: newColorArray.withUnsafeMutableBufferPointer({ (pointer: inout UnsafeMutableBufferPointer<SCNVector3>) -> Data in
            Data(buffer: pointer)
        }), semantic: .color, vectorCount: finalCount, usesFloatComponents: true, componentsPerVector: 3, bytesPerComponent: MemoryLayout<Float>.size, dataOffset: 0, dataStride: MemoryLayout<SCNVector3>.size)
        vertex = SCNGeometrySource(data: newVertexArray.withUnsafeMutableBufferPointer({ (pointer: inout UnsafeMutableBufferPointer<SCNVector3>) -> Data in
            Data(buffer: pointer)
        }), semantic: .vertex, vectorCount: finalCount, usesFloatComponents: true, componentsPerVector: 3, bytesPerComponent: MemoryLayout<Float>.size, dataOffset: 0, dataStride: MemoryLayout<SCNVector3>.size)
        
        let indices = Array(ClosedRange<Int32>.init(0..<Int32(finalCount)))
        let indiceData = indices.withUnsafeBufferPointer { Data(buffer: $0) }
        let element = SCNGeometryElement(data: indiceData, primitiveType: .point, primitiveCount: finalCount, bytesPerIndex: MemoryLayout.size(ofValue: Int32(0)))
        element.pointSize = 15
        element.minimumPointScreenSpaceRadius = 2
        element.maximumPointScreenSpaceRadius = 15
        
        let newGeometry = SCNGeometry(sources: [color, vertex], elements: [element])
        newGeometry.firstMaterial?.lightingModel = .constant
        newGeometry.firstMaterial?.diffuse.contents = UIColor.white
        cloudPointNode.geometry = newGeometry
        cloudPointNode.simdWorldTransform = self.simdWorldTransform
    }
    
    func rig(cloudPointNode: SCNNode) -> Void
    {
        guard let geometry = cloudPointNode.geometry else {
            return
        }
        
        let vertex = geometry.sources(for: .vertex).first!
        var vertexData = vertex.data
        var boneWeightsArray : [simd_float4] = []
        var boneIndicesArray : [SIMD4<UInt16>] = []
        var boneSet : Set<SCNNode> = Set()
        
        vertexData.withUnsafeMutableBytes { (pointer : UnsafeMutableRawBufferPointer) -> Void in
            for i in 0..<vertex.vectorCount
            {
                let vertex = pointer.load(fromByteOffset: i * vertex.dataStride + vertex.dataOffset, as: SCNVector3.self)
                let vertexWorldPosition = cloudPointNode.convertPosition(vertex, to: nil)
                let vertexWorldPositionSIMD = simd_float3(vertexWorldPosition)
                
                var volumeValues : Dictionary<Int,Float> = Dictionary()
                for rigVolumeIndex in 0..<riggingVolumeIndex.count
                {
                    if volumeValues.count >= 4 {
                        break
                    }
                    let volume:(startJoint: Int, endJoint: Int, radius: Float) = riggingVolumeIndex[rigVolumeIndex]
                    let startJointNode : SCNNode = joints[jointNames[volume.startJoint]]!
                    let startJointWorldPosition = startJointNode.convertPosition(SCNVector3(0,0,0), to: nil)
                    let startJointWorldPositionSIMD = simd_float3(startJointWorldPosition)
                    boneSet.insert(startJointNode)
                    var sdfRes : Float = 0.0
                    if (volume.startJoint == volume.endJoint)
                    {
                        let endJointNode : SCNNode = joints[jointNames[volume.endJoint]]!
                        let endJointWorldPosition = endJointNode.convertPosition(SCNVector3(0,0,0), to: nil)
                        let endJointWorldPositionSIMD = simd_float3(endJointWorldPosition)
                        boneSet.insert(endJointNode)
                        sdfRes = sdCapsule(p: vertexWorldPositionSIMD, a: startJointWorldPositionSIMD, b: endJointWorldPositionSIMD, r: volume.radius)
                    } else {
                        sdfRes = sdSphere(p: vertexWorldPositionSIMD, c: startJointWorldPositionSIMD, r: volume.radius)
                    }
                    if sdfRes <= 0
                    {
                        volumeValues[volume.startJoint] = sdfRes
                    }
                }
                let containBoneIndexes : [Int] = Array(volumeValues.keys).sorted(by: {volumeValues[$0]! < volumeValues[$1]!}) // sdf values are negative, so smallest actually is deepest
                let weightSum = volumeValues.values.reduce(0, +)
                
                let weight : simd_float4 = simd_float4(
                    containBoneIndexes.count > 0 ? volumeValues[containBoneIndexes[0]]!/weightSum : 1.0,
                    containBoneIndexes.count > 1 ? volumeValues[containBoneIndexes[1]]!/weightSum : 0.0,
                    containBoneIndexes.count > 2 ? volumeValues[containBoneIndexes[2]]!/weightSum : 0.0,
                    containBoneIndexes.count > 3 ? volumeValues[containBoneIndexes[3]]!/weightSum : 0.0
                )
                let indice : SIMD4<UInt16> = SIMD4<UInt16>(
                    containBoneIndexes.count > 0 ? UInt16(containBoneIndexes[0]) : 0,
                    containBoneIndexes.count > 1 ? UInt16(containBoneIndexes[1]) : 0,
                    containBoneIndexes.count > 2 ? UInt16(containBoneIndexes[2]) : 0,
                    containBoneIndexes.count > 3 ? UInt16(containBoneIndexes[3]) : 0
                )
                boneWeightsArray.append(weight)
                boneIndicesArray.append(indice)
            }
        }
        
        
        let boneWeightsData = boneWeightsArray.withUnsafeMutableBufferPointer({ (pointer: inout UnsafeMutableBufferPointer<simd_float4>) -> Data in
            Data(buffer: pointer)
        })
        let boneIndicesData = boneIndicesArray.withUnsafeMutableBufferPointer({ (pointer: inout UnsafeMutableBufferPointer<SIMD4<UInt16>>) -> Data in
            Data(buffer: pointer)
        })
        
        let boneWeightsSource = SCNGeometrySource(data: boneWeightsData, semantic: .boneWeights, vectorCount: boneWeightsArray.count, usesFloatComponents: true, componentsPerVector: 4, bytesPerComponent: MemoryLayout<Float>.size, dataOffset: 0, dataStride: MemoryLayout<simd_float4>.size)
        let boneIndicesSource = SCNGeometrySource(data: boneIndicesData, semantic: .boneIndices, vectorCount: boneIndicesArray.count, usesFloatComponents: true, componentsPerVector: 4, bytesPerComponent: MemoryLayout<UInt16>.size, dataOffset: 0, dataStride: MemoryLayout<SIMD4<UInt16>>.size)
        
        assert(MemoryLayout<SIMD4<UInt16>>.size == MemoryLayout<UInt16>.size * 4)
        
        let bones : [SCNNode] = getBones()

        let boneInverseBindTransforms : [NSValue] = bones.map { (joint: SCNNode) -> NSValue in
            NSValue(scnMatrix4: SCNMatrix4Invert(self.convertTransform(SCNMatrix4Identity, from: joint)))
        }
        
        let skinner = SCNSkinner(baseGeometry: geometry, bones: bones, boneInverseBindTransforms: boneInverseBindTransforms, boneWeights: boneWeightsSource, boneIndices: boneIndicesSource)
        
        skinner.skeleton = joints["hips_joint"]
        cloudPointNode.skinner = skinner
    }
    
    func getBones() -> [SCNNode] {
        let bones : [SCNNode] = (0..<jointCount).map({ (boneIndex:Int) -> SCNNode in
            joints[jointNames[boneIndex]]!
        })
        return bones
    }
    
    func apply(frame: ARKitSkeletonAnimationFrame) -> Void {
        let hips = joints["hips_joint"]
        frame.joints.forEach { (seg:(key: String, value: simd_float4x4)) in
            if let joint = joints[seg.key],
               let hips = hips
            {
                joint.simdWorldTransform = hips.simdConvertTransform(seg.value, to: nil)
            } else {
                print("non exist joint")
            }
        }
    }
    
}
