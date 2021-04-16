//
//  ARDebugStepBodyPositioningView.swift
//  PlaygroundBook
//
//  Created by fincher on 4/15/21.
//

import SwiftUI

struct ARDebugStepBodyPositioningView: View {
    @EnvironmentObject var environment: DataEnvironment
    
    var body: some View {
        VStack {
            Text("Skeleton Positioning")
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
           
            HStack {
                Text("X")
                Slider(value: Binding<Double>(get: { () -> Double in
                    environment.positionAddX
                }, set: { (value:Double) in
                    environment.positionAddX = value
                }), in: -1...1, step: 1) { (editing:Bool) in
                    if !editing { environment.positionAddX = 0.0 }
                }
            }.padding(.horizontal)
            
            HStack {
                Text("Y")
                Slider(value: Binding<Double>(get: { () -> Double in
                    environment.positionAddZ
                }, set: { (value:Double) in
                    environment.positionAddZ = value
                }), in: -1...1, step: 1) { (editing:Bool) in
                    if !editing { environment.positionAddZ = 0.0 }
                }
            }.padding(.horizontal)
            
            
            
            HStack {
                Text("Z")
                Slider(value: Binding<Double>(get: { () -> Double in
                    environment.positionAddY
                }, set: { (value:Double) in
                    environment.positionAddY = value
                }), in: -1...1, step: 1) { (editing:Bool) in
                    if !editing { environment.positionAddY = 0.0 }
                }
            }.padding(.horizontal)
        }
    }
}

struct ARDebugStepBodyPositioningView_Previews: PreviewProvider {
    static var previews: some View {
        ARDebugStepBodyPositioningView()
    }
}
