//
//  ScanNode.swift
//  UserModuleFramework
//
//  Created by fincher on 4/13/21.
//

import Foundation
import SceneKit
import ARKit

class ScanNode: SCNNode, SCNCustomNode
{
    
    var pointCloudCollector: PointCloudCollector?
    
    func setup() {
        name = "scan"
        pointCloudCollector = PointCloudCollector(session: OperationManager.shared.session, metalDevice: OperationManager.shared.device)
        pointCloudCollector?.pointCloudsUpdated = {() in
            if let pointCloudCollector = self.pointCloudCollector {
                self.geometry = SCNGeometry(buffer: pointCloudCollector.particlesBuffer).withAlphaMaterial()
            }
        }
    }
    
    //MARK: - SCNCustomNode
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        pointCloudCollector?.drawRectResized(size: frame.camera.imageResolution)
        switch EnvironmentManager.shared.env.arOperationMode {
        case .attachPointCloud:
            pointCloudCollector?.draw()
            break
        case .captureSekeleton:
            break
        case .setBoundingBox:
            break
        case .rigAnimation:
            break
        case .positionSekeleton:
            break
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
    }
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        
    }
}
