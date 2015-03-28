//
//  RMXSprite.swift
//  RattleGL
//
//  Created by Max Bilbow on 13/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import GLKit



enum RMXParticleType { case OBSERVER, SHAPE, SIMPLE_PARTICLE, WORLD }
class RMSParticle : RMXObject {
 
    #if OPENGL_OSX
    lazy var mouse: RMXMouse = RMSMouse(parent: self)
    #endif
    var actions: RMXSpriteActions?
    var type: RMXParticleType = .SIMPLE_PARTICLE
    
    var camera: RMXCamera?
    
    var isDrawable: Bool {
        return self.shape.isVisible
    }
    var geometry: ShapeType {
        return self.shape.type
    }
    
    lazy var shape: RMXShape = RMXShape(parent: self, world: self.world)
    var anchor = RMXVector3Zero
    
    //Set automated rotation (used mainly for the sun)
    ///@todo create a behavior protocal/class instead of fun pointers.
    var rAxis = RMXVector3Zero
    var rotation:Float = 0
    var rotationCenterDistance:Float = 0
    var isRotating = false
    //static var COUNT: Int = 0
    
    init(world:RMSWorld?,  parent:RMXObject! = nil, name: String = "RMSParticle")
    {
        super.init(parent:parent, world:world, name: name)
        self.actions = RMXSpriteActions(parent: self)
        self.body = RMSPhysicsBody(parent: self)
        //RMSParticle.COUNT++
        self.actions!.parent = self
        //self.mouse = RMXMouse(parent:self, world:self.world)
        
        self.camera = RMXCamera(world: world, pov: self)
        //Set up for basic particle
        self.resets.append({
            self.body = RMSPhysicsBody(parent: self)
            self.shape = RMXShape(parent: self, world:self.world)
            self.actions = RMXSpriteActions(parent: self)
            self.anchor = GLKVector3Make(0,0,0)
            self.isAnimated = true
            self.rAxis = GLKVector3Make(0,0,1)
            self.rotation = 0
            self.isRotating = false
            self.rotationCenterDistance = 0
            func restIf() -> Bool {
                return GLKVector3Length(self.body.velocity) < 0.01
            }
            self.prepareToRest = restIf
        })
        
        self.resets.last?()
    }
    
    private var _asObserver = false
    private var _asShape = false
    
    func setAsShape(shape render: ((Float)->Void)?) -> RMSParticle? {//, mass: Float? = nil, isAnimated: Bool? = true, hasGravity: Bool? = false) -> RMSParticle {
        if _asShape { return self }
        if render != nil { self.shape.setRenderer(render!) }
        self.resets.append({
            //if body != nil { self.body = body! }
            self.shape.isVisible = true
        })
        _asShape = true
        self.resets.last?()
        return self
    }
    
    func setAsObserver() -> RMSParticle {
        if _asObserver { return self }
        self.resets.append({
            self.actions!.armLength = self.body.radius * 2
            self.actions!.setReach(2 * self.actions!.armLength);
            self.body.mass = 9
            self.body.radius = 20
            self.body.position = GLKVector3Make(0,self.body.radius,-20)
            self.setHasGravity(true)
            self.isAlwaysActive = true
        })
        _asObserver = true
        self.resets.last?()
        return self
    }
    
    class func New(world: RMSWorld! = nil, parent: RMXObject! = nil) -> RMSParticle {
        return RMSParticle(world: world, parent: parent)
        
    }
    
    func addBehaviour(behaviour: () -> ()) {
        self.behaviours.append(behaviour)
        //self.behaviours.last?()
    }
   
    
    var viewPoint: RMXVector3{
        return GLKVector3Add(self.body.forwardVector,self.position)
    }
    
    var ground: Float {
        return self.body.radius - ( self.actions?.squatLevel ?? 0 )
    }
    
    func animate() {
        if self.isAnimated && self.shouldAnimate {
            self.actions?.jumpTest()
            self.body.animate()
            self.actions?.manipulate()
            for behaviour in self.behaviours {
                behaviour()
            }
        }
    
    ///add this as a behaviour (create the variables outside of function before adding)
        if self.isRotating {
            self.rotation += self.body.rotationSpeed/self.rotationCenterDistance
            var temp = RMX.circle(count: Float(self.rotation), radius: Float(self.rotationCenterDistance) * 2)
            self.body.position = GLKVector3Make(temp.x - self.rotationCenterDistance,temp.y,0)
        }

    }
    
    
    func stop() {
        self.body.velocity = RMXVector3Zero
    }
    
    func plusAngle(point: [Float], speed: Float){
        RMXLog(point[0])
        self.plusAngle(point[0] * -speed, y: point[1] * speed)
    }
    
    
    
    var isGrounded: Bool {
        return self.body.position.y <= self.body.radius
    }
    
    
    
    var upThrust: Float {
        return self.body.velocity.y
    }
    
    var downForce: Float {
        return self.body.forces.y
    }
    
        
    func toggleGravity() {
        self.body.hasGravity = !self.body.hasGravity
    }
    
    func toggleFriction() {
        self.body.hasFriction = !self.body.hasFriction
    }
    

    
    func describePosition() -> String? {
/*    RMXVector3 drag = [self.physics dragFor:self];
    return [NSString stringWithFormat:@"\n   Pos: %f, %f, %f (%p)\n   Vel: %f, %f, %f (%p)\n   Acc: %f, %f, %f (%p)\n   µ: %f, %f, %f\n   g: %f, %f, %f\n  dF: %f, %f, %f\n  hasG: %i, hasF: %i, µ: %f", self.body.position.x,self.body.position.y,self.body.position.z,self.body,
    self.body.velocity.x,self.body.velocity.y,self.body.velocity.z,self.body
    ,self.body.acceleration.x,self.body.acceleration.y,self.body.acceleration.z,self.body,
    [self.physics frictionFor:self].x,[self.physics frictionFor:self].y,[self.physics frictionFor:self].z,
    [self.physics gravityFor:self].x,[self.physics gravityFor:self].y,[self.physics gravityFor:self].z,
    drag.x,drag.y,drag.z
    ,self.hasGravity,self.hasFriction, self.absFriction];
    
    //[rmxDebugger add:RMX_PARTICLE n:self t:[NSString stringWithFormat:@"%@",self.name]];
    //[rmxDebugger add:RMX_PARTICLE n:self.name t:[NSString stringWithFormat:@"%@ POSITION: %p | PX: %f, PY: %f, PZ: %f",self.name,[self pMem],[self position].x,[self position].y,[self position].z ]]; */
        return nil
    }
    
    
    var isLightSource: Bool {
        return self.shape.isLight
    }
    


}

extension RMSParticle {
    var hasGravity: Bool {
        return self.body.hasGravity
    }
    
    func setHasGravity(isTrue: Bool){
        self.body.hasGravity = isTrue
    }
    
    var hasFriction: Bool {
        return self.body.hasFriction
    }
    
    func setHasFriction(isTrue: Bool){
        self.body.hasFriction = isTrue
    }
    
    func setRotationSpeed(speed s: Float){
        self.body.rotationSpeed = s
    }
    
    var hasItem: Bool {
        return self.actions?.item != nil
    }
}