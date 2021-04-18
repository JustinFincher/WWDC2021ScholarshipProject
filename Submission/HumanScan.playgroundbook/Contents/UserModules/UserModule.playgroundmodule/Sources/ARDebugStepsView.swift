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
        case .recordAnimation: return AnyView(ARDebugStepRecordAnimationView())
        case .captureSekeleton: return AnyView(ARDebugStepHumanBodyView())
        case .positionSekeleton: return AnyView(ARDebugStepBodyPositioningView())
        case .removeBgAndRig: return AnyView(ARDebugStepRemoveBgAndRigView())
        case .animateSkeleton: return AnyView(ARDebugStepRiggingView())
        }
    }
    
    var body: some View {
        VStack(content: {
            Picker(selection: $environment.arOperationMode, label: Text("Step")) {
                Text("1").tag(AROperationMode.attachPointCloud)
                Text("2").tag(AROperationMode.captureSekeleton)
                Text("3").tag(AROperationMode.positionSekeleton)
                Text("4").tag(AROperationMode.removeBgAndRig)
                Text("5").tag(AROperationMode.animateSkeleton)
                if arDebugMode {
                    Text("6").tag(AROperationMode.recordAnimation)
                }
            }
            .disabled(!arDebugMode)
            .frame(maxWidth: .infinity, alignment: .center)
            .fixedSize(horizontal: false, vertical: true)
            .pickerStyle(SegmentedPickerStyle())
            .padding([.horizontal, .top])
            
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
