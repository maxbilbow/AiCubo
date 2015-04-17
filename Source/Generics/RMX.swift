//
//  RMX.swift
//  RattleGL
//
//  Created by Max Bilbow on 17/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation

enum PoppyState: Int32 { case IDLE = 1, READY_TO_CHASE , CHASING, FETCHING }

public struct RMX {

    static let isFullscreen: Bool = false
    static let usingDepreciated: Bool = true
    static let usingSceneKit: Bool = false
}

import GLKit

#if OPENGL_ES
    import UIKit
//    typealias RMXView = UIView
    typealias RMXContext = EAGLContext
//    typealias RMXController = RMXDPad
    #elseif OSX
    import Cocoa
    import OpenGL
    import GLUT
//    typealias RMXController = RMSKeys
    typealias GLKViewController = NSViewController
//    typealias RMXView = NSView
    typealias RMXContext = UnsafeMutablePointer<_CGLContextObject>
#endif

#if iOS
typealias NSColor = UIColor
#endif

func == (lhs: RMXSprite, rhs: RMXSprite) -> Bool {
    return lhs.rmxID == rhs.rmxID
}


func != (lhs: RMXSprite, rhs: RMXSprite) -> Bool {
    return lhs.rmxID != rhs.rmxID
}

