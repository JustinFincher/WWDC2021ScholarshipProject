//
//  ARDebugStepHumanBodyView.swift
//  UserModuleFramework
//
//  Created by fincher on 4/10/21.
//

import SwiftUI

struct ARDebugStepHumanBodyView: View {
    @EnvironmentObject var environment: DataEnvironment
    var body: some View {
        ScrollView(.vertical, showsIndicators: true, content: {
            VStack(alignment: .leading, spacing: 8, content: {
                Text("Capture Skeleton")
                    .font(.subheadline)
                Text("Ask the person you wish to scan to maintain the T-pose or 大-pose. The pose should be maintained when you are reading the skeleton position.")
                    .font(.caption)
                Text("Point your iPad torwards to the person you wish to scan. You should be able to see a skeleton highlighting the joints and bones. Move around a little bit to align the skeleton witht the human body, then tap next to fix any positioning issues.")
                    .font(.caption)
                
                Button(action: {
                    environment.arOperationMode = .positionSekeleton
                }, label: {
                    FilledButtonView(icon: "", text: "Next", color: Color.accentColor, shadow: false, primary: true)
                })
            })
            .padding(.horizontal)
        })
    }
}

struct ARDebugStepHumanBodyView_Previews: PreviewProvider {
    static var previews: some View {
        ARDebugStepHumanBodyView()
    }
}
