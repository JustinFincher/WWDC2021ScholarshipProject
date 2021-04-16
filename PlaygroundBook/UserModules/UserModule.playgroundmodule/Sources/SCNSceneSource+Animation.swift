//
//  SCNSceneSource+Animation.swift
//  PlaygroundBook
//
//  Created by fincher on 4/15/21.
//

import Foundation
import SceneKit

extension SCNSceneSource
{
    func examineAnimatable() -> Void {
        var animation : SCNAnimatable? = entryWithIdentifier("hips_joint", withClass: SCNAnimatable.self) as SCNAnimatable?
        print(animation)
        animation = entryWithIdentifier("spine_1_joint", withClass: SCNAnimatable.self) as SCNAnimatable?
        print(animation)
        
    }
}
