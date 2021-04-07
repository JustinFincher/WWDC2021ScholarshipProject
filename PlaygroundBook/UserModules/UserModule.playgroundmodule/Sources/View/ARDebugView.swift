//
//  ARDebugView.swift
//  UserModule
//
//  Created by fincher on 4/6/21.
//

import SwiftUI

struct ARDebugView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ZStack {
                    NavigationView(content: {
                        Text("Test")
                            .navigationBarTitle("AR")
                    })
                    .navigationViewStyle(StackNavigationViewStyle())
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .background(Color.init(UIColor.systemGroupedBackground))
                .cornerRadius(25)
                .shadow(radius: 10)
            }
            .padding()
            .frame(width: geometry.size.width / 4, height: geometry.size.height / 2, alignment: .topLeading)
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
