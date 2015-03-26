//
//  RMX.swift
//  RattleGL
//
//  Created by Max Bilbow on 17/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation


public struct RMX {
    static let isDebugging: Bool = false
    static let isFullscreen: Bool = false
    static let usingDepreciated: Bool = true
    static let usingSceneKit: Bool = false
}
import GLKit

#if OPENGL_ES
    import UIKit
    typealias RMXView = GLKView
    typealias RMXContext = EAGLContext
    typealias RMXController = RMXDPad
    #elseif OPENGL_OSX
    import Cocoa
    import OpenGL
    import GLUT
    typealias RMXController = RMSKeys
    typealias GLKViewController = NSViewController
    typealias RMXView = NSOpenGLView
    typealias RMXContext = UnsafeMutablePointer<_CGLContextObject>
#endif
