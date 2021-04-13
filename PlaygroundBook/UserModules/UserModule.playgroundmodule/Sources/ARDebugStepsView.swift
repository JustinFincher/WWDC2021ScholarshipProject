//
//  ARDebugStepsView.swift
//  UserModuleFramework
//
//  Created by fincher on 4/7/21.
//

import SwiftUI

struct ARDebugStepsView: View {
    @EnvironmentObject var environment: DataEnvironment
    
    func getContentView() -> AnyView {
        switch environment.arOperationMode {
        case .attachPointCloud: return AnyView(ARDebugStepPointCloudView())
        case .captureSekeleton: return AnyView(ARDebugStepHumanBodyView())
        case .setBoundingBox: return AnyView(ARDebugStepBoundingBoxView())
        case .rigAnimation: return AnyView(ARDebugStepRiggingView())
        }
   }
        
    var body: some View {
        VStack(content: {
            Picker(selection: $environment.arOperationMode, label: Text("Step")) {
                Text("1").tag(AROperationMode.captureSekeleton)
                Text("2").tag(AROperationMode.attachPointCloud)
                Text("3").tag(AROperationMode.setBoundingBox)
                Text("4").tag(AROperationMode.rigAnimation)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .fixedSize(horizontal: false, vertical: true)
            .pickerStyle(SegmentedPickerStyle())
            .padding([.horizontal])
            
            getContentView()
            .frame(maxHeight: .infinity, alignment: .center)
        })
        .navigationTitle("Steps")
    }
}

struct ARDebugStepsView_Previews: PreviewProvider {
    static var previews: some View {
        ARDebugStepsView()
    }
}
