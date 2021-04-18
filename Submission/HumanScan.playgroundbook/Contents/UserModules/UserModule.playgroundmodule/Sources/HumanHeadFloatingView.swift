//
//  HumanHeadFloatingView.swift
//  UserModuleFramework
//
//  Created by fincher on 4/13/21.
//

import SwiftUI

struct HumanHeadFloatingView: View {
    
    @EnvironmentObject var environment: DataEnvironment
    
    var body: some View {
        ZStack {
            Text("text")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .edgesIgnoringSafeArea(.all)
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct HumanHeadFloatingView_Previews: PreviewProvider {
    static var previews: some View {
        HumanHeadFloatingView()
    }
}
