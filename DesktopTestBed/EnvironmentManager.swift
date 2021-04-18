//
//  EnvironmentManager.swift
//  DesktopTestBed
//
//  Created by fincher on 4/14/21.
//

import Foundation

class DataEnvironment: ObservableObject
{
    @Published var sceneURL : URL? = nil
    @Published var positionAddX : Double = 0.0
    @Published var positionAddY : Double = 0.0
    @Published var positionAddZ : Double = 0.0
    @Published var arOperationMode : AROperationMode = !arDebugMode ? AROperationMode.attachPointCloud : AROperationMode.recordAnimation
    
    func triggerUpdate(content: @escaping (_ env: DataEnvironment) -> Void) {
        DispatchQueue.main.async {
            content(self)
            self.objectWillChange.send()
        }
    }
    
    init() {
    }
}

class EnvironmentManager: RuntimeManagableSingleton {
    
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
