//
//  RMXNodeProperty.swift
//  AiCubo
//
//  Created by Max Bilbow on 31/03/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
import GLKit
#if SceneKit
    import SceneKit
    #endif

protocol RMXSpriteProperty {
    var owner: RMXSprite! { get }
    var world: RMSWorld { get }
//    var actions: RMXSpriteActions { get }
//    #if SceneKit
//    var body: SCNPhysicsBody { get }
//    #else
//    var body: RMSPhysicsBody { get }
//    #endif
//    var collisionBody: RMSCollisionBody { get }
//    var physics: RMXPhysics { get }
//    var position: GLKVector3 { get }
//    func animate()
}

