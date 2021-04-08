//
//  ARDebugStepsScanView.swift
//  UserModuleFramework
//
//  Created by fincher on 4/7/21.
//

import SwiftUI
import GameplayKit
import SceneKit
struct ARDebugStepsScanView: View {
    
    @EnvironmentObject var environment: DataEnvironment
    
    var body: some View {
        VStack {
            List {
                ForEach(environment.arEntities, id: \.self) { entity in
                    VStack(alignment: .leading) {
                        Text("Entity")
                            .font(.callout)
                        Text("Node \(entity.component(ofType: GKSCNNodeComponent.self)?.node.name ?? "NULL")")
                            .font(.footnote)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            Button(action: {
                environment.arOperationMode = .colorize
            }, label: {
                FilledButtonView(icon: "", text: "Save \(environment.arEntities.count) Meshes", color: Color.accentColor, shadow: false, primary: true)
            })
            .padding([.horizontal, .bottom])
        }
    }
}

struct ARDebugStepsScanView_Previews: PreviewProvider {
    static var previews: some View {
        ARDebugStepsScanView()
    }
}
