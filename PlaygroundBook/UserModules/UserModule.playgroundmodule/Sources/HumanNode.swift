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
    var skeleton : SCNNode? = nil
    var boundingBox : SCNNode? = nil
    var headsUp : SCNNode? = nil
    var joints: [String:SCNNode] = [String:SCNNode]()
    var jointsParentalPath: [Int32: (indice:simd_int4, weight:simd_float4)] = [Int32: (indice:simd_int4, weight:simd_float4)]()
    let riggingJointIndex : [Int] = [
        0, //"root"
    ]
    
    func setup() {
        name = "human"
        
        skeleton = SCNNode()
        if let skeleton = skeleton {
            skeleton.name = "skeleton"
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
        
        boundingBox = SCNNode()
        if let boundingBox = boundingBox {
            boundingBox.name = "boundingBox"
            addChildNode(boundingBox)
        }
        
        for jointIndex in Int32(1)..<Int32(ARSkeletonDefinition.defaultBody3D.jointCount) {
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
        return ARSkeletonDefinition.defaultBody3D.parentIndices[index]
    }
    
    func pose(bodyAnchor: ARBodyAnchor, reuse: Bool = false) -> Void {
        if let skeleton = skeleton {
            if !reuse {
                joints.removeAll()
                skeleton.childNodes.forEach { node in
                    node.removeFromParentNode()
                }
            }
            
            self.simdTransform = bodyAnchor.transform
            
            if !reuse {
                for jointIndex in 0..<ARSkeletonDefinition.defaultBody3D.jointCount { // with root
                    let name = ARSkeletonDefinition.defaultBody3D.jointNames[jointIndex]
                    let jointNode : SCNNode = SCNNode()
                    jointNode.name = name
                    joints[name] = jointNode
                }
            }
            
            for jointIndex in 0..<ARSkeletonDefinition.defaultBody3D.jointCount { // ignore root
                let name : String = ARSkeletonDefinition.defaultBody3D.jointNames[jointIndex]
                let parentJointIndex : Int = ARSkeletonDefinition.defaultBody3D.parentIndices[jointIndex]
                if let currentJoint = joints[name],
                   let parentJoint = jointIndex == 0 ? skeleton : joints[ARSkeletonDefinition.defaultBody3D.jointNames[parentJointIndex]]
                {
                    if !reuse {
                        parentJoint.addChildNode(currentJoint)
                    }
                    currentJoint.simdTransform = bodyAnchor.skeleton.jointLocalTransforms[jointIndex]
                    let parentJoinPositionInLocal = currentJoint.convertPosition(SCNVector3.init(0, 0, 0), from: parentJoint)
                    currentJoint.geometry = SCNGeometry(line: SCNVector3(0,0,0), to: parentJoinPositionInLocal)
                    currentJoint.geometry?.firstMaterial?.diffuse.contents = UIColor.white
                    
                    let markNode = SCNNode().withName(name: "mark")
                    markNode.geometry = SCNSphere(radius: 0.01)
                    currentJoint.addChildNode(markNode)
                }
                
            }
            
            if let headsUp = headsUp,
               let headJoint = joints["head_joint"],
               let rootJoint = joints["root"]
            {
//                headsUp.isHidden = joints.count == 0
                headsUp.simdWorldPosition = headJoint.simdWorldPosition + rootJoint.simdWorldUp
            }
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
                let jointName = ARSkeletonDefinition.defaultBody3D.jointNames[jointIndex]
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
    
    //MARK: - SCNCustomNode
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if let pointOfView = renderer.pointOfView,
           let headsUp = headsUp {
            headsUp.simdLook(at: pointOfView.simdPosition)
        }
    }
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
    }
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        let bodies : [ARBodyAnchor] = anchors.compactMap { anchor -> ARBodyAnchor? in
            anchor as? ARBodyAnchor
        }
        if let body = bodies.first {
            print("add body \(body)")
            pose(bodyAnchor: body)
        }
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        let bodies : [ARBodyAnchor] = anchors.compactMap { anchor -> ARBodyAnchor? in
            anchor as? ARBodyAnchor
        }
        if let body = bodies.first {
            print("update body \(body)")
            pose(bodyAnchor: body)
        }
    }
}
