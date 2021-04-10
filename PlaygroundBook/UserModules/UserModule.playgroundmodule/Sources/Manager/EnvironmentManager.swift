//
//  EnvironmentManager.swift
//  Dynamic
//
//  Created by Fincher on 12/8/20.
//

import CoreLocation
import Foundation
import GameplayKit
import UIKit
import SwiftUI
import Combine
import ARKit

class DataEnvironment: ObservableObject
{
    @Published var arOperationMode : AROperationMode = AROperationMode.pointCloud
    
    func triggerUpdate(content: @escaping (_ env: DataEnvironment) -> Void) {
        DispatchQueue.main.async {
            content(self)
            self.objectWillChange.send()
        }
    }
    
    init() {
    }
}

class EnvironmentManager : RuntimeManagableSingleton
{
    static let shared: EnvironmentManager = {
        let instance = EnvironmentManager()
        return instance
    }()
    
    let env: DataEnvironment = DataEnvironment()
    
    private override init() {}
    
    override class func setup() {
        print("EnvironmentManager.setup")
    }

}
