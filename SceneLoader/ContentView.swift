//
//  ContentView.swift
//  AnimationAuthorTool
//
//  Created by fincher on 4/16/21.
//

import SwiftUI

struct ContentView: View {
    @State var frameCount : Int = 0
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 8, content: {

                Button(action: {
                    let picker = DocumentPickerViewController(supportedExtensions: ["scn"]) { (url: URL) in
                        print(url)
                        EnvironmentManager.shared.env.sceneURL = url
                    } onDismiss: {
                        
                    }
                    UIApplication.shared.windows.first?.rootViewController?.present(picker, animated: true)
                    
                }, label: {
                    FilledButtonView(icon: "", text: "import scene", color: Color.accentColor, shadow: false, primary: false)
                })
            })
            .padding()
            .navigationTitle("Operations")
            
            SceneSwiftUIView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
