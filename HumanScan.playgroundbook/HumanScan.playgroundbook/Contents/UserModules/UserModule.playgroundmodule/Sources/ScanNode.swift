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
    
    override class var supportsSecureCoding: Bool {
        return true
    }
    
    var pointCloudCollector: PointCloudCollector?
    
    func setup() {
        name = "scan"
        if pointCloudCollector == nil
        {
            pointCloudCollector = PointCloudCollector(session: OperationManager.shared.session, metalDevice: OperationManager.shared.device)
            pointCloudCollector?.pointCloudsUpdated = {() in
                if let pointCloudCollector = self.pointCloudCollector {
                    self.geometry = SCNGeometry(buffer: pointCloudCollector.particlesBuffer).withAlphaMaterial()
                }
            }
        }
    }
    
    func setAlpha(alpha: Float) -> Void {
        self.geometry?.firstMaterial?.transparencyMode = .singleLayer
        self.geometry?.firstMaterial?.lightingModel = .constant
        self.geometry?.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(CGFloat(alpha))
        self.geometry?.firstMaterial?.transparency = CGFloat(alpha)
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
        case .removeBgAndRig:
            break
        case .animateSkeleton:
            break
        case .positionSekeleton:
            break
        case .recordAnimation:
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
