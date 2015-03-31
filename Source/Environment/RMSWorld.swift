//
//  RMSWorld.swift
//  RattleGL
//
//  Created by Max Bilbow on 10/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import GLKit

class RMSWorld : RMSParticle {
    
    let gravityScaler: Float = 0.05
    ///TODO: Create thos for timekeeping
    var clock: RMXClock?

    lazy var actionProcessor: RMSActionProcessor = RMSActionProcessor(world: self)
    
    
    var sun: RMSParticle?
    private let GRAVITY: Float = 9.8
    
    
    
    
    
    lazy var activeSprite: RMSParticle = RMSParticle(parent: self).setAsObserver()
    lazy var physics: RMXPhysics = RMXPhysics(world: self)
    
    lazy var observer: RMSParticle = self.activeSprite
    
    lazy var activeCamera: RMXCamera = RMXCamera(self.observer)
    

    
    init(parent: RMXObject! = nil, name: String = "The World", capacity: Int = 15000) {
        super.init(parent: nil, type: .WORLD, name: name)
//        self.children.c.reserveCapacity(capacity)
        self.world = self
        self.body.radius = 2000
        self.activeSprite.addInitCall { () -> () in
            self.observer.position = GLKVector3Make(20, 20, 20)
        }
        
        self.activeCamera = RMXCamera(self.activeSprite)
        
        self.children[self.activeSprite.rmxID] = self.activeSprite
        //fatalError("Grav: \(self.physics.gravity)")
         self.isAnimated = false
        self.shape.isVisible = false
        
    }
    
  
   
            
    func µAt(someBody: RMSParticle) -> Float {
        if !someBody.isInWorld && someBody.isObserver {
            return 0.0000001
        } else if (someBody.position.y <= someBody.ground   ) {
            return 0.2// * RMXGetSpeed(someBody->body.velocity);//Rolling wheel resistance
        } else {
            return 0.01 //air;
        }

    }
    func massDensityAt(someBody: RMSParticle) -> Float {
        if !someBody.isInWorld && someBody.isObserver {
            return 0.0000001
        } else if someBody.position.y < someBody.ground   {// 8 / 10 ) {// someBody.ground )
            return 99.1 //water or other
        } else {
            return 0.01
        }
    }
    func collisionTest(sender: RMSParticle) -> Bool{
    //Have I gone through a barrier?
        let velocity = sender.body.velocity
        let v = velocity.y
        let p = sender.position.y
        let next = sender.body.velocity + sender.position
        let bounceY: Float = -v
        let g = sender.ground
        if p <= g && v < 0 && sender.isInWorld {
            if p < g / sender.body.coushin {
                RMXVector3SetY(&sender.body.velocity, bounceY * sender.body.coushin)
                RMXVector3SetY(&sender.position, g)
            } else {
                RMXVector3SetY(&sender.body.velocity, sender.hasGravity ? 0 : bounceY * sender.body.coushin)
                RMXVector3SetY(&sender.position, g)
            }
            return true
        }
        if GLKVector3Length(next) >= self.body.radius && sender.type != .OBSERVER {
            sender.actions.headTo(self)
            sender.body.velocity = GLKVector3Negate(velocity)
        }
        
        return false
    }
    
    func gravityAt(sender: RMSParticle) -> RMXVector3 {
        return self.physics.gravityFor(sender)
    }
    
    
   
    override func animate() {
        self.actionProcessor.animate()
        self.debug()
        super.animate()
    }
    
    override func reset() {
        self.observer.reset()
        //super.reset()
    }
    
    func closestObjectTo(sender: RMSParticle)->RMSParticle? {
        var closest: Int = -1
        var dista: Float = Float.infinity// = sender.body.distanceTo(closest)
        for object in children {
            let child = object.1
            if child != sender {
                let distb: Float = sender.body.distanceTo(child)
                if distb < dista {
                    closest = child.rmxID
                    dista = distb
                }
            }
        }
        if let result = children[closest] {
            if dista < sender.actions.reach + result.body.radius  {
                return result
            }
        }
        return nil
    }
    
    func furthestObjectFrom(sender: RMSParticle)->RMSParticle? {
        var furthest: Int = -1
        var dista: Float = 0// = sender.body.distanceTo(closest)
        for object in children {
            let child = object.1
            if child != sender {
                let distb: Float = sender.body.distanceTo(child)
                if distb > dista {
                    furthest = child.rmxID
                    dista = distb
                }
            }
        }
        if let result = children[furthest] {
                return result
        }   else { return nil }
    }
    
  
    //private var _hasGravity = false
    override func toggleGravity() {
        for object in children {
            let child = object.1
            if (child != self.observer) && !(child.isLightSource) {
                child.setHasGravity(self.hasGravity)
            }
        }
        super.toggleGravity()
    }

    
    func action(action: String = "reset",speed: Float = 0, point: [Float] = []) {
        self.actionProcessor.movement( action,speed: speed, point: point)
    }
    
    
    
}


/* 
private func normalForceAt(sender: RMSParticle) -> RMXVector3 {
var result: Float = 0
var bounce: Float = 0
let normal = self.physics.normalFor(sender)
let altitude = sender.body.position.y
let ground = sender.ground
if altitude < 0 {
RMXVector3SetY(&sender.body.position, 0)
}
if altitude < ground { //* 9 / 10 {
if let bouncing = sender.variables["isBouncing"] {
if bouncing.isActive {
bouncing.i *= 0.8
if bouncing.i <= 0.1 {
bounce = 0
bouncing.isActive = false
bouncing.i = 0
RMXVector3SetY(&sender.body.position, ground)
//                        print(__LINE__)
} else {
bounce = bouncing.i
//                        print(__LINE__)
}

} else {

bouncing.i += 0.01
if bouncing.i >= 1 {
bouncing.isActive = true
//                        print(__LINE__)
} else {
bounce = 0
//                        print(__LINE__)
}
}
}
//            print(__LINE__)
result = normal.y + (1 + fabs(altitude / ground + altitude)) * bounce
} else if altitude  <= ground  {
result = normal.y
RMXVector3SetY(&sender.body.position, ground)
//            print(__LINE__)
} else if altitude > ground {
result = 0//someBody.weight// * self.physics.gravity; //air;
//            print(__LINE__)
} else {
result = normal.y
//            print(__LINE__)
}
//        println(": \(bounce) \(result) \(self.physics.gravity.print)\n")
return GLKVector3Make(0, result, 0)
}
*/
*/
