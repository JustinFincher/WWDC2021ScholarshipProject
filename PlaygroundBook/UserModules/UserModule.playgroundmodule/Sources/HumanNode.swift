//
//  HumanNode.swift
//  UserModuleFramework
//
//  Created by fincher on 4/13/21.
//

import Foundation
import SceneKit
import ARKit

class HumanNode: SCNNode
{
    var skeletonRoot : SCNNode? = nil
    
    override init() {
        super.init()
        postInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func postInit() -> Void {
        name = "human"
        skeletonRoot = SCNNode()
        if let skeletonRoot = skeletonRoot {
            skeletonRoot.name = "skeleton"
            addChildNode(skeletonRoot)
        }
    }
    
    func update(bodyAnchor: ARBodyAnchor) -> Void {
        if let skeletonRoot = skeletonRoot {
            skeletonRoot.childNodes.forEach { node in
                node.removeFromParentNode()
            }
            self.simdTransform = bodyAnchor.transform
            var joints : [SCNNode] = [skeletonRoot]
            skeletonRoot.name =  ARSkeletonDefinition.defaultBody3D.jointNames[0]
            for jointIndex in 1..<ARSkeletonDefinition.defaultBody3D.jointCount { // ignore root
                let name = ARSkeletonDefinition.defaultBody3D.jointNames[jointIndex]
                let jointNode : SCNNode = SCNNode()
                jointNode.name = name
                joints.append(jointNode)
                jointNode.geometry = SCNSphere(radius: 0.02 * bodyAnchor.estimatedScaleFactor)
            }
            for jointIndex in 1..<ARSkeletonDefinition.defaultBody3D.jointCount { // ignore root
                let parentJointIndex = ARSkeletonDefinition.defaultBody3D.parentIndices[jointIndex]
                let currentJoint = joints[jointIndex]
                let parentJoint = joints[parentJointIndex]
                parentJoint.addChildNode(currentJoint)
                currentJoint.simdTransform = bodyAnchor.skeleton.jointLocalTransforms[jointIndex]
            }
        }
    }
    
    func getBones() -> [SCNNode] {
        var joints : [SCNNode] = []
        if let skeletonRoot = skeletonRoot {
            joints.append(skeletonRoot)
            for jointIndex in 1..<ARSkeletonDefinition.defaultBody3D.jointCount { // ignore root
                let name = ARSkeletonDefinition.defaultBody3D.jointNames[jointIndex]
                if let joint = skeletonRoot.childNode(withName: name, recursively: true)
                {
                    joints.append(joint)
                }
            }
        }
        return joints
    }
    
    func rig(geometry: SCNGeometry, bodyAnchor: ARBodyAnchor) -> Void
    {
        let jointTransforms = bodyAnchor.skeleton.jointModelTransforms
        let vertex = geometry.sources(for: .vertex).first!
        let vertexCount = vertex.vectorCount
        for vertexIndex in 0..<vertexCount {
            
        }
//        let boneWeights = SCNGeometrySource(data: <#T##Data#>, semantic: .boneWeights, vectorCount: vertexCount, usesFloatComponents: true, componentsPerVector: 4, bytesPerComponent: <#T##Int#>, dataOffset: <#T##Int#>, dataStride: <#T##Int#>)
//        let boneIndices = SCNGeometrySource(data: <#T##Data#>, semantic: .boneIndices, vectorCount: vertexCount, usesFloatComponents: true, componentsPerVector: 4, bytesPerComponent: <#T##Int#>, dataOffset: <#T##Int#>, dataStride: <#T##Int#>)
//        let skinner = SCNSkinner(baseGeometry: geometry, bones: bones, boneInverseBindTransforms: nil, boneWeights: <#T##SCNGeometrySource#>, boneIndices: <#T##SCNGeometrySource#>)
    }

}
