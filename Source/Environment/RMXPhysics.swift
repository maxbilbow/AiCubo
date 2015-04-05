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
    var worldGravity: RMFloat {
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
//        return GLKVector3MultiplyScalar(self.getGravityFor, hasGravity ? RMFloat(-gravity) : 0 )
//    }
    
    
    
    func normalFor(sender: RMXNode) -> RMXVector3 {
        let g = sender.position.y > 0 ? 0 : self.gravity.y
        return RMXVector3MultiplyScalar(RMXVector3Make(0, 0, 0),-sender.body!.mass)
    }
    
    func gravityFor(sender: RMXNode) -> RMXVector3{
        return RMXVector3MultiplyScalar(self.gravity,sender.body!.mass)
    }
    
    
    
    func dragFor(sender: RMXNode) -> RMXVector3{
        let dragC: RMFloat = sender.body!.dragC
        let rho: RMFloat = 0.005 * sender.world.massDensityAt(sender)
        let u: RMFloat = RMXVector3Length(sender.body!.velocity)
        let area: RMFloat = sender.body!.dragArea
        var v: RMXVector3 = RMXVector3Zero
        let drag = (0.5 * rho * u * u * dragC * area)/3
        return RMXVector3Make(drag, drag, drag)
    }
    
    func frictionFor(sender: RMXNode) -> RMXVector3{
        let µ = sender.world.µAt(sender)
        return RMXVector3Make(µ/3, 0, µ/3);//TODO
    }
    
   
}