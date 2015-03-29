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
    var sprites: Array<RMSParticle>
    
    var drawables: Array<RMSParticle>{
        return self.sprites.filter { (sprite: RMSParticle) -> Bool in
            return sprite.shape.type != .NULL && sprite.shape.isVisible
        }
    }
    
    lazy var observer: RMSParticle = RMSParticle(world: self, parent: self).setAsObserver()
    lazy var physics: RMXPhysics = RMXPhysics(world: self)
    
    var activeSprite: RMSParticle? {
        return self.observer
    }
    
    var activeCamera: RMXCamera? {
        return observer.camera
    }
    

    
    init(parent: RMXObject! = nil, name: String = "The World", capacity: Int = 15000) {
        self.sprites = Array<RMSParticle>()
        self.sprites.reserveCapacity(capacity)
        
        super.init(world: nil, parent: parent, name: name)
        self.body.radius = 2000
        self.observer.addInitCall { () -> () in
            self.observer.body.position = GLKVector3Make(20, 20, 20)
        }
        
        self.camera = RMXCamera(world: self, pov: observer)
        
        self.sprites.append(self.observer)
        //fatalError("Grav: \(self.physics.gravity)")
         self.isAnimated = false
    }
    
  
    func insertSprite(sprite: RMSParticle){
        if sprite.body.distanceTo(self) <= self.body.radius {
            self.sprites.append(sprite)
        }
    }
            
    func µAt(someBody: RMSParticle) -> Float {
        if (someBody.body.position.y <= someBody.ground   ) {
            return 0.2// * RMXGetSpeed(someBody->body.velocity);//Rolling wheel resistance
        } else {
            return 0.01// * RMXGetSpeed(someBody->body.velocity); //air;
        }
    }
    func massDensityAt(someBody: RMSParticle) -> Float {
        if someBody.body.position.y < someBody.ground   {// 8 / 10 ) {// someBody.ground )
            return 99.1 //water or other
        } else {
            return 0.01 //air;
        }
    }
    func collisionTest(sender: RMSParticle) -> Bool{
    //Have I gone through a barrier?
        let velocity = sender.body.velocity
        let v = velocity.y
        let p = sender.body.position.y
        let next = sender.body.velocity + sender.body.position
        let bounceY: Float = -v
        let g = sender.ground
        if p <= g && v < 0 && sender.isInWorld {
            if p < g / sender.body.coushin {
                RMXVector3SetY(&sender.body.velocity, bounceY * sender.body.coushin)
                RMXVector3SetY(&sender.body.position, g)
            } else {
                RMXVector3SetY(&sender.body.velocity, sender.hasGravity ? 0 : bounceY * sender.body.coushin)
                RMXVector3SetY(&sender.body.position, g)
            }
            return true
        }
        if GLKVector3Length(next) >= self.body.radius && sender.type != .OBSERVER {
            sender.body.velocity = GLKVector3Negate(velocity)
        }
        
        return false
    }
    
    func gravityAt(sender: RMSParticle) -> RMXVector3 {
        return self.physics.gravityFor(sender)
    }
    
    
   
    override func animate() {
        super.animate()
        for sprite in sprites {
            if sprite !== self {
                sprite.animate()
            }
           
        }
        self.actionProcessor.animate()
        self.debug()
        
    }
    
    override func reset() {
        self.observer.reset()
        //super.reset()
    }
    
    func closestObjectTo(sender: RMSParticle)->RMSParticle? {
        var closest: RMSParticle = sprites[1]
        var dista: Float = sender.body.distanceTo(closest)
        for sprite in sprites {
            let distb: Float = sender.body.distanceTo(sprite)
            //NSString *lt = @" < ";
            if sprite.rmxID != sender.rmxID {
                if distb < dista {
                    closest = sprite
                    dista = distb
                }
            }
        }
        if dista < sender.actions!.reach + closest.body.radius + sender.body.radius {
            return closest
        }
        return nil
    }
    
  
    //private var _hasGravity = false
    override func toggleGravity() {
        for sprite in sprites {
            if (sprite !== self.observer) && !(sprite.isLightSource) {
                sprite.setHasGravity(self.hasGravity)
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
