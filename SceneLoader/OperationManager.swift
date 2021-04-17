//
//  OperationManager.swift
//  DesktopTestBed
//
//  Created by fincher on 4/14/21.
//

import SceneKit
import MobileCoreServices
import Combine

class OperationManager: RuntimeManagableSingleton, SCNSceneRendererDelegate
{   
    static let shared: OperationManager = {
        let instance = OperationManager()
        return instance
    }()
    
    private override init() {
        
    }
    
    override class func setup() {
        print("OperationManager.setup")
    }
    
    // MARK: - SCNSceneRendererDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
       
    }
}
