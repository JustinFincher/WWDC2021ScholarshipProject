//
//  Data.swift
//  UserModuleFramework
//
//  Created by fincher on 4/7/21.
//

import Foundation

enum AROperationMode {
    case pointCloud
    case skeletonRig
    case presentHuman
}

struct EntityDisplayModel: Hashable, Identifiable {
    var id: Self { self }
    var key: String
    var value: String
    var children: [EntityDisplayModel]? = nil
}
