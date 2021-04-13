//
//  ARDebugStepsScanView.swift
//  UserModuleFramework
//
//  Created by fincher on 4/7/21.
//

import SwiftUI
import GameplayKit
import SceneKit
struct ARDebugStepPointCloudView: View {
    
    @EnvironmentObject var environment: DataEnvironment
    
    var body: some View {
        VStack {
            Text("Add Point Cloud")
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

struct ARDebugStepPointCloudView_Previews: PreviewProvider {
    static var previews: some View {
        ARDebugStepPointCloudView()
    }
}
