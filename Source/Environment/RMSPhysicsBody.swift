//
//  RMSPhysicsBody.swift
//  RattleGL
//
//  Created by Max Bilbow on 10/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//


import GLKit
import SceneKit


extension RMXSprite {
    
    func lookAround(theta t: RMFloatB? = nil, phi p: RMFloatB? = nil, roll r: RMFloatB? = nil) {
        
        if let theta = t {
            let axis = self.upVector
            let speed = self.rotationSpeed * theta
            self.node.physicsBody!.applyTorque(SCNVector4Make(axis.x,axis.y,axis.z, -speed), impulse: false)
        }
        if let phi = p {
            let axis = self.leftVector
            let speed = self.rotationSpeed * phi
            self.node.physicsBody!.applyTorque(SCNVector4Make(axis.x,axis.y,axis.z, speed), impulse: false)
        }
        if let roll = r {
            let axis = self.forwardVector
            let speed = self.rotationSpeed * roll
            self.node.physicsBody!.applyTorque(SCNVector4Make(axis.x,axis.y,axis.z, -speed), impulse: false)
//            self.node.transform *= RMXMatrix4MakeRotation(speed * 0.0001, RMXVector3Make(0,0,1))
        }
        
    }
    var orientation: RMXVector4 {
        return self.node.presentationNode().orientation
    }
    
    func accelerateForward(v: RMFloatB) {
        let force = self.forwardVector * -v * self.speed
        RMXLog("\n Force:\(force.print)")
        self.node.physicsBody!.applyForce(force, impulse: false)
    }
    
    func accelerateUp(v: RMFloatB) {
        let force = self.upVector * -v * self.speed
        RMXLog(force.print)
        self.node.physicsBody!.applyForce(force, impulse: false)
    }
    
    func accelerateLeft(v: RMFloatB) {
        let force = self.leftVector * -v * self.speed
        RMXLog(force.print)
        self.node.physicsBody!.applyForce(force, impulse: false)
    }
    
    
    func completeStop(){
        self.stop()
        self.node.physicsBody!.velocity = RMXVector3Zero
    }
    ///Stops all acceleration foces, not velocity
    func stop(){
        self.node.physicsBody!.clearAllForces()
    }
    
    func negateRoll(){
        
    }
    

}

extension RMXSprite {
    func setRadius(radius: RMFloatB){
        let s = radius * 2
        self.node.scale = RMXVector3Make(s,s,s)
    }
    
    var weight: RMFloatB {
        return RMFloatB(self.node.physicsBody!.mass)// * self.world.gravity
    }
   
    func distanceTo(point: RMXVector3 = RMXVector3Zero) -> RMFloatB{
        return RMXVector3Distance(self.position, point)
    }
    
    func distanceTo(object:RMXSprite) -> RMFloatB{
            return RMXVector3Distance(self.position,object.position)
    }
    
    


    var velocity: RMXVector3 {
        return self.node.physicsBody!.velocity ?? RMXVector3Zero
    }

    

   
    
}