//
//  ARDebugView.swift
//  UserModule
//
//  Created by fincher on 4/6/21.
//

import SwiftUI

struct ARDebugView: View {
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Rectangle()
                    .cornerRadius(12)
                    .frame(width: geometry.size.width / 3, height: geometry.size.height / 2, alignment: .topLeading)
                    .background(Color.init(UIColor.systemBackground))
                    .padding()
            }
            Text("Test")
        }
    }
}

struct ARDebugView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ARDebugView()
                
        }
    }
}
