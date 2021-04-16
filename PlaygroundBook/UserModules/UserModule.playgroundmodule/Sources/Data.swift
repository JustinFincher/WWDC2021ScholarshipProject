//
//  Data.swift
//  UserModuleFramework
//
//  Created by fincher on 4/7/21.
//

import Foundation
import MetalKit

enum AROperationMode {
    case captureSekeleton
    case positionSekeleton
    case attachPointCloud
    case setBoundingBox
    case rigAnimation
}

struct EntityDisplayModel: Hashable, Identifiable {
    var id: Self { self }
    var key: String
    var value: String
    var children: [EntityDisplayModel]? = nil
}

protocol RenderDestinationProvider {
    var currentRenderPassDescriptor: MTLRenderPassDescriptor? { get }
    var currentDrawable: CAMetalDrawable? { get }
    var colorPixelFormat: MTLPixelFormat { get set }
    var depthStencilPixelFormat: MTLPixelFormat { get set }
    var sampleCount: Int { get set }
}
