//
//  SDF.swift
//  LiveViewTestApp
//
//  Created by fincher on 4/14/21.
//
// converted from https://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm

import Accelerate
import Foundation
import SceneKit

func sdSphere(p:simd_float3, s:Float) -> Float {
    return simd_length(p) - s;
}

func sdBox(p:simd_float3, b:Float) -> Float {
    let q : simd_float3 = simd_abs(p) - b
    let first = simd_length(simd_max(q, simd_float3(0,0,0)))
    let second = simd_min(simd_max(q.x, max(q.y, q.z)), 0.0)
    return first + second
}

func sdVerticalCapsule(p:simd_float3, h:Float, r:Float) -> Float {
    var p = p
    p.y = p.y - simd_clamp(p.y, 0.0, h)
    return simd_length(p) - r
}

func opUnion(d1:Float, d2:Float) -> Float {
    return min(d1, d2)
}
