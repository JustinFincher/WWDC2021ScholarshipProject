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

class OperationComponent: GKComponent {
    
    private var cancellable: AnyCancellable?
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func didAddToEntity() {
        cancellable = EnvironmentManager.shared.env.$arOperationMode.sink(receiveValue: { mode in
            switch mode {
            case .polygon:
                break
            case .colorize:
                if let node = self.entity?.component(ofType: GKSCNNodeComponent.self)?.node {
                    node.geometry = node.geometry?.withUV().withUVMaterial()
                }
                break
            case .rigging:
                break
            case .export:
                break
            }
        })
    }
    
    override func willRemoveFromEntity() {
        cancellable?.cancel()
    }
    
    func toEntityDisplayModel() -> EntityDisplayModel {
        let model = EntityDisplayModel(key: String(describing: type(of: self)), value: "", children: [])
        return model
    }
}
