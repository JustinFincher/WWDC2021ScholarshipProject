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
        VStack {
            Text("Rig Animation")
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            Button(action: {
                showExportSheet.toggle()
            }, label: {
                FilledButtonView(icon: "", text: "Export", color: Color.accentColor, shadow: false, primary: true)
            })
            .padding(.horizontal)
            .sheet(isPresented: $showExportSheet, onDismiss: {
            }, content: {
                ActivityViewControllerView(activityItems: [OperationManager.shared.scene.exportAndReturnURL()!])
            })
        }
    }
}

struct ARDebugStepRiggingView_Previews: PreviewProvider {
    static var previews: some View {
        ARDebugStepRiggingView()
    }
}
