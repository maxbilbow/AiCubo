//
//  RMSPhysicsBody.swift
//  RattleGL
//
//  Created by Max Bilbow on 10/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//


import GLKit

class RMSPhysicsBody {
    
    private let PI: Float = 3.14159265358979323846
    var position, velocity, acceleration, forces: GLKVector3
    var orientation: GLKMatrix3//, groundOrientation: GLKMatrix3
    private var _orientation: GLKMatrix3 {
        return self.orientation// false ? self.groundOrientation : self.orientation
    }
    var vMatrix: GLKMatrix4
    var parent: RMSParticle
    var accelerationRate:Float = 0
    var rotationSpeed:Float
    var hasFriction = true
    var hasGravity = false
    var coushin: Float = 2
    
    var world: RMSWorld {
        return self.parent.world!
    }
    var physics: RMXPhysics {
        return self.world.physics
    }
    var theta, phi, radius, mass, dragC: Float
    var dragArea: Float {
        return ( self.radius * self.radius * self.PI )
    }
    
    init(parent: RMSParticle, mass: Float = 1, radius: Float = 1, dragC: Float = 0.1,
        accRate: Float = 1, rotSpeed:Float = 1){
        self.theta = 0
        self.phi = 0
        self.mass = mass
        self.radius = radius
        self.dragC = dragC
        self.position = GLKVector3Make(0,0,0)
        self.velocity = GLKVector3Make(0,0,0)
        self.acceleration = GLKVector3Make(0,0,0)
        self.forces = GLKVector3Make(0,0,0)
        self.orientation = GLKMatrix3Identity
//        self.groundOrientation = GLKMatrix3Identity
        self.vMatrix = GLKMatrix4MakeScale(0,0,0)
        self.accelerationRate = accRate
        self.rotationSpeed = rotSpeed
        self.parent = parent
    }
    
    class func New(parent: RMSParticle) -> RMSPhysicsBody{
        return RMSPhysicsBody(parent: parent)
    }
    class func New(parent: RMSParticle, mass: Float = 1, radius: Float = 1, dragC: Float = 0.1) -> RMSPhysicsBody {
        return RMSPhysicsBody(parent: parent, mass: mass, radius: radius, dragC: dragC)
    }
    
    var weight: Float{
        return self.mass * self.physics.worldGravity
    }
    
    var upVector: GLKVector3 {
        return GLKMatrix3GetRow(self._orientation, 1)
    }
    
    var leftVector: GLKVector3 {
        return GLKMatrix3GetRow(self.orientation, 0)
    }
    
    var forwardVector: GLKVector3 {
        return GLKMatrix3GetRow(self._orientation, 2)
    }
    
    func distanceTo(object:RMXObject) -> Float{
        return GLKVector3Distance(self.position,object.position)
    }
    
    func accelerateForward(v: Float) {
        RMXVector3SetZ(&self.acceleration, v * self.accelerationRate)
    }
    
    func accelerateUp(v: Float) {
        RMXVector3SetY(&self.acceleration, v * self.accelerationRate)
    }
    
    func accelerateLeft(v: Float) {
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
    
    func stop(){
        self.forwardStop()
        self.leftStop()
        self.upStop()
    }
    
    private let _phiLimit = Float(2)
    
    ///input as radians
    func addTheta(leftRightRadians theta: Float){
        //let theta: Float = GLKMathDegreesToRadians(x)
        self.theta += theta
        self.orientation = GLKMatrix3Rotate(self.orientation, theta, 0, 1, 0);
    }
    
    
    func addPhi(upDownRadians phi: Float) {
        self.phi += phi
        self.orientation = GLKMatrix3RotateWithVector3(self.orientation, phi, self.leftVector)
    }
    
    func setTheta(var leftRightRadians theta: Float){
        theta -= self.theta
        self.addTheta(leftRightRadians: theta)
    }
    
    func setPhi(var upDownRadians phi: Float){
        phi -= self.phi
        self.addPhi(upDownRadians: phi)
    }
    

    
    func addRoll(sideRollRadians roll: Float){
        //TODO
    }
    
    @availability(*, deprecated=1.0, obsoleted=2.0, message="Because now calculated seperately!")
    func addAngle(x:Float, y:Float, z: Float = 0) {
        //body.position.z += theta; return;
        
        let theta: Float = GLKMathDegreesToRadians(x)
        var phi: Float = GLKMathDegreesToRadians(y)
        var roll: Float = GLKMathDegreesToRadians(z)
        
        
        self.phi += phi //= newPhi
        self.theta += theta
        
//        self.groundOrientation = GLKMatrix3Rotate(self.orientation, theta, 0, 1, 0);
        self.orientation = GLKMatrix3Rotate(self.orientation, theta, 0, 1, 0);
        self.orientation = GLKMatrix3RotateWithVector3(self.orientation, phi, self.leftVector)
        RMXLog("\n   Left: \(self.leftVector.print)\n     Up: \(self.upVector.print)\n    FWD: \(self.forwardVector.print)")
        
    }
    
    func setVelocity(v: [Float], speed: Float = 1){
        let matrix = GLKMatrix3Transpose(self._orientation)
        self.velocity += GLKMatrix3MultiplyVector3(matrix, GLKVector3Make(v[0] * speed,v[1] * speed,v[2] * speed))
    }
    func animate()    {

        let g = self.hasGravity ? self.world.gravityAt(self.parent) : RMXVector3Zero
        let n = self.hasGravity ? self.physics.normalFor(self.parent) : RMXVector3Zero
        let f = self.physics.frictionFor(self.parent)// : GLKVector3Make(1,1,1);
        let d = self.physics.dragFor(self.parent)// : GLKVector3Make(1,1,1);
        
        self.velocity = GLKVector3DivideScalar(self.velocity, Float(1 + self.world.µAt(self.parent) + d.x))
        
        let forces = GLKVector3Make(
            (g.x + /* d.x + f.x +*/ n.x),
            (g.y +/* d.y + f.y +*/ n.y),//+body.acceleration.y,
            (g.z +/* d.z + f.z +*/ n.z)
        )
        
        //    self.body.forces.x += g.x + n.x;
        //    self.body.forces.y += g.y + n.y;
        //    self.body.forces.z += g.z + n.z;
        
        self.forces = GLKVector3Add(forces,GLKMatrix3MultiplyVector3(GLKMatrix3Transpose(self._orientation),self.acceleration));
        self.velocity = GLKVector3Add(self.velocity,self.forces);//transpos or?
        
        self.world.collisionTest(self.parent)

        
        //self.applyLimits()
        self.position = GLKVector3Add(self.position,self.velocity);
        
        
    }
    


   
    
}