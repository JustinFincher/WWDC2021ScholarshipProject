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
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true, content: {
            VStack(alignment: .leading, spacing: 8, content: {
                Text("Animation Test")
                    .font(.subheadline)
                Text("If all is going right, you should see an isolated human model with correctly-rigged skeleton. Press play button to play some cool dance move! Or you can export this 3D model and AirDrop to a computer for futher examination.")
                    .font(.caption)
                
                Button(action: {
                    OperationManager.shared.humanNode.loadAnimation(url: Bundle.main.url(forResource: "record", withExtension: "json")!)
                }, label: {
                    FilledButtonView(icon: "", text: "Play", color: Color.accentColor, shadow: false, primary: true)
                })
                
                Button(action: {
                    showExportSheet.toggle()
                }, label: {
                    FilledButtonView(icon: "", text: "Export", color: Color.accentColor, shadow: false, primary: true)
                })
                .sheet(isPresented: $showExportSheet, onDismiss: {
                }, content: {
                    ActivityViewControllerView(activityItems: [OperationManager.shared.scene.exportAndReturnURL() as Any])
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
