//
//  ARDebugStepRiggingView.swift
//  UserModuleFramework
//
//  Created by fincher on 4/13/21.
//

import SwiftUI

struct ARDebugStepRiggingView: View {
    @EnvironmentObject var environment: DataEnvironment
    @State private var showExportSheet: Bool = false
    @State var exportUrl : URL? = nil
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true, content: {
            VStack(alignment: .leading, spacing: 8, content: {
                Text("Animation Test")
                    .font(.subheadline)
                Text("If all is going right, you should see an isolated human model with correctly-rigged skeleton. Initially, it was designed to have the skeleton dance in the AR space, but due to a bug in SceneKit, you need to export this model to a Mac and use Xcode to examine it.")
                    .font(.caption)
                
//                Button(action: {
//                    OperationManager.shared.humanNode.loadAnimation(url: Bundle.main.url(forResource: "chenxi", withExtension: "json")!)
//                }, label: {
//                    FilledButtonView(icon: "", text: "Play", color: Color.accentColor, shadow: false, primary: true)
//                })
                
                Button(action: {
                    OperationManager.shared.humanNode.toggleSkinner(cloudPointNode: OperationManager.shared.scanNode, enable: true)
                    exportUrl = OperationManager.shared.scene.exportAndReturnURL()
                    OperationManager.shared.humanNode.toggleSkinner(cloudPointNode: OperationManager.shared.scanNode, enable: false)
                    showExportSheet.toggle()
                }, label: {
                    FilledButtonView(icon: "", text: "Export", color: Color.accentColor, shadow: false, primary: true)
                })
                .sheet(isPresented: $showExportSheet, onDismiss: {
                }, content: {
                    ActivityViewControllerView(activityItems: [exportUrl])
                })
            })
            .padding(.horizontal)
        })
    }
}

struct ARDebugStepRiggingView_Previews: PreviewProvider {
    static var previews: some View {
        ARDebugStepRiggingView()
    }
}
