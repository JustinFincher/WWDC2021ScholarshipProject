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
    func withName(name: String) -> SCNNode {
        self.name = name
        return self
    }
    
    func withParent(parent: SCNNode) -> SCNNode {
        parent.addChildNode(self)
        return self
    }
}
