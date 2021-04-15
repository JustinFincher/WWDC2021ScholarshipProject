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

func sdSphere(p:simd_float3, c: simd_float3, r:Float) -> Float {
    return simd_length(p - c) - r;
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

func sdCapsule(p:simd_float3, a:simd_float3, b:simd_float3, r:Float) -> Float {
    let pa = p - a
    let ba = b - a
    let c = simd_dot(pa, ba) / simd_dot(ba, ba)
    let h = simd_clamp(c, 0.0, 1.0)
    return simd_length(pa - ba * h) - r
}

func opUnion(d1:Float, d2:Float) -> Float {
    return min(d1, d2)
}

