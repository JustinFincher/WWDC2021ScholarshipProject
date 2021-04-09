//
//  ARDebugStepColorizeView.swift
//  UserModuleFramework
//
//  Created by fincher on 4/8/21.
//

import SwiftUI

struct ARDebugStepColorizeView: View {
    @EnvironmentObject var environment: DataEnvironment
    
    var body: some View {
        VStack {
            EntityHierarchyView()
            Button(action: {
                environment.arOperationMode = .rigging
            }, label: {
                FilledButtonView(icon: "", text: "Start Rigging", color: Color.accentColor, shadow: false, primary: true)
            })
            .padding([.horizontal])
            
            Button(action: {
                environment.triggerUpdate { env in }
            }, label: {
                FilledButtonView(icon: "", text: "Refresh", color: Color.accentColor, shadow: false, primary: false)
            })
            .padding([.horizontal, .bottom])
        }
    }
}

struct ARDebugStepColorizeView_Previews: PreviewProvider {
    static var previews: some View {
        ARDebugStepColorizeView()
    }
}
