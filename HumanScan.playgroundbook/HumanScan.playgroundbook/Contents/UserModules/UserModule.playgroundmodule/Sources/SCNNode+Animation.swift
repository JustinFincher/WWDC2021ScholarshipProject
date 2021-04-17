//
//  SCNNode+Animation.swift
//  PlaygroundBook
//
//  Created by fincher on 4/15/21.
//

import Foundation
import SceneKit

extension SCNNode
{
    func examineAnimatable() -> Void {
        self.enumerateChildNodes { (child: SCNNode, stop: UnsafeMutablePointer<ObjCBool>) in
            print("node \(String(describing: child.name))")
            if child.animationKeys.count > 0
            {
                child.animationKeys.forEach { (key:String) in
                    print(" key \(key)")
                    let animationPlayer = child.animationPlayer(forKey: key)
                    print(animationPlayer?.animation)
                }
            }
        }
    }
    
    func transformMixamoIntoSceneKitNaming() -> Void {
        
    }
}
