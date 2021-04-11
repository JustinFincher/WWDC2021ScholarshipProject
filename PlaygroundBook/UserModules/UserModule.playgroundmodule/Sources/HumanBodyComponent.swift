//
//  HumanBodyComponent.swift
//  UserModuleFramework
//
//  Created by fincher on 4/10/21.
//

import Foundation
import SceneKit
import ARKit
import GameplayKit
import Combine

class HumanBodyComponent: GKComponent {
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func didAddToEntity() {
        
    }
    
    override func willRemoveFromEntity() {
    }
}
