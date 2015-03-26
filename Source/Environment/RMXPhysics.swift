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
    var worldGravity: Float {
        return 9.8 * self.world.gravityScaler
    }
    
    var world: RMSWorld
    //public var world: RMXWorld
    var directionOfGravity: RMXVector3
    
    init(world: RMSWorld) {
        //if parent != nil {
            self.world = world
            self.directionOfGravity = GLKVector3Make(0,-1,0)
//        } else {
//            fatalError(__FUNCTION__)
//        }
    }
   
    var gravity: GLKVector3 {
        return self.directionOfGravity * self.worldGravity
    }
    
//    func gVector(hasGravity: Bool) -> RMXVector3 {
//        return GLKVector3MultiplyScalar(self.getGravityFor, hasGravity ? Float(-gravity) : 0 )
//    }
    
    
    
    func normalFor(sender: RMSParticle) -> RMXVector3 {
        let g = sender.body.position.y > 0 ? 0 : self.gravity.y
        return GLKVector3MultiplyScalar(GLKVector3Make(0, 0, 0),-sender.body.mass)
    }
    
    func gravityFor(sender: RMSParticle) -> RMXVector3{
        return GLKVector3MultiplyScalar(self.gravity,sender.body.mass)
    }
    
    
    
    func dragFor(sender: RMSParticle) -> RMXVector3{
        let dragC: Float = sender.body.dragC
        let rho: Float = 0.005 * sender.world!.massDensityAt(sender)
        let u: Float = GLKVector3Length(sender.body.velocity)
        let area: Float = sender.body.dragArea
        var v: RMXVector3 = RMXVector3Zero
        RMXVector3SetX(&v, 0.5 * rho * u * u * dragC * area)
        return v
    }
    
    func frictionFor(sender: RMSParticle) -> RMXVector3{
        let µ = sender.world!.µAt(sender)
        return GLKVector3Make(µ, µ, µ);//TODO
    }
    
   
}