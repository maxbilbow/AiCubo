//
//  RMSPhysicsBody.swift
//  RattleGL
//
//  Created by Max Bilbow on 10/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//


import GLKit


#if SceneKit
    import SceneKit

    #else


class RMSPhysicsBody {


    var velocity = RMXVector3Zero
    var mass: RMFloatB = 0
   
    var acceleration = RMXVector3Zero
//    var forces = RMXVector3Zero

    var orientation: RMXMatrix4 = RMXMatrix4Identity //{
//        return self.owner.orientationMat
//    }
    
    var vMatrix: RMXMatrix4 = RMXMatrix4Zero

       var accelerationRate:RMFloatB = 1

    
    var rotationSpeed:RMFloatB = 1

    var hasFriction: Bool {
        return self.owner.hasFriction
    }
    var hasGravity: Bool{
        return self.owner.hasGravity
    }
    var coushin: RMFloatB = 2
    
    var theta: RMFloatB = 0
    var phi: RMFloatB = 0
    
    var dragC: RMFloatB = 0.1
    
    var dragArea: RMFloatB {
        let x = self.node!.scale.x
        let y = self.node!.scale.y
        return x * y
    }
    var node: RMXNode? {
        return self.owner.node
    }
    
    var owner: RMXSprite! = nil
    
    var world: RMSWorld {
        return self.owner.world
    }
    
    var actions: RMXSprite {
        return self.owner
    }
    
    var physics: RMXPhysics {
        return self.world.physics
    }

    var position: RMXVector3 {
        return self.owner.position
    }
    
    init(_ owner: RMXSprite){
        
    
                self.initialize(owner)

    }


    private func initialize(owner: RMXSprite, mass: RMFloat = 1, radius: RMFloatB = 1, dragC: RMFloatB = 0.1,
        accRate: RMFloatB = 1, rotSpeed:RMFloatB = 1){
            self.node?.physicsBody!.mass = mass
            self.dragC = dragC
            self.accelerationRate = accRate
            self.rotationSpeed = rotSpeed
            self.owner = owner
    }
    
}
    
    #endif

extension RMXSprite {
    func accelerateForward(v: RMFloatB) {
        RMXVector3SetZ(&self.acceleration, v * self.accelerationRate)
    }
    
    func accelerateUp(v: RMFloatB) {
//        let force = self.upVector * v
//        self.node.physicsBody!.applyForce(force, impulse: true)
        RMXVector3SetY(&self.acceleration, v * self.accelerationRate)
    }
    
    func accelerateLeft(v: RMFloatB) {
//        let force = self.leftVector * v
//        self.node.physicsBody!.applyForce(force, impulse: true)
        RMXVector3SetX(&self.acceleration, v * self.accelerationRate)
    }
    
    
    func forwardStop() {
//        let force = RMXVector3Zero
//        self.node.physicsBody!.applyForce(force, impulse: true)
        RMXVector3SetZ(&self.acceleration,0)
    }
    
    func upStop() {
//        let force = RMXVector3Zero
//        self.node.physicsBody!.applyForce(force, impulse: true)
        RMXVector3SetY(&self.acceleration,0)
    }
    
    func leftStop() {
//        let force = RMXVector3Zero
//        self.node.physicsBody!.applyForce(force, impulse: true)
        RMXVector3SetX(&self.acceleration,0)
    }
    
    func completeStop(){
        self.stop()
        self.node.physicsBody!.velocity = RMXVector3Zero
    }
    ///Stops all acceleration foces, not velocity
    func stop(){
        self.forwardStop()
        self.leftStop()
        self.upStop()
    }
    
    func negateRoll(){
       
    }
    
    ///input as radians
    func addTheta(leftRightRadians theta: RMFloatB){
        if theta == 0 { return }
        self.theta += theta

        let orientation = RMXMatrix4MakeRotation(theta,RMXVector3Make(0,1,0))
//        self.orientation *= RMXMatrix4Transpose(orientation)
        #if SceneKit
//            self.node.eulerAngles.y += theta
            self.node.transform *= orientation

        #endif
    }
    
    
    func addPhi(upDownRadians phi: RMFloatB) {
        if phi == 0 { return }
        self.phi += phi
        let orientation = RMXMatrix4MakeRotation(phi, RMXVector3Make(1,0,0))

        #if SceneKit
//        self.orientation *= RMXMatrix4Transpose(orientation)
          self.node.transform *= orientation
        
        #endif
    }
    
    func addRoll(rollRadians roll: RMFloatB) {
        if roll == 0 { return }
        self.roll += roll
        let orientation = RMXMatrix4MakeRotation(roll, RMXVector3Make(0,0,1))
        
        //self.orientation = RMXMatrix4RotateWithVector3(self.orientation, phi, self.leftVector)
        #if SceneKit
//            self.orientation *= RMXMatrix4Transpose(orientation)
            self.node.transform *= orientation
            
        #endif
    }
    
    func setTheta(leftRightRadians theta: RMFloatB){
        self.addTheta(leftRightRadians: -self.theta)
        self.addTheta(leftRightRadians: theta)
    }
    
    func setPhi(upDownRadians phi: RMFloatB){
        self.addPhi(upDownRadians: -self.phi)
        self.addPhi(upDownRadians: phi)
    }
    
    func setRoll(rollRadians roll: RMFloatB){
        self.addRoll(rollRadians: -self.roll)
        self.addRoll(rollRadians: roll)
    }
    
    

}

extension RMXSprite {
    func setRadius(radius: RMFloatB){
        let s = radius * 2
        self.node.scale = RMXVector3Make(s,s,s)
    }
    
    var weight: RMFloatB {
        return RMFloatB(self.node.physicsBody!.mass) * self.world.gravityAt(self).y
    }
   
    func distanceTo(#point: RMXVector3) -> RMFloatB{
        return RMXVector3Distance(self.position, point)
    }
    
    func distanceTo(object:RMXSprite) -> RMFloatB{
            return RMXVector3Distance(self.position,object.position)
    }
    
    



    

   
    
}