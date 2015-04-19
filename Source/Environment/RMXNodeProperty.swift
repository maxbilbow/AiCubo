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
    var owner: RMXNode! { get set }
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
    var owner: RMXNode!
    var world: RMSWorld {
        return self.owner.world
    }
    #if SceneKit
    var body: SCNPhysicsBody {
        return self.owner.body!
    }
    #else
    var body: RMSPhysicsBody {
        return self.owner.body!
    }
    #endif
    
    var actions: RMXSpriteActions {
        return self.owner.actions
    }
    
    var collisionBody: RMSCollisionBody {
        return self.owner.collisionBody
    }
    
    var physics: RMXPhysics {
        return self.world.physics
    }
    
    var position: RMXVector3 {
        return self.owner.position
    }
    
    func animate(){
        
    }
    
    init(_ owner: RMXNode){
        self.owner = owner
    }
}