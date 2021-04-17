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
        ScrollView(.vertical, showsIndicators: true, content: {
            VStack(alignment: .leading, spacing: 8, content: {
                Text("Pair skeleton with scanned point cloud")
                    .font(.subheadline)
                Text("Now you can ask your buddy to walk away from the original position as all information are now caputred. The next step needs a while so hang tight (ask your buddy to join you and see what you have scanned)!")
                    .font(.caption)
                Text("Double check that the skeleton is matched with the human point cloud. Then press next and wait for half a minute. Your iPad will now remove the background from the static scanned model and pair skeleton joints with it so it can be dynamic.")
                    .font(.caption)
                
                Button(action: {
                    waiting = true
                    DispatchQueue.global(qos: .userInteractive).async {
                        let manager = OperationManager.shared
                        manager.humanNode.filterPoints(cloudPointNode: manager.scanNode)
                        manager.humanNode.rig(cloudPointNode: manager.scanNode)
                        DispatchQueue.main.async {
                            waiting = false
                            environment.arOperationMode = .animateSkeleton
                        }
                    }
                }, label: {
                    FilledButtonView(icon: "", text: (waiting ? "Processing" : "Next"), color: Color.accentColor, shadow: false, primary: true)
                })
                .disabled(waiting)
            })
            .padding(.horizontal)
        })
    }
}

struct ARDebugStepRemoveBgAndRigView_Previews: PreviewProvider {
    static var previews: some View {
        ARDebugStepRemoveBgAndRigView()
    }
}
