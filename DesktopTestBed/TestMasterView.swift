//
//  TestDebugView.swift
//  DesktopTestBed
//
//  Created by fincher on 4/14/21.
//

import SwiftUI
import SceneKit

struct TestDebugView: View {
    var body: some View {
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
            
            Button(action: {
                OperationManager.shared.filterPoints {
                    
                }
            }, label: {
                FilledButtonView(icon: "", text: "filter points", color: Color.accentColor, shadow: false, primary: false)
            })
            
            Button(action: {
                OperationManager.shared.rig()
            }, label: {
                FilledButtonView(icon: "", text: "rig", color: Color.accentColor, shadow: false, primary: false)
            })
            
            Button(action: {
                let picker = DocumentPickerViewController(supportedExtensions: ["dae","scn","scnz"]) { (url: URL) in
                    print(url)
                    
                    do {
                        let scene = try SCNScene(url: url, options: nil)
                        scene.rootNode.examineAnimatable()
                    } catch let err {
                        print(err)
                    }
                } onDismiss: {
                    
                }
                UIApplication.shared.windows.first?.rootViewController?.present(picker, animated: true)
            }, label: {
                FilledButtonView(icon: "", text: "animate", color: Color.accentColor, shadow: false, primary: false)
            })
            
            Button(action: {
                if let url = EnvironmentManager.shared.env.sceneURL
                {
                    let lastComp = url.deletingPathExtension().lastPathComponent + "-export"
                    let target = url.deletingLastPathComponent()
                        .appendingPathComponent(lastComp)
                        .appendingPathExtension("scn")
                    OperationManager.shared.scene.write(to: target, options: nil, delegate: nil, progressHandler: nil)
                }
            }, label: {
                FilledButtonView(icon: "", text: "export scene", color: Color.accentColor, shadow: false, primary: false)
            })
        }).padding()
    }
}

struct TestMasterView : View {
    var body: some View {
        TestDebugView()
            .navigationTitle("Control")
    }
}

struct TestDebugView_Previews: PreviewProvider {
    static var previews: some View {
        TestDebugView()
    }
}
