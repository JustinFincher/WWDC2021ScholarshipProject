//
//  SCNNode+Human.swift
//  UserModuleFramework
//
//  Created by fincher on 4/10/21.
//

import Foundation
import SceneKit
import ARKit

extension SCNNode
{
    func update(bodyAnchor: ARBodyAnchor) -> Void {
        self.childNodes.forEach { node in
            node.removeFromParentNode()
        }
        self.simdTransform = bodyAnchor.transform
        var joints : [SCNNode] = [self]
        self.name =  ARSkeletonDefinition.defaultBody3D.jointNames[0]
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
    
    func getBones() -> [SCNNode] {
        var joints : [SCNNode] = [self]
        for jointIndex in 1..<ARSkeletonDefinition.defaultBody3D.jointCount { // ignore root
            let name = ARSkeletonDefinition.defaultBody3D.jointNames[jointIndex]
            if let joint = self.childNode(withName: name, recursively: true)
            {
                joints.append(joint)
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
