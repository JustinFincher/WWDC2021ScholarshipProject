//
//  LiveViewController.swift
//  UserModule
//
//  Created by fincher on 5/11/20.
//

import Foundation
import UIKit
import PlaygroundSupport
import SwiftUI

open class LiveViewController : UIViewController, PlaygroundLiveViewMessageHandler, PlaygroundLiveViewSafeAreaContainer
{
    let debugViewController = UIHostingController(rootView: ARDebugView())
    let cameraView : ARCameraView = ARCameraView()
    
    public override func viewDidLoad() {
        UIApplication.shared.isIdleTimerDisabled = true
        
        RuntimeManager.shared.spawn()
        
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
