//
//  ARCameraView.swift
//  UserModule
//
//  Created by fincher on 4/6/21.
//

import Foundation
import SceneKit
import ARKit
import SwiftUI

class ARCameraView: ARSCNView, ARSCNViewDelegate, ARSessionDelegate {
    
    let debugViewController = UIHostingController(rootView: ARDebugView())
    
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
        debugViewController.view.frame = self.frame
        debugViewController.view.backgroundColor = .clear
        self.addSubview(debugViewController.view)
        debugViewController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        self.automaticallyUpdatesLighting = true
        self.showsStatistics = true
        self.delegate = self
        self.session.delegate = self
        self.scene = SCNScene()
        self.debugOptions = [.renderAsWireframe]
        let configuration = ARWorldTrackingConfiguration()
        configuration.appClipCodeTrackingEnabled = false
        configuration.environmentTexturing = .automatic
        configuration.isCollaborationEnabled = true
        configuration.sceneReconstruction = .mesh
        self.session.run(configuration, options: [])
        self.play(nil)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if let meshAnchor : ARMeshAnchor = anchor as? ARMeshAnchor {
            let geometry = SCNGeometry(arGeometry: meshAnchor.geometry)
            geometry.assignReflectiveMaterial()
            let node = SCNNode()
            node.geometry = geometry
            return node
        }
        return nil
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let meshAnchor : ARMeshAnchor = anchor as? ARMeshAnchor {
            let geometry = SCNGeometry(arGeometry: meshAnchor.geometry)
            geometry.assignReflectiveMaterial()
            node.geometry = geometry
        }
    }
}
