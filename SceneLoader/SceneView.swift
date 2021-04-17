//
//  TestSceneView.swift
//  DesktopTestBed
//
//  Created by fincher on 4/14/21.
//

import Foundation
import SceneKit
import Combine
import SwiftUI

class SceneView: SCNView {
    
    
    private var sceneLoadCancellable: AnyCancellable?
    
    func postInit() -> Void {
        self.showsStatistics = true
        self.allowsCameraControl = true
        self.debugOptions = [.showCameras, .showSkeletons, .showWireframe, .showBoundingBoxes]
        self.delegate = OperationManager.shared
        sceneLoadCancellable = EnvironmentManager.shared.env.$sceneURL.sink { (url : URL?) in
            if let url = url {
                do {
                    self.scene = try SCNScene(url: url, options: nil)
                } catch let err {
                    print(err)
                }
                self.play(nil)
            }
        }
    }
}

struct SceneSwiftUIView : UIViewRepresentable {
    func makeUIView(context: Context) -> SceneView {
        let view = SceneView(frame: .zero, options:nil)
        view.postInit()
        return view
    }
    
    func updateUIView(_ uiView: SceneView, context: Context) {
        
    }

    typealias UIViewType = SceneView
}
