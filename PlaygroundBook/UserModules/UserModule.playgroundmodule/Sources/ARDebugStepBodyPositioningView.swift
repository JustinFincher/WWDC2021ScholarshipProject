//
//  ARDebugStepBodyPositioningView.swift
//  PlaygroundBook
//
//  Created by fincher on 4/15/21.
//

import SwiftUI

struct ARDebugStepBodyPositioningView: View {
    @EnvironmentObject var environment: DataEnvironment
    
    @State private var showExportSheet: Bool = false
    var body: some View {
        ScrollView(.vertical, showsIndicators: true, content: {
            VStack(alignment: .leading, spacing: 8, content: {
                Text("Skeleton Positioning")
                    .font(.subheadline)
                Text("Ask the person you wish to scan to maintain the T-pose or 大-pose.")
                    .font(.caption)
                Text("You may find that the captured skeleton is a bit off from the real position your buddy is standing at. Drag the sliders below to manually align it until you can see the skeleton prefectly embeded in the scanned point clouds. Then press next.")
                    .font(.caption)
                
                HStack {
                    Text("X")
                    Slider(value: Binding<Double>(get: { () -> Double in
                        environment.positionAddX
                    }, set: { (value:Double) in
                        environment.positionAddX = value
                    }), in: -1...1, step: 1) { (editing:Bool) in
                        if !editing { environment.positionAddX = 0.0 }
                    }
                }
                
                HStack {
                    Text("Y")
                    Slider(value: Binding<Double>(get: { () -> Double in
                        environment.positionAddZ
                    }, set: { (value:Double) in
                        environment.positionAddZ = value
                    }), in: -1...1, step: 1) { (editing:Bool) in
                        if !editing { environment.positionAddZ = 0.0 }
                    }
                }
                
                
                
                HStack {
                    Text("Z")
                    Slider(value: Binding<Double>(get: { () -> Double in
                        environment.positionAddY
                    }, set: { (value:Double) in
                        environment.positionAddY = value
                    }), in: -1...1, step: 1) { (editing:Bool) in
                        if !editing { environment.positionAddY = 0.0 }
                    }
                }
                
                Button(action: {
                    environment.arOperationMode = .removeBgAndRig
                }, label: {
                    FilledButtonView(icon: "", text: "Next", color: Color.accentColor, shadow: false, primary: true)
                })
                
                Button(action: {
                    showExportSheet.toggle()
                }, label: {
                    FilledButtonView(icon: "", text: "Export", color: Color.accentColor, shadow: false, primary: true)
                })
                .sheet(isPresented: $showExportSheet, onDismiss: {
                }, content: {
                    ActivityViewControllerView(activityItems: [OperationManager.shared.scene.exportAndReturnURL()!])
                })
            })
            .padding(.horizontal)
        })
    }
}

struct ARDebugStepBodyPositioningView_Previews: PreviewProvider {
    static var previews: some View {
        ARDebugStepBodyPositioningView()
    }
}
