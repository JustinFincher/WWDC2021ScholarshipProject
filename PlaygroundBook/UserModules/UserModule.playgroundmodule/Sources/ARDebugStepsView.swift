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
        case .rigAnimation: return AnyView(ZStack {})
        case .setBoundingBox: return AnyView(ZStack {})
        }
   }
        
    var body: some View {
        VStack(content: {
            Picker(selection: $environment.arOperationMode, label: Text("Step")) {
                Text("Capture Skeleton").tag(AROperationMode.captureSekeleton)
                Text("Add Point Cloud").tag(AROperationMode.attachPointCloud)
                Text("Set Bounding Box").tag(AROperationMode.setBoundingBox)
                Text("Rig Animation").tag(AROperationMode.rigAnimation)
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
