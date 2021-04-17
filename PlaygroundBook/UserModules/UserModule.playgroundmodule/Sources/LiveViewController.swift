//
//  LiveViewController.swift
//  UserModule
//
//  Created by fincher on 5/11/20.
//

import Foundation
import UIKit
import SceneKit
import PlaygroundSupport
import SwiftUI

open class LiveViewController : UIViewController, PlaygroundLiveViewMessageHandler, PlaygroundLiveViewSafeAreaContainer
{
    let debugViewController = UIHostingController(rootView: ARDebugView())
    let cameraView : ARCameraView = ARCameraView(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0), options:
//                                                    [SCNView.Option.preferredRenderingAPI.rawValue : SCNRenderingAPI.openGLES2]
                                                 nil
    )
    
    public override func viewDidLoad() {
        cameraView.frame = CGRect.init(origin: CGPoint.init(x: 0, y: 0), size:self.view.bounds.size)
        cameraView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.view.addSubview(cameraView)
        
        debugViewController.view.frame = self.view.frame
        debugViewController.view.backgroundColor = .clear
        self.cameraView.addSubview(debugViewController.view)
        debugViewController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        debugViewController.didMove(toParent: self)
    }
    
    //MARK: PlaygroundLiveViewMessageHandler
    
    public func receive(_ message: PlaygroundValue) {
        // guard case let .string(messageString) = message else { return }
    }
    
    public func send(_ message: PlaygroundValue) {
        
    }
    
    public func liveViewMessageConnectionClosed() {
    }
    
    public func liveViewMessageConnectionOpened() {
    }
    
    //MARK: PlaygroundLiveViewSafeAreaContainer
}
