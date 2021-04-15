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
    
    var joints: [String:SCNNode] = [String:SCNNode]()
    var jointsParentalPath: [Int: (indice:SIMD4<uint16>, weight:simd_float4)] = [Int: (indice:SIMD4<uint16>, weight:simd_float4)]()
    let riggingJointIndex : [Int] = [
        0, //"root"
        1, //"hips_joint"
        2, //"left_upLeg_joint"
        7, //"right_upLeg_joint"
        3, //"left_leg_joint"
        8, //"right_leg_joint"
        4, //"left_foot_joint"
//        9, //"right_foot_joint"
//        5, //"left_toes_joint"
//        10, //"right_toes_joint"
//        6, //"left_toesEnd_joint"
//        11, //"right_toesEnd_joint"
        12, //"spine_1_joint"
        13, //"spine_2_joint"
        14, //"spine_3_joint"
//        15, //"spine_4_joint"
//        18, //"spine_7_joint"
//        48, //"neck_2_joint"
//        50, //"neck_4_joint"
//        51, //"head_joint"
//        19, //"left_shoulder_1_joint"
//        63, //"right_shoulder_1_joint"
//        20, //"left_arm_joint"
//        64, //"right_arm_joint"
//        20, //"left_arm_joint"
//        64, //"right_arm_joint"
//        21, //"left_forearm_joint"
//        65, //"right_forearm_joint"
//        22, //"left_hand_joint"
//        66, //"right_forearm_joint"
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
        renderingOrder = Int.max
        simdTransform = anotherHuman.simdTransform
        joints.removeAll()
        childNodes.forEach { (child: SCNNode) in
            child.removeFromParentNode()
        }
        anotherHuman.childNodes.forEach { (child: SCNNode) in
            let clone = child.clone()
            addChildNode(clone)
            clone.transform = child.transform
        }
        name = jointNames[0]
        generateLookupTable()
        joints[name!] = self
        for jointIndex in 1..<jointCount {
            let jointName = jointNames[jointIndex]
            let node = self.childNode(withName: jointName, recursively: true)!
            joints[jointName] = node
        }
    }
    
    func setup() {
        name = jointNames[0]
        renderingOrder = Int.max
        generateLookupTable()
    }
    
    func generateLookupTable() -> Void {
        for jointIndex in 0..<jointCount {
//            var currentJointIndex = jointIndex
//            var indiceArray : [Int] = [currentJointIndex]
//            var weightArray : [Float] = []
//            for _ in 1..<4 {
//                currentJointIndex = getParentIndexOfJoint(index: Int(currentJointIndex))
//                currentJointIndex = max(currentJointIndex, 0)
//                indiceArray.append(currentJointIndex)
//            }
//            switch indiceArray.filter({ index -> Bool in index == 0 }).count { // get count for no parent
//            case 0:
//                weightArray = [0.7,0.2,0.06,0.04] // joint, joint, joint, joint or root
//                break
//            case 1:
//                weightArray = [0.7,0.2,0.1,0.0] // joint, joint, root
//                break
//            case 2:
//                weightArray = [0.7,0.3,0,0] // joint, root
//                break
//            case 3:
//                weightArray = [1.0,0,0,0] // root
//                break
//            default:
//                break
//            }
            
            var currentJointIndex = jointIndex
            var indiceArray : [Int] = [currentJointIndex, 0,0,0]
            var weightArray : [Float] = [1.0,0,0,0]
            
            let indice : SIMD4<uint16> = SIMD4<uint16>(uint16(indiceArray[0]), uint16(indiceArray[1]), uint16(indiceArray[2]), uint16(indiceArray[3]))
            let weight : simd_float4 = simd_float4(weightArray[0], weightArray[1], weightArray[2], weightArray[3])
            jointsParentalPath[jointIndex] = (indice, weight)
        }
    }
    
    func getParentIndexOfJoint(index: Int) -> Int {
        return parentIndices[index]
    }
    
    func generateBoundingBoxes() -> Void {
//        if let boundingBoxNode = boundingBoxNode {
//            boundingBoxNode.childNodes.forEach { (child: SCNNode) in
//                child.removeFromParentNode()
//            }
//
//            boundingBoxIndex.forEach { (item: (startJoint: Int, endJoint: Int, radius: Float)) in
//                let startJointName : String = jointNames[item.startJoint]
//                let endJointName : String = jointNames[item.endJoint]
//                let startJointNode : SCNNode = joints[startJointName]!
//                let endJointNode : SCNNode = joints[endJointName]!
//                let boxNode = SCNNode()
//                boundingBoxNode.addChildNode(boxNode)
//                if (item.startJoint == item.endJoint)
//                {
//                    boxNode.geometry = SCNSphere(radius: CGFloat(item.radius))
//                    boxNode.simdWorldPosition = startJointNode.simdWorldPosition
//                } else {
//                    let distance = simd_distance(startJointNode.simdWorldPosition, endJointNode.simdWorldPosition) + 0.1
//                    boxNode.geometry = SCNBox(width: CGFloat(item.radius), height: CGFloat(item.radius), length: CGFloat(distance), chamferRadius: 0)
//                    boxNode.simdWorldPosition = (startJointNode.simdWorldPosition + endJointNode.simdWorldPosition) / 2.0
//                    boxNode.simdLook(at: endJointNode.simdWorldPosition)
//                }
//                boxNode.isHidden = true
//            }
//        }
    }
    
    func filterPoints(cloudPointNode: SCNNode) -> Void {
        guard let geometry = cloudPointNode.geometry else {
            print("error")
            return
        }
        var color = geometry.sources(for: .color).first!
        let colorData = color.data
        var vertex = geometry.sources(for: .vertex).first!
        let vertexData = vertex.data
        
        let initialCount : Int = vertex.vectorCount
        var finalCount : Int  = 0
        
        assert(vertex.vectorCount == color.vectorCount)
        
        assert(vertexData.count/MemoryLayout<SCNVector3>.stride == vertex.vectorCount)
        var vertexArray = Array<SCNVector3>(repeating: SCNVector3(0, 0, 0), count: vertex.vectorCount)
        var newVertexArray : [SCNVector3] = []
        vertexArray.withUnsafeMutableBytes { (pointer: UnsafeMutableRawBufferPointer) -> Void in
            vertexData.copyBytes(to: pointer)
        }
        
        assert(colorData.count/MemoryLayout<SCNVector3>.stride == color.vectorCount)
        var colorArray = Array<SCNVector3>(repeating: SCNVector3(0, 0, 0), count: color.vectorCount)
        var newColorArray : [SCNVector3] = []
        colorArray.withUnsafeMutableBytes { (pointer: UnsafeMutableRawBufferPointer) -> Void in
            colorData.copyBytes(to: pointer)
        }
        
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
                newVertexArray.append(vertexArray[i])
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
    }
    
    func rig(cloudPointNode: SCNNode) -> Void
    {
        guard let geometry = cloudPointNode.geometry else {
            return
        }
        let color = geometry.sources(for: .color).first!
        var vertex = geometry.sources(for: .vertex).first!
        let vertexCount = vertex.vectorCount
        var vertexData = vertex.data
        
        var vertexArray = Array<SCNVector3>(repeating: SCNVector3(0, 0, 0), count: vertexData.count/MemoryLayout<SCNVector3>.stride)
        vertexArray.withUnsafeMutableBytes { (pointer: UnsafeMutableRawBufferPointer) -> Void in
            vertexData.copyBytes(to: pointer)
        }
        assert(vertexArray.count == vertexCount)
        var boneWeightsArray : [simd_float4] = []
        var boneIndicesArray : [SIMD4<uint16>] = []
        
        var jointsDistanceDict : [Int : Float] = [Int : Float]()
        for vertexIndex in 0..<vertexCount {
            jointsDistanceDict.removeAll()
            let vertexPosInScanSpace : simd_float3 = simd_float3(vertexArray[vertexIndex])
            let vertexPosInSkeletonSpace = self.simdConvertPosition(vertexPosInScanSpace, from: cloudPointNode)
            for jointIndex in riggingJointIndex {
                let jointName = jointNames[jointIndex]
                let jointNode = joints[jointName]
                let jointPosInSkeletonSpace : simd_float3 = self.simdConvertPosition(simd_float3(0, 0, 0), from: jointNode)
                let distance = simd_distance(vertexPosInSkeletonSpace, jointPosInSkeletonSpace)
                jointsDistanceDict[jointIndex] = distance
            }
            
            let jointsDistanceDictSorted = jointsDistanceDict.sorted { (p1:(key: Int, value: Float), p2:(key: Int, value: Float)) -> Bool in
                p1.value < p2.value
            }
            let skinJointIndex : Int = jointsDistanceDictSorted.first!.key
            let boneIndice : SIMD4<uint16> = jointsParentalPath[skinJointIndex]!.indice
            let boneWeight : simd_float4 = jointsParentalPath[skinJointIndex]!.weight
            boneIndicesArray.append(boneIndice)
            boneWeightsArray.append(boneWeight)
            
            vertexArray[vertexIndex] = SCNVector3(vertexPosInSkeletonSpace)
        }
        
        let boneWeightsData = boneWeightsArray.withUnsafeMutableBufferPointer({ (pointer: inout UnsafeMutableBufferPointer<simd_float4>) -> Data in
            Data(buffer: pointer)
        })
        let boneIndicesData = boneIndicesArray.withUnsafeMutableBufferPointer({ (pointer: inout UnsafeMutableBufferPointer<SIMD4<uint16>>) -> Data in
            Data(buffer: pointer)
        })
        vertexData = vertexArray.withUnsafeMutableBufferPointer({ (pointer: inout UnsafeMutableBufferPointer<SCNVector3>) -> Data in
            Data(buffer: pointer)
        })
        
        let boneWeightsSource = SCNGeometrySource(data: boneWeightsData, semantic: .boneWeights, vectorCount: vertexCount, usesFloatComponents: true, componentsPerVector: 4, bytesPerComponent: MemoryLayout<Float>.size, dataOffset: 0, dataStride: MemoryLayout<simd_float4>.size)
        let boneIndicesSource = SCNGeometrySource(data: boneIndicesData, semantic: .boneIndices, vectorCount: vertexCount, usesFloatComponents: true, componentsPerVector: 4, bytesPerComponent: MemoryLayout<uint16>.size, dataOffset: 0, dataStride: MemoryLayout<SIMD4<uint16>>.size)
        let bones : [SCNNode] = riggingJointIndex.map({ (boneIndex:Int) -> SCNNode in
            joints[jointNames[boneIndex]]!
        })
        let boneInverseBindTransforms : [NSValue] = bones.map { (joint: SCNNode) -> NSValue in
            NSValue(scnMatrix4: SCNMatrix4Invert(joint.transform))
        }
        
        vertex = SCNGeometrySource(data: vertexData, semantic: .vertex, vectorCount: vertexCount, usesFloatComponents: true, componentsPerVector: 3, bytesPerComponent: MemoryLayout<Float>.size, dataOffset: 0, dataStride: MemoryLayout<SCNVector3>.size)
        
        let newGeometry = SCNGeometry(sources: [color, vertex], elements: geometry.elements)
        newGeometry.firstMaterial?.lightingModel = .constant
        newGeometry.firstMaterial?.diffuse.contents = UIColor.white
        
        let skinner = SCNSkinner(baseGeometry: newGeometry, bones: bones, boneInverseBindTransforms: boneInverseBindTransforms, boneWeights: boneWeightsSource, boneIndices: boneIndicesSource)
        skinner.skeleton = self
        
        cloudPointNode.simdWorldTransform = self.simdWorldTransform
        cloudPointNode.geometry = newGeometry
        cloudPointNode.skinner = skinner
    }
    
    func animate(animation: SCNAnimation) -> Void {
        
    }
}
