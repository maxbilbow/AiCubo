//
//  RMXPhysics.swift
//  RattleGL
//
//  Created by Max Bilbow on 10/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//
import Foundation
import GLKit

class RMXPhysics {
    ///metres per second per second
    var worldGravity: RMFloatB {
        return 0.098
    }
    
    var world: RMSWorld
    //public var world: RMXWorld
    var directionOfGravity: RMXVector3
    
    init(world: RMSWorld) {
        //if parent != nil {
            self.world = world
            self.directionOfGravity = RMXVector3Make(0,-1,0)
//        } else {
//            fatalError(__FUNCTION__)
//        }
    }
   
    var gravity: RMXVector3 {
        return self.directionOfGravity * self.worldGravity
    }
    
//    func gVector(hasGravity: Bool) -> RMXVector3 {
//        return GLKVector3MultiplyScalar(self.getGravityFor, hasGravity ? RMFloatB(-gravity) : 0 )
//    }
    
    
    
    func normalFor(sender: RMXSprite) -> RMXVector3 {
        let g = sender.position.y > 0 ? 0 : self.gravity.y
        return RMXVector3MultiplyScalar(RMXVector3Make(0, 0, 0),-RMFloatB(sender.node.physicsBody!.mass))
    }
    
    func gravityFor(sender: RMXSprite) -> RMXVector3{
        return RMXVector3MultiplyScalar(self.gravity, RMFloatB(sender.node.physicsBody!.mass))
    }
    
    
    
    func dragFor(sender: RMXSprite) -> RMXVector3{
        let dragC: RMFloat = sender.node.physicsBody!.mass
        let rho = RMFloat(0.005 * 0.02)
        let u = RMFloat(RMXVector3Length(sender.node.physicsBody!.velocity))
        let area = RMFloat(sender.node.scale.x * sender.node.scale.y)
        var v: RMXVector3 = RMXVector3Zero
        let drag = RMFloatB((0.5 * rho * u * u * dragC * area)/3)
        return RMXVector3Make(drag, drag, drag)
    }
    
    ///TODO: If colliding, compute. Otherwise return friction at ground level.
    func frictionFor(sender: RMXSprite) -> RMXVector3{
        let µ =  RMFloatB(sender.node.physicsBody!.friction)
        if sender.isGrounded {
            return RMXVector3Make(µ/3, 0, µ/3)
        } else {
            return RMXVector3Zero
        }
    }
    
   
}