//
//  Data.swift
//  UserModuleFramework
//
//  Created by fincher on 4/7/21.
//

import Foundation

enum AROperationMode {
    case captureSekeleton
    case setBoundingBox
    case attachPointCloud
    case rigAnimation
}

struct EntityDisplayModel: Hashable, Identifiable {
    var id: Self { self }
    var key: String
    var value: String
    var children: [EntityDisplayModel]? = nil
}
