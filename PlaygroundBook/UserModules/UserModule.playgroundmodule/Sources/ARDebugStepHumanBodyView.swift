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
        VStack {
            Text("Capture Skeleton")
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            Button(action: {
                environment.arOperationMode = .positionSekeleton
            }, label: {
                FilledButtonView(icon: "", text: "Fix Position", color: Color.accentColor, shadow: false, primary: true)
            })
            .padding(.horizontal)

        }
    }
}

struct ARDebugStepHumanBodyView_Previews: PreviewProvider {
    static var previews: some View {
        ARDebugStepHumanBodyView()
    }
}
