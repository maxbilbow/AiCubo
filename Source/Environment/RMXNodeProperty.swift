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

protocol RMXNodeProperty {
    var parent: RMXNode! { get set }
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
    func animate()
}


class RMSNodeProperty: RMXNodeProperty {
    var parent: RMXNode!
    var world: RMSWorld {
        return self.parent.world
    }
    #if SceneKit
    var body: SCNPhysicsBody {
        return self.parent.body!
    }
    #else
    var body: RMSPhysicsBody {
        return self.parent.body!
    }
    #endif
    
    var actions: RMXSpriteActions {
        return self.parent.actions
    }
    
    var collisionBody: RMSCollisionBody {
        return self.parent.collisionBody
    }
    
    var physics: RMXPhysics {
        return self.world.physics
    }
    
    var position: RMXVector3 {
        return self.parent.position
    }
    
    func animate(){
        
    }
    
    init(_ parent: RMXNode){
        self.parent = parent
    }
}