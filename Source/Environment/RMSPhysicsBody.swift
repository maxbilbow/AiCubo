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
    var mass: RMFloatB = 0
    #else
    #endif
    var acceleration = RMXVector3Zero
    var forces = RMXVector3Zero

    var orientation: RMXMatrix4 = RMXMatrix4Identity //{
//        return self.owner.orientationMat
//    }
    
    var vMatrix: RMXMatrix4 = RMXMatrix4Zero

    #if SceneKit
    var accelerationRate:RMFloatB = -1
    #else
    var accelerationRate:RMFloatB = 1
    #endif
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
    private var _radius: RMFloatB = 1
    var radius: RMFloatB {
        return _radius
    }
    var dragC: RMFloatB = 0.1
    
    var dragArea: RMFloatB {
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

    init(_ owner: RMXNode, mass: RMFloatB = 1, radius: RMFloatB = 1, dragC: RMFloatB = 0.1,
        accRate: RMFloatB = 1, rotSpeed:RMFloatB = 1){
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
    
    private func initialize(owner: RMXNode, mass: RMFloat = 1, radius: RMFloatB = 1, dragC: RMFloatB = 0.1,
        accRate: RMFloatB = 1, rotSpeed:RMFloatB = 1){
            self.mass = mass
            self.setRadius(radius)
            self.dragC = dragC
            self.accelerationRate = accRate
            self.rotationSpeed = rotSpeed
            self.owner = owner
            

    }
    
    func setRadius(radius: RMFloatB){
        _radius = radius
        let s = radius * 2
        self.owner.scale = RMXVector3Make(s,s,s)
    }
    
    var weight: RMFloatB{
        return RMFloatB(self.mass) * self.physics.worldGravity
    }
   
    func distanceTo(#point: RMXVector3) -> RMFloatB{
        return RMXVector3Distance(self.position, point)
    }
    
    func distanceTo(object:RMXNode) -> RMFloatB{
            return RMXVector3Distance(self.position,object.position)
    }
    
    func accelerateForward(v: RMFloatB) {
        RMXVector3SetZ(&self.acceleration, v * self.accelerationRate)
    }
    
    func accelerateUp(v: RMFloatB) {
        RMXVector3SetY(&self.acceleration, v * self.accelerationRate)
    }
    
    func accelerateLeft(v: RMFloatB) {
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
    
    ///input as radians
    func addTheta(leftRightRadians theta: RMFloatB){
        self.theta += theta
//
        self.orientation = RMXMatrix4RotateY(self.orientation,theta)//*= orientation//m * self.orientation
        let orientation = RMXMatrix4MakeRotation(theta,RMXVector3Make(0,1,0))
        //self.orientation *= RMXMatrix4Transpose(orientation)
        #if SceneKit
            
            self.owner.transform *= RMXMatrix4Transpose(orientation)
            //self.owner.transform = RMXSetOrientation(self.owner.transform,orientation: self.orientation)
        #endif
    }
    

    func addPhi(upDownRadians phi: RMFloatB) {
        self.phi += phi
        let orientation = RMXMatrix4MakeRotation(phi, RMXVector3Make(1,0,0))
        
        self.orientation = RMXMatrix4RotateWithVector3(self.orientation, phi, self.owner.leftVector)
        #if SceneKit
            
            self.owner.transform *= RMXMatrix4Transpose(orientation)// * self.orientation
//            self.owner.eulerAngles.x -= phi
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
    

    
    func addRoll(sideRollRadians roll: RMFloatB){
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
            RMFloatB(1 + f.x + d.x),
            RMFloatB(1 + f.y + d.y),
            RMFloatB(1 + f.z + d.z)
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

        #if SceneKit
            //self.owner.transform *= self.yOrientation
//            self.owner.transform = RMXMatrix4SetPosition(self.orientation,v3:position)
            self.owner.transform = RMXMatrix4Translate(self.owner.transform,self.velocity)
            #else
        self.owner.position += self.velocity
        #endif
        
        
        
        
        
    }
    
    

   
    
}