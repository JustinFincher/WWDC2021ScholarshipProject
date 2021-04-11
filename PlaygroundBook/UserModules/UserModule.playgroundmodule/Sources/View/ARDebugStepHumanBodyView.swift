//
//  ARDebugStepHumanBodyView.swift
//  UserModuleFramework
//
//  Created by fincher on 4/10/21.
//

import SwiftUI

struct ARDebugStepHumanBodyView: View {
    var body: some View {
        VStack {
            EntityHierarchyView(entities: [
                OperationManager.shared.scanNode.entity,
                OperationManager.shared.humanNode.entity
            ])
        }
    }
}

struct ARDebugStepHumanBodyView_Previews: PreviewProvider {
    static var previews: some View {
        ARDebugStepHumanBodyView()
    }
}
