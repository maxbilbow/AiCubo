//
//  RMSChildNode.swift
//  AiCubo
//
//  Created by Max Bilbow on 31/03/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
protocol RMXChildNode {
    var parent: RMSParticle { get set }
    var world: RMSWorld { get }
    var actions: RMXSpriteActions { get }
    var body: RMSPhysicsBody { get }
    var collisionBody: RMSCollisionBody { get }
    var physics: RMXPhysics { get }
    var position: GLKVector3 { get }
}


class RMSChildNode : RMXChildNode {
    var parent: RMSParticle
    var world: RMSWorld {
        return self.parent.world!
    }
    
    var body: RMSPhysicsBody {
        return self.parent.body
    }
    
    var actions: RMXSpriteActions {
        return self.parent.actions
    }
    
    var collisionBody: RMSCollisionBody {
        return self.parent.collisionBody
    }
    
    var physics: RMXPhysics {
        return self.world.physics
    }
    
    var position: GLKVector3 {
        return self.parent.position
    }
    
    
    init(_ parent: RMSParticle){
        self.parent = parent
    }
}