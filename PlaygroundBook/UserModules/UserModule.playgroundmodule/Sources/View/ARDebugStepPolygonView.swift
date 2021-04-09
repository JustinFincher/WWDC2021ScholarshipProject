//
//  ARDebugStepsScanView.swift
//  UserModuleFramework
//
//  Created by fincher on 4/7/21.
//

import SwiftUI
import GameplayKit
import SceneKit
struct ARDebugStepPolygonView: View {
    
    @EnvironmentObject var environment: DataEnvironment
    
    var body: some View {
        VStack {
            EntityHierarchyView()
            Button(action: {
                environment.arOperationMode = .colorize
            }, label: {
                FilledButtonView(icon: "", text: "Save \(environment.arEntities.count) Meshes", color: Color.accentColor, shadow: false, primary: true)
            })
            .padding([.horizontal, .bottom])
        }
    }
}

struct ARDebugStepScanView_Previews: PreviewProvider {
    static var previews: some View {
        ARDebugStepPolygonView()
    }
}
