//
//  ARDebugView.swift
//  UserModule
//
//  Created by fincher on 4/6/21.
//

import SwiftUI

struct ARDebugView: View {
    
    @State var expanded : Bool = false
    
    func isHorizontal(geometry: GeometryProxy) -> Bool {
        return geometry.size.width > geometry.size.height
    }
    
    func getBarItemIconName() -> String {
        return expanded ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right"
    }
    
    func getPanelWidth(geometry: GeometryProxy) -> CGFloat
    {
        var multipler : CGFloat = 0.3
        if isHorizontal(geometry: geometry) {
            multipler = expanded ? 0.4 : 0.3
        } else {
            multipler = expanded ? 1 : 0.5
        }
        return geometry.size.width * multipler
    }
    func getPanelHeight(geometry: GeometryProxy) -> CGFloat
    {
        var multipler : CGFloat = 0.5
        if isHorizontal(geometry: geometry) {
            multipler = expanded ? 1.0 : 0.5
        } else {
            multipler = expanded ? 0.4 : 0.5
        }
        return geometry.size.height * multipler
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ZStack {
                    NavigationView(content: {
                        ARDebugStepsView()
                            .navigationBarItems(trailing: Button(action: {
                                expanded.toggle()
                            }, label: {
                                Image(systemName: getBarItemIconName())
                            }))
                            .navigationBarTitleDisplayMode(.inline)
                    })
                    .onTapGesture(count: 2, perform: {
                        expanded.toggle()
                    })
                    .navigationViewStyle(StackNavigationViewStyle())
                }
                .animation(.easeInOut)
                .transition(.scale)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .background(Color.init(UIColor.systemGroupedBackground))
                .cornerRadius(25)
                .shadow(radius: 10)
            }
            .padding()
            .frame(width: getPanelWidth(geometry: geometry),
                   height: getPanelHeight(geometry: geometry),
                   alignment: .topLeading)
            .environmentObject(EnvironmentManager.shared.env)
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
