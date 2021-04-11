//
//  TexturingComponent.swift
//  UserModuleFramework
//
//  Created by fincher on 4/8/21.
//

import Foundation
import SceneKit
import ARKit
import GameplayKit
import Combine

class PointCloudComponent: GKComponent {
    
    private var cancellable: AnyCancellable?
    
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
    
    func toEntityDisplayModel() -> EntityDisplayModel {
        let model = EntityDisplayModel(key: String(describing: type(of: self)), value: "", children: [])
        return model
    }
}
