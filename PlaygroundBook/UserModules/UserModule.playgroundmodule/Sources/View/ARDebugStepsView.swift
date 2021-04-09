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
        case .polygon: return AnyView(ARDebugStepPolygonView())
        case .colorize: return AnyView(ARDebugStepColorizeView())
        case .rigging: return AnyView(ZStack {})
        case .export: return AnyView(ZStack {})
        }
   }
        
    var body: some View {
        VStack(content: {
            Picker(selection: $environment.arOperationMode, label: Text("Step")) {
                Text("Scan").tag(AROperationMode.polygon)
                Text("Color").tag(AROperationMode.colorize)
                Text("Rig").tag(AROperationMode.rigging)
                Text("Export").tag(AROperationMode.export)
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
