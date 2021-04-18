//
//  HumanNode.swift
//  UserModuleFramework
//
//  Created by fincher on 4/13/21.
//

import Foundation
import SceneKit
import ARKit
import SwiftUI

class HumanNode: SCNNode, SCNCustomNode
{
    override class var supportsSecureCoding: Bool {
        return true
    }
    
    var skeleton : SCNNode? = nil
    var joints: [String:SCNNode] = [String:SCNNode]()
    var animation : ARKitSkeletonAnimation? = nil
    
    func reset() -> Void {
        joints.removeAll()
        childNodes.forEach { (child: SCNNode) in
            child.removeFromParentNode()
        }
        animation = nil
    }
    
    func setup() {
        name = "human"
        skeleton = self.childNode(withName: "skeleton", recursively: false) ?? SCNNode().withName(name: "skeleton").withParent(parent: self)
        
        for jointIndex in 0..<jointCount {
            let jointName = jointNames[jointIndex]
            let node = self.childNode(withName: jointName, recursively: true) ?? SCNNode().withName(name: jointName)
            joints[jointName] = node
        }
        
        for jointIndex in 0..<jointCount {
            let jointName = jointNames[jointIndex]
            if let currentJoint = joints[jointName], let parentJoint = jointIndex == 0 ? skeleton : joints[jointNames[jointParentIndices[jointIndex]]]
            {
                parentJoint.addChildNode(currentJoint)
            }
        }
    }
    
    func setPose(bodyAnchor: ARBodyAnchor) -> Void {
        self.simdTransform = bodyAnchor.transform
        for jointIndex in 0..<jointCount {
            let jointName : String = jointNames[jointIndex]
            if let currentJoint = joints[jointName]
            {
                let extendedIndex = ARSkeletonDefinition.defaultBody3D.jointNames.firstIndex(of: jointName)
                currentJoint.simdWorldTransform = self.simdConvertTransform(bodyAnchor.skeleton.jointModelTransforms[extendedIndex!], to: nil)
            }
        }
        addMarker()
    }
    
    func addMarker() -> Void {
        for jointIndex in 0..<jointCount {
            let name : String = jointNames[jointIndex]
            let parentJointIndex : Int = jointParentIndices[jointIndex]
            if let currentJoint = joints[name],
               let parentJoint = jointIndex == 0 ? skeleton : joints[jointNames[parentJointIndex]]
            {
                let parentJoinPositionInLocal = currentJoint.convertPosition(SCNVector3.init(0, 0, 0), from: parentJoint)
                currentJoint.geometry = SCNGeometry(line: SCNVector3(0,0,0), to: parentJoinPositionInLocal).withWhiteMaterial()
                let markNode : SCNNode = currentJoint.childNode(withName: "mark", recursively: false) ?? SCNNode().withName(name: "mark").withParent(parent: currentJoint)
                markNode.geometry = SCNSphere(radius: 0.01).withWhiteMaterial()
            }
        }
    }
    
    func removeMarker() -> Void {
        self.enumerateChildNodes { (child:SCNNode, stop:UnsafeMutablePointer<ObjCBool>) in
            if let childName = child.name
            {
                if joints.keys.contains(childName)
                {
                    child.geometry = nil
                } else if name == "mark" {
                    child.removeFromParentNode()
                }
            }
        }
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
        
        let indices = finalCount == 0 ? [] : Array(0...Int32(finalCount - 1))
        let indiceData = indices.withUnsafeBufferPointer { Data(buffer: $0) }
        let element = SCNGeometryElement(data: indiceData, primitiveType: .point, primitiveCount: finalCount, bytesPerIndex: MemoryLayout<Int32>.size)
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
        removeMarker()
        
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
                    containBoneIndexes.count > 0 ? volumeValues[containBoneIndexes[0]]!/weightSum : 0.0,
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
        assert(boneWeightsData.count / MemoryLayout<simd_float4>.size == boneWeightsArray.count)
        assert(boneIndicesData.count / MemoryLayout<SIMD4<UInt16>>.size == boneIndicesArray.count)
        assert(vertex.vectorCount == boneWeightsArray.count)
        assert(vertex.vectorCount == boneIndicesArray.count)
        
        let boneWeightsSource = SCNGeometrySource(data: boneWeightsData, semantic: .boneWeights, vectorCount: boneWeightsArray.count, usesFloatComponents: true, componentsPerVector: 4, bytesPerComponent: MemoryLayout<Float>.size, dataOffset: 0, dataStride: MemoryLayout<simd_float4>.size)
        let boneIndicesSource = SCNGeometrySource(data: boneIndicesData, semantic: .boneIndices, vectorCount: boneIndicesArray.count, usesFloatComponents: true, componentsPerVector: 4, bytesPerComponent: MemoryLayout<UInt16>.size, dataOffset: 0, dataStride: MemoryLayout<SIMD4<UInt16>>.size)
        
        assert(MemoryLayout<SIMD4<UInt16>>.size == MemoryLayout<UInt16>.size * 4)
        
        let bones : [SCNNode] = (0..<jointCount).map({ (boneIndex:Int) -> SCNNode in
            joints[jointNames[boneIndex]]!
        })
        
        let boneInverseBindTransforms : [NSValue] = bones.map { (joint: SCNNode) -> NSValue in
            NSValue(scnMatrix4: SCNMatrix4Invert(self.convertTransform(SCNMatrix4Identity, from: joint)))
        }
        
        let newGeometry = geometry.withPointSize(size: 15)
        
        let skinner = SCNSkinner(baseGeometry: newGeometry, bones: bones, boneInverseBindTransforms: boneInverseBindTransforms, boneWeights: boneWeightsSource, boneIndices: boneIndicesSource)
        
        skinner.skeleton = joints[jointNames[0]]
        cloudPointNode.geometry = newGeometry
        cloudPointNode.skinner = skinner
    }
    
    func setPose(frame: ARKitSkeletonAnimationFrame) -> Void {
        print("apply frame")
        frame.joints.forEach { (seg:(key: Int, value: simd_float4x4)) in
            if let joint = joints[jointNames[seg.key]] {
                joint.simdTransform = seg.value
            }
        }
    }
    
    func getPose() -> ARKitSkeletonAnimationFrame {
        print("gather frame")
        var dict : Dictionary<Int, simd_float4x4> = Dictionary<Int, simd_float4x4>()
        for jointIndex in 0..<jointCount {
            if let node = joints[jointNames[jointIndex]]
            {
                dict[jointIndex] = node.simdTransform
            }
        }
        return ARKitSkeletonAnimationFrame(joints: dict)
    }
    
    func exportAnimationAndReturnURL() -> URL? {
        do {
            let jsonData = try JSONEncoder().encode(animation)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            
            let tempDirPath = FileManager.default.temporaryDirectory
            let tempFileURL = tempDirPath.appendingPathComponent("animation.json", isDirectory: false)
            
            try jsonString.write(to: tempFileURL, atomically: true, encoding: .utf8)
            return tempFileURL
        } catch let error {
            print(error)
        }
        return nil
    }
    
    func loadAnimation(url : URL) -> Void {
        do {
            let json = try String(contentsOf: url)
            if let data = json.data(using: .utf8)
            {
                let an = try JSONDecoder().decode(ARKitSkeletonAnimation.self, from: data)
                self.animation = an
            }
        } catch let err {
            print(err)
        }
    }
    
    //MARK: - SCNCustomNode
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        switch EnvironmentManager.shared.env.arOperationMode {
        case .attachPointCloud:
            break
        case .captureSekeleton:
            break
        case .removeBgAndRig:
            break
        case .animateSkeleton:
            if animation?.frames.count ?? 0 > 0 {
                print("frame \(animation?.frames.count ?? 0)")
                setPose(frame: (animation?.frames[0])!)
                animation?.removeFirstFrame()
            }
            break
        case .positionSekeleton:
            break
        case .recordAnimation:
            if animation == nil {
                animation = ARKitSkeletonAnimation(frames: [])
            }
            print("frame \(animation?.frames.count ?? 0)")
            animation?.addFrame(frame: self.getPose())
            break
        }
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        switch EnvironmentManager.shared.env.arOperationMode {
        case .attachPointCloud:
            break
        case .captureSekeleton:
            break
        case .removeBgAndRig:
            break
        case .animateSkeleton:
            break
        case .positionSekeleton:
            simdWorldPosition = simdWorldPosition + simd_float3(
                Float(EnvironmentManager.shared.env.positionAddX * 0.005),
                Float(EnvironmentManager.shared.env.positionAddY * 0.005),
                Float(EnvironmentManager.shared.env.positionAddZ * 0.005))
            break
        case .recordAnimation:
            break
        }
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        switch EnvironmentManager.shared.env.arOperationMode {
        case .attachPointCloud:
            break
        case .captureSekeleton, .recordAnimation:
            if let body = anchors.compactMap({ anchor -> ARBodyAnchor? in
                anchor as? ARBodyAnchor
            }).first {
                setPose(bodyAnchor: body)
            }
            break
        case .removeBgAndRig:
            break
        case .animateSkeleton:
            break
        case .positionSekeleton:
            break
        }
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        switch EnvironmentManager.shared.env.arOperationMode {
        case .attachPointCloud:
            break
        case .captureSekeleton, .recordAnimation:
            if let body = anchors.compactMap({ anchor -> ARBodyAnchor? in
                anchor as? ARBodyAnchor
            }).first {
                setPose(bodyAnchor: body)
            }
            break
        case .removeBgAndRig:
            break
        case .animateSkeleton:
            break
        case .positionSekeleton:
            break
        }
        
    }
}
