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
        case .pointCloud: return AnyView(ARDebugStepPointCloudView())
        case .skeletonRig: return AnyView(ARDebugStepHumanBodyView())
        case .presentHuman: return AnyView(ZStack {})
        }
   }
        
    var body: some View {
        VStack(content: {
            Picker(selection: $environment.arOperationMode, label: Text("Step")) {
                Text("SkeletonRig").tag(AROperationMode.skeletonRig)
                Text("PointCloud").tag(AROperationMode.pointCloud)
                Text("Presenration").tag(AROperationMode.presentHuman)
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
