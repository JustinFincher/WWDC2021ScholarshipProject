//
//  EnvironmentManager.swift
//  Dynamic
//
//  Created by Fincher on 12/8/20.
//

import CoreLocation
import Foundation
import UIKit
import SwiftUI
import Combine

class DynamicEnvironment: ObservableObject
{
    @Published var showGlobalView : Bool = false
    @Published var globalView : AnyView = AnyView(Color.clear)
    func showView(view: AnyView, forTime: DispatchTimeInterval) -> Void {
        self.showGlobalView = true
        self.globalView = view
        print("showGlobalView \(showGlobalView)")
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.asyncAfter(deadline: .now() + forTime) {
                self.showGlobalView = false
                print("showGlobalView \(self.showGlobalView)")
            }
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
    
    let env: DynamicEnvironment = DynamicEnvironment()
    
    private override init() {}
    
    override class func setup() {
        print("EnvironmentManager.setup")
    }
}
