//
//  SCNVector+Lerp.swift
//  UserModuleFramework
//
//  Created by fincher on 4/9/21.
//

import Foundation
import SceneKit

extension Float {
    func lerp(target: Float, ratio: Float) -> Float {
        return self + (target - self) * ratio
    }
}
extension SCNVector4 {
    func lerp(target: SCNVector4, ratio: Float) -> SCNVector4 {
        return SCNVector4(self.x.lerp(target: target.y, ratio: ratio),
                          self.y.lerp(target: target.y, ratio: ratio),
                          self.z.lerp(target: target.z, ratio: ratio),
                          self.w.lerp(target: target.w, ratio: ratio))
    }
}
