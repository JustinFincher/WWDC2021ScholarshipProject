//
//  ARDebugStepBoundingBoxView.swift
//  UserModuleFramework
//
//  Created by fincher on 4/13/21.
//

import SwiftUI

struct ARDebugStepRemoveBgAndRigView: View {
    @EnvironmentObject var environment: DataEnvironment
    @State var waiting: Bool = false
    var body: some View {
        VStack {
            Text("Remove Background And Rig")
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            Button(action: {
                waiting = true
                DispatchQueue.global(qos: .userInteractive).async {
                    let manager = OperationManager.shared
                    manager.humanNode.filterPoints(cloudPointNode: manager.scanNode)
                    manager.humanNode.rig(cloudPointNode: manager.scanNode)
                    DispatchQueue.main.async {
                        waiting = false
                    }
                }
            }, label: {
                FilledButtonView(icon: "", text: (waiting ? "Waiting" : "Filter Points And Rig"), color: Color.accentColor, shadow: false, primary: true)
            })
            .disabled(waiting)
            .padding(.horizontal)
        }
    }
}

struct ARDebugStepRemoveBgAndRigView_Previews: PreviewProvider {
    static var previews: some View {
        ARDebugStepRemoveBgAndRigView()
    }
}
