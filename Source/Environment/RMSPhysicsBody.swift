//
//  RMSPhysicsBody.swift
//  RattleGL
//
//  Created by Max Bilbow on 10/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//


import GLKit


#if !SceneKit
    protocol SCNPhysicsBody {}
    #else
    import SceneKit
    #endif
class RMSPhysicsBody: SCNPhysicsBody, RMXNodeProperty {

    #if !SceneKit
    var velocity = RMXVector3Zero
    var mass: RMFloat = 0
    #else
    #endif
    var acceleration = RMXVector3Zero
    var forces = RMXVector3Zero

    var orientation: RMXMatrix4 {// = RMXMatrix4Identity //{
        return self.owner.orientationMat
    }
    
    var vMatrix: RMXMatrix4 = RMXMatrix4Zero

    #if SceneKit
    var accelerationRate:RMFloat = -1
    #else
    var accelerationRate:RMFloat = 1
    #endif
    var rotationSpeed:RMFloat = 1
    
    var hasFriction: Bool {
        return self.owner.hasFriction
    }
    var hasGravity: Bool{
        return self.owner.hasGravity
    }
    var coushin: RMFloat = 2
    
    var theta: RMFloat = 0
    var phi: RMFloat = 0
    private var _radius: RMFloat = 1
    var radius: RMFloat {
        return _radius
    }
    var dragC: RMFloat = 0.1
    
    var dragArea: RMFloat {
        return ( self.radius * self.radius * PI )
    }
    var owner: RMXNode!
    var world: RMSWorld {
        return self.owner.world
    }
    
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

    init(_ owner: RMXNode, mass: RMFloat = 1, radius: RMFloat = 1, dragC: RMFloat = 0.1,
        accRate: RMFloat = 1, rotSpeed:RMFloat = 1){
            self.owner = owner
            #if SceneKit
            super.init()
                #else
                self.initialize(owner, mass: mass, radius: radius, dragC: dragC, accRate: accRate, rotSpeed: rotSpeed)
            #endif
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialize(owner: RMXNode, mass: RMFloat = 1, radius: RMFloat = 1, dragC: RMFloat = 0.1,
        accRate: RMFloat = 1, rotSpeed:RMFloat = 1){
            self.mass = mass
            self.setRadius(radius)
            self.dragC = dragC
            self.accelerationRate = accRate
            self.rotationSpeed = rotSpeed
            self.owner = owner
            

    }
    
    func setRadius(radius: RMFloat){
        _radius = radius
        let s = radius * 2
        self.owner.scale = RMXVector3Make(s,s,s)
    }
    
    var weight: RMFloat{
        return self.mass * self.physics.worldGravity
    }
   
    func distanceTo(#point: RMXVector3) -> RMFloat{
        return RMXVector3Distance(self.position, point)
    }
    
    func distanceTo(object:RMXNode) -> RMFloat{
            return RMXVector3Distance(self.position,object.position)
    }
    
    func accelerateForward(v: RMFloat) {
        RMXVector3SetZ(&self.acceleration, v * self.accelerationRate)
    }
    
    func accelerateUp(v: RMFloat) {
        RMXVector3SetY(&self.acceleration, v * self.accelerationRate)
    }
    
    func accelerateLeft(v: RMFloat) {
        RMXVector3SetX(&self.acceleration, v * self.accelerationRate)
    }
    
    
    func forwardStop() {
        RMXVector3SetZ(&self.acceleration,0)
    }
    
    func upStop() {
        RMXVector3SetY(&self.acceleration,0)
    }
    
    func leftStop() {
        RMXVector3SetX(&self.acceleration,0)
    }
    
    func completeStop(){
        self.stop()
        self.velocity = RMXVector3Zero
    }
    ///Stops all acceleration foces, not velocity
    func stop(){
        self.forwardStop()
        self.leftStop()
        self.upStop()
    }
    
    private let _phiLimit = RMFloat(2)
    
    ///input as radians
    func addTheta(leftRightRadians theta: RMFloat){
        //let theta: Float = GLKMathDegreesToRadians(x)
        self.theta += theta
        self.owner.transform = RMXMatrix4Rotate(self.owner.transform, theta,0,1,0)
        
//        let mat = RMXMatrix4Rotate(RMXMatrix4Identity,theta,0,1,0)
//        self.owner.transform = mat * self.owner.transform


    }
    
//    private var _orientation: RMXMatrix4 = RMXMatrix4Identity
    func addPhi(upDownRadians phi: RMFloat) {
        self.phi += phi
        let axis = self.owner.leftVector
        
//        let mat = RMXMatrix4Rotate(RMXMatrix4Identity,phi,axis.x,axis.y,axis.z)
//        self.owner.transform = mat * self.owner.transform
//
        
        //RMXLog(axis.print)
        if !self.owner.isObserver {
       self.owner.transform = RMXMatrix4RotateWithVector3(self.owner.transform, phi, axis)
        }
    }
    
    func setTheta(leftRightRadians theta: RMFloat){
        self.addTheta(leftRightRadians: -self.theta)
        self.addTheta(leftRightRadians: theta)
    }
    
    func setPhi(upDownRadians phi: RMFloat){
        self.addPhi(upDownRadians: -self.phi)
        self.addPhi(upDownRadians: phi)
    }
    

    
    func addRoll(sideRollRadians roll: RMFloat){
        //TODO
    }
    
//    func setVelocity(v: [Float], speed: Float = 1){
////        let matrix = GLKMatrix4Transpose(self.orientation)
//        self.velocity += GLKMatrix4MultiplyVector3(self.orientation, GLKVector3Make(v[0] * speed,v[1] * speed,v[2] * speed))
//    }
    
    func animate()    {
        
        let g = self.hasGravity ? self.world.gravityAt(self.owner) : RMXVector3Zero
        let n = self.hasGravity ? self.physics.normalFor(self.owner) : RMXVector3Zero
        let f = self.physics.frictionFor(self.owner)// : GLKVector3Make(1,1,1);
        let d = self.physics.dragFor(self.owner)// : GLKVector3Make(1,1,1);
        
        let frictionAndDrag = RMXVector3Make(
            RMFloat(1 + f.x + d.x),
            RMFloat(1 + f.y + d.y),
            RMFloat(1 + f.z + d.z)
            )
        self.velocity = RMXVector3Divide(self.velocity, frictionAndDrag)
        
        let forces = RMXVector3Make(
            (g.x + /* d.x + f.x +*/ n.x),
            (g.y +/* d.y + f.y +*/ n.y),//+body.acceleration.y,
            (g.z +/* d.z + f.z +*/ n.z)
        )
        
        //    self.body.forces.x += g.x + n.x;
        //    self.body.forces.y += g.y + n.y;
        //    self.body.forces.z += g.z + n.z;
        
        self.forces = forces + RMXMatrix4MultiplyVector3(self.orientation, self.acceleration)
        self.velocity += self.forces
        
        self.world.collisionTest(self.owner)

        
     
        self.owner.transform = RMXMatrix4Translate(self.owner.transform,self.velocity)
        
//        if self.owner.isObserver { RMXLog("\n\n   LFT: \(self.leftVector.print), \(self.owner.leftVector.print) \n    UP: \(self.upVector.print), \(self.owner.upVector.print)\n   FWD: \(self.forwardVector.print), \(self.owner.forwardVector.print)\n   FRC: \(self.forces.print)\n") }
        
    }
    
    

   
    
}