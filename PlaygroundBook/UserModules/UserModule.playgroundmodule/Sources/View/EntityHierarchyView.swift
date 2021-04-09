//
//  EntityHierarchyView.swift
//  UserModuleFramework
//
//  Created by fincher on 4/8/21.
//

import SwiftUI

struct EntityHierarchyView: View {
    
    @EnvironmentObject var environment: DataEnvironment
    
    func getDisplayItems() -> [EntityDisplayModel] {
        return environment.arEntities.map { entity -> EntityDisplayModel in
            entity.toEntityDisplayModel()
        }
    }
    
    var body: some View {
        List(getDisplayItems(), children: \.children) { item in
            Text("\(item.key)").font(.body)
            if item.value != ""
            {
                Text("\(item.value)").font(.footnote)
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

struct EntityHierarchyView_Previews: PreviewProvider {
    static var previews: some View {
        EntityHierarchyView()
    }
}
