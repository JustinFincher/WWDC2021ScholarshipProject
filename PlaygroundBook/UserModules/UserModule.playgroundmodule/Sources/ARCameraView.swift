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

class ARCameraView: ARSCNView {
    
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
        self.delegate = OperationManager.shared
        self.session = OperationManager.shared.session
        self.scene = OperationManager.shared.scene
        self.debugOptions = [.showSkeletons, .showWorldOrigin]
        self.play(nil)
    }
    
}
