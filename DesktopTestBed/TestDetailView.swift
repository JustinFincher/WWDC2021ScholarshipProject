//
//  TestSceneView.swift
//  DesktopTestBed
//
//  Created by fincher on 4/14/21.
//

import Foundation
import SceneKit
import SwiftUI

class TestSceneView: SCNView {
    func postInit() -> Void {
        self.scene = OperationManager.shared.scene
        self.showsStatistics = true
        self.allowsCameraControl = true
        self.play(nil)
        self.delegate = OperationManager.shared
    }
}

struct TestDetailView : View {
    var body: some View {
        TestSceneSwiftUIView()
            .navigationTitle("Scene")
    }
}

struct TestSceneSwiftUIView : UIViewRepresentable {
    func makeUIView(context: Context) -> TestSceneView {
        let view = TestSceneView()
        view.postInit()
        return view
    }
    
    func updateUIView(_ uiView: TestSceneView, context: Context) {
        
    }

    typealias UIViewType = TestSceneView
}
