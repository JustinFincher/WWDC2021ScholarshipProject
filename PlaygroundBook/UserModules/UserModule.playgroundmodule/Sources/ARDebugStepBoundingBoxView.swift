//
//  ARDebugStepBoundingBoxView.swift
//  UserModuleFramework
//
//  Created by fincher on 4/13/21.
//

import SwiftUI

struct ARDebugStepBoundingBoxView: View {
    @EnvironmentObject var environment: DataEnvironment
    var body: some View {
        VStack {
            Text("Set Bounding Box")
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            EntityHierarchyView(entities: [
                OperationManager.shared.scanNode.entity,
                OperationManager.shared.humanNode.entity
            ])
        }
    }
}

struct ARDebugStepBoundingBoxView_Previews: PreviewProvider {
    static var previews: some View {
        ARDebugStepBoundingBoxView()
    }
}
