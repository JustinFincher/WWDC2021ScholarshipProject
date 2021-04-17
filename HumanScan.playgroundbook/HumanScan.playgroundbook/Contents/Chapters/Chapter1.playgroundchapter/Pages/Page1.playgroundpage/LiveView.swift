//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  Instantiates a live view and passes it to the PlaygroundSupport framework.
//

import PlaygroundSupport
import SwiftUI
import UserModule

PlaygroundPage.current.setLiveView(PlaygroundManager.shared.vc)
