//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  A source file which is part of the auxiliary module named "BookCore".
//  Provides the implementation of the "always-on" live view.
//

import UIKit
import PlaygroundSupport
import SwiftUI

@objc(BookCore_LiveViewController)
public class LiveViewController: UIViewController, PlaygroundLiveViewMessageHandler, PlaygroundLiveViewSafeAreaContainer {
    
    let cameraView : ARCameraView = ARCameraView()
    let debugViewController = UIHostingController(rootView: ARDebugView())
    
    public override func viewDidLoad() {
        
        cameraView.frame = CGRect.init(origin: CGPoint.init(x: 0, y: 0), size:self.view.bounds.size)
        cameraView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.view.addSubview(cameraView)
        
        debugViewController.view.frame = self.view.frame
        debugViewController.view.backgroundColor = .clear
        self.view.addSubview(debugViewController.view)
        debugViewController.didMove(toParent: self)
    }
    
    /*
    public func liveViewMessageConnectionOpened() {
        // Implement this method to be notified when the live view message connection is opened.
        // The connection will be opened when the process running Contents.swift starts running and listening for messages.
    }
    */

    /*
    public func liveViewMessageConnectionClosed() {
        // Implement this method to be notified when the live view message connection is closed.
        // The connection will be closed when the process running Contents.swift exits and is no longer listening for messages.
        // This happens when the user's code naturally finishes running, if the user presses Stop, or if there is a crash.
    }
    */

    public func receive(_ message: PlaygroundValue) {
        // Implement this method to receive messages sent from the process running Contents.swift.
        // This method is *required* by the PlaygroundLiveViewMessageHandler protocol.
        // Use this method to decode any messages sent as PlaygroundValue values and respond accordingly.
    }
}
