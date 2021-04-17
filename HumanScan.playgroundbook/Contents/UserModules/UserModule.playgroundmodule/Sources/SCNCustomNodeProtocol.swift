//
//  SCNCustomNodeProtocol.swift
//  UserModuleFramework
//
//  Created by fincher on 4/13/21.
//

import Foundation
import SceneKit
import ARKit

protocol SCNCustomNode {
    func setup()
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval)
    func session(_ session: ARSession, didUpdate frame: ARFrame)
    func session(_ session: ARSession, didAdd anchors: [ARAnchor])
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor])
}
