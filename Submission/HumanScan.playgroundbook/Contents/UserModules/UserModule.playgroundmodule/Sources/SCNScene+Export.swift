//
//  SCNScene+Export.swift
//  UserModuleFramework
//
//  Created by fincher on 4/13/21.
//

import Foundation
import SceneKit

extension SCNScene {
    func exportAndReturnURL() -> URL? {
        let tempDirPath = FileManager.default.temporaryDirectory
        let tempFileURL = tempDirPath.appendingPathComponent("export.scn", isDirectory: false)
        
        if self.write(to:tempFileURL, options:nil, delegate: nil, progressHandler: { (progress: Float, error: Error?, stop: UnsafeMutablePointer<ObjCBool>) in
            print("export \(progress)")
        }) {
            return tempFileURL
        } else {
            return nil
        }
    }
}
