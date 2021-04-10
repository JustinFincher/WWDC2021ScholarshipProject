//
//  EntityHierarchyView.swift
//  UserModuleFramework
//
//  Created by fincher on 4/8/21.
//

import SwiftUI
import GameplayKit

struct EntityHierarchyView: View {
    
    @EnvironmentObject var environment: DataEnvironment
    var entity : GKEntity
    
    var body: some View {
        List([entity.toEntityDisplayModel()], children: \.children) { item in
            Text("\(item.key)").font(.body)
            if item.value != ""
            {
                Text("\(item.value)").font(.footnote)
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}
