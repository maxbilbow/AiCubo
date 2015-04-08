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
        return 9.8 * self.world.gravityScaler
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
    
    
    
    func normalFor(sender: RMXNode) -> RMXVector3 {
        let g = sender.position.y > 0 ? 0 : self.gravity.y
        return RMXVector3MultiplyScalar(RMXVector3Make(0, 0, 0),-RMFloatB(sender.body!.mass))
    }
    
    func gravityFor(sender: RMXNode) -> RMXVector3{
        return RMXVector3MultiplyScalar(self.gravity, RMFloatB(sender.body!.mass))
    }
    
    
    
    func dragFor(sender: RMXNode) -> RMXVector3{
        let dragC: RMFloatB = sender.body!.dragC
        let rho: RMFloatB = 0.005 * sender.world.massDensityAt(sender)
        let u: RMFloatB = RMXVector3Length(sender.body!.velocity)
        let area: RMFloatB = sender.body!.dragArea
        var v: RMXVector3 = RMXVector3Zero
        let drag = (0.5 * rho * u * u * dragC * area)/3
        return RMXVector3Make(drag, drag, drag)
    }
    
    func frictionFor(sender: RMXNode) -> RMXVector3{
        let µ = sender.world.µAt(sender)
        return RMXVector3Make(µ/3, 0, µ/3);//TODO
    }
    
   
}