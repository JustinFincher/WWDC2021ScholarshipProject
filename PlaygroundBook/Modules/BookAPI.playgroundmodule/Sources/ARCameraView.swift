//
//  ARCameraView.swift
//  BookCore
//
//  Created by fincher on 4/6/21.
//

import Foundation
import SceneKit
import ARKit

class ARCameraView: ARSCNView, ARSCNViewDelegate, ARSessionDelegate {
    
    init() {
        super.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        postInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect, options: [String : Any]? = nil) {
        super.init(frame: frame, options: options)
    }
    
    func postInit() -> Void {
        self.automaticallyUpdatesLighting = true
        self.showsStatistics = true
        self.delegate = self
        self.session.delegate = self
        self.scene = SCNScene()
        let configuration = ARWorldTrackingConfiguration()
        self.session.run(configuration, options: [])
        self.play(nil)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
    }
}
