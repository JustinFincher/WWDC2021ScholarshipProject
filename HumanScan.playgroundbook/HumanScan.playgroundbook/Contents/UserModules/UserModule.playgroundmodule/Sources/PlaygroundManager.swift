//
//  PlaygroundManager.swift
//  UserModuleFramework
//
//  Created by fincher on 4/11/21.
//

import Foundation

public class PlaygroundManager
{
    public static let shared: PlaygroundManager = PlaygroundManager()
    
    public let vc: LiveViewController = LiveViewController()
    
    public init() {
        RuntimeManager.shared.spawn()
    }
}
