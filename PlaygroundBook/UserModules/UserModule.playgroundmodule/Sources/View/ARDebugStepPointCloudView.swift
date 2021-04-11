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
            
            EntityHierarchyView(entities: [
                OperationManager.shared.scanNode.entity,
                OperationManager.shared.humanNode.entity
            ])
            
            Button(action: {
                environment.arOperationMode = .skeletonRig
            }, label: {
                FilledButtonView(icon: "", text: "Save Cloud Points", color: Color.accentColor, shadow: false, primary: true)
            })
            .padding([.horizontal, .bottom])
        }
    }
}

struct ARDebugStepPointCloudView_Previews: PreviewProvider {
    static var previews: some View {
        ARDebugStepPointCloudView()
    }
}
