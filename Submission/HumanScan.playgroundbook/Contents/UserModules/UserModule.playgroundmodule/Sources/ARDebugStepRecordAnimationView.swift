//
//  ARDebugStepRecordAnimationView.swift
//  UserModuleFramework
//
//  Created by fincher on 4/16/21.
//

import SwiftUI

struct ARDebugStepRecordAnimationView: View {
    @EnvironmentObject var environment: DataEnvironment
    @State private var showExportSheet: Bool = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true, content: {
            VStack(alignment: .leading, spacing: 8, content: {
                Text("Record Animation")
                    .font(.subheadline)
                Button(action: {
                    OperationManager.shared.humanNode.animation = ARKitSkeletonAnimation(frames: [])
                }, label: {
                    FilledButtonView(icon: "", text: "Record", color: Color.accentColor, shadow: false, primary: true)
                })
                Button(action: {
                    showExportSheet.toggle()
                }, label: {
                    FilledButtonView(icon: "", text: "Export", color: Color.accentColor, shadow: false, primary: true)
                })
                .sheet(isPresented: $showExportSheet, onDismiss: {
                }, content: {
                    ActivityViewControllerView(activityItems: [OperationManager.shared.humanNode.exportAnimationAndReturnURL()!])
                })
            })
            .padding(.horizontal)
        })
    }
}

struct ARDebugStepRecordAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        ARDebugStepRecordAnimationView()
    }
}
