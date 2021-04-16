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
    
    var joints: [String:SCNNode] = [String:SCNNode]()
    
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
        print("apply frame")
        let hips = joints["hips_joint"]
        frame.joints.forEach { (seg:(key: String, value: simd_float4x4)) in
            if let joint = joints[seg.key],
               let hips = hips
            {
//                print("\(seg.key)")
                joint.simdWorldTransform = hips.simdConvertTransform(seg.value, to: nil)
                let hipRelativePos = hips.simdConvertPosition(joint.simdWorldPosition, from: nil) * 0.012
                joint.simdWorldPosition = hips.simdConvertPosition(hipRelativePos, to: nil)
            } else {
                print("non exist joint")
            }
        }
        drawSkeleton()
        
    }
    
    func drawSkeleton() -> Void {
        for jointIndex in 0..<jointCount { // ignore root
            let name : String = jointNames[jointIndex]
            let parentJointIndex : Int = jointParentIndices[jointIndex]
            if let currentJoint = joints[name],
               let parentJoint = jointIndex == 0 ? skeleton : joints[jointNames[parentJointIndex]]
            {
                let parentJoinPositionInLocal = currentJoint.convertPosition(SCNVector3.init(0, 0, 0), from: parentJoint)
                currentJoint.geometry = SCNGeometry(line: SCNVector3(0,0,0), to: parentJoinPositionInLocal)
                currentJoint.geometry?.firstMaterial?.lightingModel = .constant
                currentJoint.geometry?.firstMaterial?.diffuse.contents = UIColor.white
                let markNode : SCNNode = currentJoint.childNode(withName: "mark", recursively: false) ?? SCNNode().withName(name: "mark")
                markNode.removeFromParentNode()
                currentJoint.addChildNode(markNode)
                markNode.geometry = SCNSphere(radius: 0.01)
                markNode.geometry?.firstMaterial?.lightingModel = .constant
                markNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
            }
        }
    }
    
}
