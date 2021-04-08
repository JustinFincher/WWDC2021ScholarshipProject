//
//  ARDebugStepsScanView.swift
//  UserModuleFramework
//
//  Created by fincher on 4/7/21.
//

import SwiftUI

struct ARDebugStepsScanView: View {
    @EnvironmentObject var environment: DataEnvironment
    
    var body: some View {
        VStack {
            List {
                ForEach(environment.arMeshNodes, id: \.self) { node in
                    VStack(alignment: .leading) {
                        Text("Mesh Source Count \(node.geometry?.getVerticesCount() ?? 0)")
                            .font(.callout)
                        Text("Node \(node.name ?? "NULL")")
                            .font(.footnote)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            Button(action: {
                environment.arOperationMode = .colorize
            }, label: {
                FilledButtonView(icon: "", text: "Save \(environment.arMeshNodes.count) Meshes", color: Color.accentColor, shadow: false, primary: true)
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
