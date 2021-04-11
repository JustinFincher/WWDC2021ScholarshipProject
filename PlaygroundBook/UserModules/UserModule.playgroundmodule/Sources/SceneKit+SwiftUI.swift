//
//  SCNNode+Helper.swift
//  UserModuleFramework
//
//  Created by fincher on 4/8/21.
//

import Foundation
import SceneKit

extension SCNNode {
    func toEntityDisplayModel() -> EntityDisplayModel {
        var model = EntityDisplayModel(key: String(describing: type(of: self)), value: "\(self.name ?? "NULL")", children: [])
        if let geometry = self.geometry {
            model.children?.append(geometry.toEntityDisplayModel())
        }
        return model
    }
}

extension SCNGeometry {
    
    func toEntityDisplayModel() -> EntityDisplayModel {
        var model = EntityDisplayModel(key: String(describing: type(of: self)), value: "\(self.elements.count) elements", children: [])
        self.elements.forEach { element in
            model.children?.append(element.toEntityDisplayModel())
        }
        self.sources.forEach { source in
            model.children?.append(source.toEntityDisplayModel())
        }
        return model
    }
}

extension SCNGeometryElement {
    func toEntityDisplayModel() -> EntityDisplayModel {
        let model = EntityDisplayModel(key: String(describing: type(of: self)), value: "\(self.primitiveCount) primitives", children: [])
        return model
    }
}


extension SCNGeometrySource {
    func toEntityDisplayModel() -> EntityDisplayModel {
        var model = EntityDisplayModel(key: String(describing: type(of: self)), value: "\(self.semantic.rawValue)", children: [])
        model.children?.append(EntityDisplayModel(key: "bytesPerComponent", value: "\(self.bytesPerComponent)"))
        model.children?.append(EntityDisplayModel(key: "componentsPerVector", value: "\(self.componentsPerVector)"))
        model.children?.append(EntityDisplayModel(key: "vectorCount", value: "\(self.vectorCount)"))
        model.children?.append(EntityDisplayModel(key: "usesFloatComponents", value: "\(self.usesFloatComponents)"))
        return model
    }
}
