//
//  Data.swift
//  UserModuleFramework
//
//  Created by fincher on 4/7/21.
//

import Foundation
import MetalKit
import SceneKit

enum AROperationMode {
    case captureSekeleton
    case positionSekeleton
    case attachPointCloud
    case removeBgAndRig
    case animateSkeleton
}

protocol RenderDestinationProvider {
    var currentRenderPassDescriptor: MTLRenderPassDescriptor? { get }
    var currentDrawable: CAMetalDrawable? { get }
    var colorPixelFormat: MTLPixelFormat { get set }
    var depthStencilPixelFormat: MTLPixelFormat { get set }
    var sampleCount: Int { get set }
}

struct ARKitSkeletonAnimationFrame : Codable {
    var joints : Dictionary<String, simd_float4x4> = Dictionary<String, simd_float4x4>()
}

struct ARKitSkeletonAnimation : Codable {
    var frames : [ARKitSkeletonAnimationFrame] = []
    mutating func addFrame(frame: ARKitSkeletonAnimationFrame){
        frames.append(frame)
    }
    mutating func removeFirstFrame() {
        frames.removeFirst()
    }
}
