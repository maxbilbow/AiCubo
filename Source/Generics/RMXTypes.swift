//
//  RMXVertex.swift
//  AiCubo
//
//  Created by Max Bilbow on 05/04/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
import GLKit

typealias MBEIndexType = uint16_t

struct Uniforms {
    var viewProjectionMatrix: GLKMatrix4
}

struct PerInstanceUniforms {
    var modelMatrix: GLKMatrix4
    var normalMatrix: GLKMatrix3
}

struct RMXVertex {
    var position, normal: GLKVector4 //packed_float4?
    var texCoords: GLKVector2 //packed_float2
}
