//
//  ARDebugStepsScanView.swift
//  UserModuleFramework
//
//  Created by fincher on 4/7/21.
//

import SwiftUI
import GameplayKit
import SceneKit
struct ARDebugStepPointCloudView: View {
    
    @EnvironmentObject var environment: DataEnvironment
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true, content: {
            VStack(alignment: .leading, spacing: 8, content: {
                Text("Scan Point Clouds")
                    .font(.subheadline)
                Text("Ask the person you wish to scan to stand straight with a T-pose or 大-pose. The pose should be maintained when you are scanning.")
                    .font(.caption)
                Text("Point your iPad torwards to the person you wish to scan. Keep enough distance so the iPad can capture the whole human body, then walk around the person so we can get a 360 degree scan.")
                    .font(.caption)
                Text("When finished, tap the button below to detect human pose.")
                    .font(.caption)
                
                Button(action: {
                    environment.arOperationMode = .captureSekeleton
                }, label: {
                    FilledButtonView(icon: "", text: "Next", color: Color.accentColor, shadow: false, primary: true)
                })
            })
            .padding(.horizontal)
        })
    }
}

struct ARDebugStepPointCloudView_Previews: PreviewProvider {
    static var previews: some View {
        ARDebugStepPointCloudView()
    }
}
