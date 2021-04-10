//
//  GKEntity+Helper.swift
//  UserModuleFramework
//
//  Created by fincher on 4/8/21.
//

import Foundation
import GameplayKit
import SceneKit

extension GKEntity {
    func toEntityDisplayModel() -> EntityDisplayModel {
        var model = EntityDisplayModel(key: String(describing: type(of: self)), value: "\(self.components.count) components", children: [])
        if let comp = self.component(ofType: GKSCNNodeComponent.self) {
            model.children?.append(comp.toEntityDisplayModel())
        }
        if let comp = self.component(ofType: PointCloudComponent.self) {
            model.children?.append(comp.toEntityDisplayModel())
        }
        return model
    }
}

extension GKSCNNodeComponent {
    func toEntityDisplayModel() -> EntityDisplayModel {
        var model = EntityDisplayModel(key: String(describing: type(of: self)), value: "", children: [])
        model.children?.append(node.toEntityDisplayModel())
        return model
    }
}
