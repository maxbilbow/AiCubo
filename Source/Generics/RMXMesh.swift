//
//  RMXMesh.swift
//  AiCubo
//
//  Created by Max Bilbow on 05/04/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation


#if iOS
import UIKit
    #if METAL
    import Metal
    #endif
#elseif OSX
    import GLKit
    import GLUT
#endif

class RMXMesh {

    #if METAL
    var vertexBuffer: MTLBuffer! = nil
    var indexBuffer: MTLBuffer! = nil
    #else
    var vertexBuffer: AnyObject! = nil
    var indexBuffer: AnyObject! = nil
    #endif

}
