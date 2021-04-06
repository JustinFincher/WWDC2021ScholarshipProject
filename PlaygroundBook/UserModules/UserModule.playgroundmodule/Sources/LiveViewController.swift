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
    let cameraView : ARCameraView = ARCameraView()
    
    public override func viewDidLoad() {
        
        cameraView.frame = CGRect.init(origin: CGPoint.init(x: 0, y: 0), size:self.view.bounds.size)
        cameraView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.view.addSubview(cameraView)
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
