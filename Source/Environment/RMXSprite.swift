//
//  RMXInteraction.swift
//  RattleGL
//
//  Created by Max Bilbow on 17/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
#if SceneKit
import SceneKit
    #else
import GLKit
    #endif
enum JumpState { case PREPARING_TO_JUMP, JUMPING, GOING_UP, COMING_DOWN, NOT_JUMPING }

class RMXSprite : RMXChildNode {
    
    #if OSX
    lazy var mouse: RMXMouse = RMSMouse(owner: self)
    #endif
    
    var radius: RMFloatB {
        return (self.node.scale.x + self.node.scale.y + self.node.scale.z) / (3 * 2)
    }
    static var COUNT: Int = 0
    var rmxID: Int = RMXSprite.COUNT
    var isUnique: Bool = false
    var hasFriction = true
    var hasGravity = false
    private var _rotation: RMFloatB = 0
    var isVisible: Bool = true
    var isLight: Bool = false
    var shapeType: ShapeType = .NULL
    
    lazy var world: RMSWorld! = self as? RMSWorld ?? nil
    
    var type: RMXSpriteType = .DEFAULT
    var wasJustThrown:Bool = false
    var anchor = RMXVector3Zero
    
    var parentSprite: RMXSprite?
    
//    lazy var body: RMSPhysicsBody? = RMSPhysicsBody(self)
    
    var parentNode: SCNNode? {
        return self.node.parentNode
    }
    
    var paretn: RMXSprite?
    
    var node: RMXNode = RMXNode()
    
    var name: String {
        return "\(_name): \(self.rmxID)"
    }
    
    var centerOfView: RMXVector3 {
        return self.position + self.forwardVector// * self.actions.reach
    }
    
    var isAnimated: Bool = true
    private var _name: String = ""
    
    func setName(name: String) {
        self._name = name
    }
    var altitude: RMFloatB {
        return self.position.y
    }
    private var armLength: RMFloatB = 0
    var reach: RMFloatB {
        return self.node.scale.z + self.armLength
    }
    
    
    private var _jumpState: JumpState = .NOT_JUMPING
    private var _maxSquat: RMFloatB = 0
    
    var startingPoint: RMXVector3?
    
    lazy var resets: [() -> () ] = [{
        self.node.physicsBody!.velocity = RMXVector3Zero
        #if SceneKit
            self.node.transform = RMXMatrix4Identity
            #else
            self.node.position = self.startingPoint ?? RMXVector3Zero
        #endif
    }]
    
    var behaviours: [(Bool) -> ()] = Array<(Bool) -> ()>()
    lazy var environments: ChildSpriteArray = ChildSpriteArray(parent: self)
    //    var children: UnsafeMutablePointer<[Int : RMXNode]> {
    //        return environments.current
    //    }
    
    var children: [RMXSprite] {
        return environments.current
    }
    
    var childSpriteArray: ChildSpriteArray{
        return self.environments
    }
    var hasChildren: Bool {
        return self.children.isEmpty
    }
    var isAlwaysActive = true
    var isActive = true
    var variables: [ String: Variable] = [ "isBouncing" : Variable(i: 1) ]
    
    
    
    var isObserver: Bool {
        return self == self.world.observer
    }
    
    var isActiveSprite: Bool {
        return self == self.world.activeSprite
    }
    
    
    
    private var _isDrawable: Bool?
    var isDrawable: Bool {
        if _isDrawable != nil {
            return _isDrawable!
        } else {
            _isDrawable = self.isVisible && self.shapeType != .NULL
        }
        return _isDrawable!
    }
    

    ///Set automated rotation (used mainly for the sun)
    ///@todo create a behavior protocal/class instead of fun pointers.
    var rAxis = RMXVector3Make(0,0,1)
    
    var rotationCenterDistance:RMFloatB = 0
    var isRotating = false
    
    var isInWorld: Bool {
        return self.distanceTo(self.world) < self.world.radius
    }
    
    
    class func Unique(parentSprite:RMXSprite?, type: RMXSpriteType = .DEFAULT) -> RMXSprite {
        let result = RMXSprite.new(parent: parentSprite!)
        result.type = type
        result.isUnique = true
        return result
    }

    
    var jumpStrength: RMFloatB = 10
    var squatLevel:RMFloatB = 0
    private var _prepairingToJump: Bool = false
    private var _goingUp:Bool = false
    private var _ignoreNextJump:Bool = false
    private var _itemWasAnimated:Bool = false
    private var _itemHadGravity:Bool = false
    

    var item: RMXSprite?
    var itemPosition: RMXVector3 = RMXVector3Zero
    

    init(node: RMXNode = RMXNode()){
        self.node = node
        
        self.spriteDidInitialize()
    }
    
    
    func reset(){
        for re in resets {
            re()
        }
        for child in children {
            child.reset()
        }
    }
    
    var usesBehaviour = true

    var hasItem: Bool {
        return self.item != nil
    }
    
    class func new(#parent: RMXSprite) -> RMXSprite {
        let sprite = RMXSprite()
        sprite.parentSprite = parent
        sprite.world = parent.world
        parent.insertChild(sprite)
        return sprite
    }
    
    func spriteDidInitialize(){
        RMXSprite.COUNT++
        #if SceneKit
            self.node.physicsBody = SCNPhysicsBody.staticBody()
        #endif
        if self.parentSprite != nil {
            self.world = self.parentSprite!.world
        }
        self.node.name = self.name
    }
    
    func toggleGravity() {
        self.hasGravity = !self.hasGravity
    }
    
    var theta: RMFloatB = 0
    var phi: RMFloatB = 0
    var roll: RMFloatB = 0
    var orientation = RMXMatrix4Identity
    var rotationSpeed: RMFloatB = 1
    #if SceneKit
    var accelerationRate:RMFloatB = -1
    #else
    var accelerationRate:RMFloatB = 1
    #endif
    var acceleration: RMXVector3 = RMXVector3Zero
    private let _zNorm = 90 * PI_OVER_180
}

extension RMXSprite {

    func initPosition(startingPoint point: RMXVector3){
        self.startingPoint = point
        self.node.position = point
    }
    
    func setShape(type: ShapeType = .CUBE) -> RMXSprite {//, mass: RMFloatB? = nil, isAnimated: Bool? = true, hasGravity: Bool? = false) -> RMXSprite {
        self.shapeType = type
        #if SceneKit
            switch(type) {
            case .CUBE:
                self.node.geometry = RMXArt.CUBE
                break
            case .SPHERE:
                self.node.geometry = RMXArt.SPHERE
                break
            case .CYLINDER:
                self.node.geometry = RMXArt.CYLINDER
                break
            case .PLANE:
                self.node.geometry = RMXArt.PLANE
                break
            case .FLOOR:
                self.node.geometry = RMXShape.FLOOR
                break
            default:
                self.node.geometry = RMXArt.CYLINDER
            }
            self.node.geometry! = (self.node.geometry!.copy() as? SCNGeometry)!
            self.node.geometry!.firstMaterial = (self.node.geometry!.firstMaterial!.copy() as? SCNMaterial)!
            #endif
        return self
    }

    
    func asObserver() -> RMXSprite {
        if self.type != .OBSERVER {
            self.type = .OBSERVER
            #if SceneKit
            self.node.physicsBody = SCNPhysicsBody.kinematicBody()
            #endif
            if self.startingPoint == nil {
                self.startingPoint = RMXVector3Make(0,self.radius,-20)
            }
            self.resets.append({
                self.armLength = self.radius * RMFloatB(2)
                
                self.node.physicsBody!.mass = 9
                
                self.setRadius(20)
                
                
                self.hasGravity = true
                self.isAlwaysActive = true
            })
            self.resets.last?()
        }
        return self
    }
    
    func resetDrawable(){
        self._isDrawable = nil
    }
    
   
}


extension RMXSprite {
    
    func insertChild(child: RMXSprite){
        child.parentSprite = self
        child.world = self.world
        #if SceneKit
//            child.node.removeFromParentNode()
            self.node.addChildNode(child.node)
        #endif
        self.childSpriteArray.set(child)
    }
    
    
    func insertChildren(#children: [Int:RMXSprite]){
        for child in children {
            self.insertChild(child.1)
        }
    }
    
    
    func expellChild(id rmxID: Int){
        if let child = self.childSpriteArray.get(rmxID) {
            if child.parentSprite! == self {
                //child.parent! = self.world
                self.childSpriteArray.remove(rmxID)
            }
        }
        
    }
    
    func expellChild(child: RMXSprite){
        if child.parentSprite! == self {
            child.parentSprite!.world = self.world
            self.childSpriteArray.remove(child.rmxID)
        }
    }
    
    func removeBehaviours(){
        self.behaviours.removeAll()
    }
    
    func setBehaviours(areOn: Bool){
        self.usesBehaviour = areOn
        for child in children{
            child.usesBehaviour = areOn
        }
    }
    
    func negateRoll(){
        if self.hasGravity {
            let roll = RMXGetTheta(vectorA: self.upVector, vectorB: RMXVector3Make(1,0,0))
            self.setRoll(rollRadians: -roll)
            self.addRoll(rollRadians: _zNorm)
        }
    }
    private func animate_position()    {
        self.negateRoll()//only runs if hasGravity == true
        let g = self.hasGravity ? self.world.gravityAt(self) : RMXVector3Zero
        let n = self.hasGravity ? self.world.physics.normalFor(self) : RMXVector3Zero
        let f = self.world.physics.frictionFor(self)// : GLKVector3Make(1,1,1);
        let d = self.world.physics.dragFor(self)// : GLKVector3Make(1,1,1);
        
        let frictionAndDrag = RMXVector3Make(
            RMFloatB(1 + f.x + d.x),
            RMFloatB(1 + f.y + d.y),
            RMFloatB(1 + f.z + d.z)
        )
        let oldVelocity = self.node.physicsBody!.velocity
        self.node.physicsBody!.velocity = RMXVector3Divide(oldVelocity, frictionAndDrag)
        
        let forces = RMXVector3Make(
            (g.x + /* d.x + f.x +*/ n.x),
            (g.y +/* d.y + f.y +*/ n.y),//+body.acceleration.y,
            (g.z +/* d.z + f.z +*/ n.z)
        )
        

        let totalForce = forces + RMXMatrix4MultiplyVector3(self.orientation, self.acceleration)
        
        
        self.world.collisionTest(self)
        
        #if SceneKit
            if false {//self.isObserver { //let body = self.owner.physicsBody {
                self.node.physicsBody!.applyForce(forces, impulse: true)
            } else {
                self.node.physicsBody!.velocity += totalForce
                self.node.transform = RMXMatrix4Translate(self.node.transform, self.node.physicsBody!.velocity)
            }
            #else
            self.node.position += self.velocity
        #endif
        
        
        
        
        
    }
    
    
    func animate() {
        for behaviour in self.behaviours {
            behaviour(self.usesBehaviour)
        }
        for child in children {
            child.animate()
        }
        if self.isAnimated {
            self.jumpTest()
            self.animate_position()
            self.manipulate()
        }
        
        ///add this as a behaviour (create the variables outside of function before adding)
        if self.isRotating {
            self._rotation += self.rotationSpeed / self.rotationCenterDistance
            var temp = RMX.circle(count: self._rotation, radius: self.rotationCenterDistance * 2, limit:  self.rotationCenterDistance)
            #if SceneKit
                self.node.position = RMXVector3Make(temp.x - self.rotationCenterDistance,temp.y,0)
                #else
                //self.transform = RMXMatrix4Translate(self.transform, RMXVector3Make(temp.x - self.rotationCenterDistance,temp.y,0))
                self.position = RMXVector3Make(temp.x - self.rotationCenterDistance,temp.y,0)
            #endif
        }
        #if SceneKit
            let transform = self.node.transform
            if self.isObserver { RMXLog("\nORIENTATION\n\(self.orientationMat.print)\n\nTRANSFORM:\n\(transform.print),\n   POV: \(self.viewPoint.print)") }
            #else
            let transform = self.position
            if self.isObserver { RMXLog("\n\(self.orientationMat.print)\n   POS: \(transform.print),\n   POV: \(self.viewPoint.print)") }
        #endif
        
        if self.isObserver { RMXLog("\n\n   LFT: \(self.leftVector.print),\n    UP: \(self.upVector.print)\n   FWD: \(self.forwardVector.print)\n\n") }
        
    }
    
    
    func toggleFriction() {
        self.hasFriction = !self.hasFriction
    }
}
extension RMXSprite {
    
    func throwItem(strength: RMFloatB) -> Bool
    {
        if self.item != nil {
            self.item!.isAnimated = true
            self.item!.hasGravity = _itemHadGravity
            let fwd4 = self.forwardVector
            let fwd3 = RMXVector3Make(fwd4.x, fwd4.y, fwd4.z)
            self.item!.node.physicsBody!.velocity = self.node.physicsBody!.velocity + RMXVector3MultiplyScalar(fwd3,strength)
            self.item!.wasJustThrown = true
            self.setItem(item: nil)
            return true
        } else {
            return false
        }
    }
    
    func manipulate() {
        if self.item != nil {
            let fwd = self.forwardVector
            self.item!.node.position = self.viewPoint + RMXVector3MultiplyScalar(fwd, self.reach + self.item!.reach)
            
            
        }
    }
    
    private func setItem(item itemIn: RMXSprite?){
        if let item = itemIn {
            self.item = item
//            self.insertChild(item)
//            self.item!.node.position = RMXVector3Zero
//            self.item!.node.position.z = self.reach + self.item!.reach
            _itemWasAnimated = item.isAnimated
            _itemHadGravity = item.hasGravity
            item.hasGravity = false
            item.isAnimated = true
            self.armLength = self.reach
        } else if let item = self.item {
            item.isAnimated = true
            item.hasGravity = _itemHadGravity
//            self.world.insertChild(item)
            
            self.item = nil
        }
    }
    
    func isWithinReachOf(item: RMXSprite) -> Bool{
        return self.distanceTo(item) <= self.reach + item.radius
    }
    
    func grabItem(item itemIn: RMXSprite? = nil) -> Bool {
        if self.hasItem { return false }
        if let item = itemIn {
            if self.isWithinReachOf(item) {
                self.setItem(item: item)
                return true
            }
        } else if let item = self.world.closestObjectTo(self) {
            if self.item == nil && self.isWithinReachOf(item) {
                self.setItem(item: item)
                return true
            }
        }
        return false
    }
    
    func releaseItem() {
        if item != nil { RMXLog("DROPPED: \(item!.name)") }
        if self.item != nil {
            self.item!.isAnimated = true //_itemWasAnimated
            self.item!.hasGravity = _itemHadGravity
//            #if SceneKit
//            self.item!.node.removeFromParentNode()
//                #endif
//            self.world.insertChild(self.item!)
            self.setItem(item: nil)
        }
    }
    
    func extendArmLength(i: RMFloatB)    {
        if self.armLength + i > 1 {
            self.armLength += i
        }
    }
    
    
    enum JumpState { case PREPARING_TO_JUMP, JUMPING, GOING_UP, COMING_DOWN, NOT_JUMPING }
    
    var height: RMFloatB {
        return self.node.scale.y
    }
    
    func jumpTest() -> JumpState {
        
        switch (_jumpState) {
        case .NOT_JUMPING:
            return _jumpState
        case .PREPARING_TO_JUMP:
            if self.squatLevel > _maxSquat{
                _jumpState = .JUMPING
            } else {
                let increment: RMFloatB = _maxSquat / 50
                self.squatLevel += increment
            }
            break
        case .JUMPING:
            if self.altitude > self.height || _jumpStrength < self.weight {//|| self.body.velocity.y <= 0 {
                _jumpState = .GOING_UP
                self.squatLevel = 0
            } else {
                RMXVector3PlusY(&self.node.physicsBody!.velocity, _jumpStrength)
            }
            break
        case .GOING_UP:
            if self.node.physicsBody!.velocity.y <= 0 {
                _jumpState = .COMING_DOWN
            } else {
                //Anything to do?
            }
            break
        case .COMING_DOWN:
            if self.altitude <= self.radius {
                _jumpState = .NOT_JUMPING
            }
            break
        default:
            fatalError("Shouldn't get here")
        }
        return _jumpState
    }
    
    func prepareToJump() -> Bool{
        if _jumpState == .NOT_JUMPING && self.isGrounded {
            _jumpState = .PREPARING_TO_JUMP
            _maxSquat = self.radius / 4
            return true
        } else {
            return false
        }
    }
    
    private var _jumpStrength: RMFloatB {
        return fabs(self.weight * self.jumpStrength * self.squatLevel/_maxSquat)
    }
    func jump() {
        if _jumpState == .PREPARING_TO_JUMP {
            _jumpState = .JUMPING
        }
    }

    func setReach(reach: RMFloatB) {
        self.armLength = reach
    }
    
    private class func stop(sender: RMXSprite, objects: [AnyObject]?) -> AnyObject? {
        sender.completeStop()
        return nil
    }
    
    func headTo(object: RMXSprite, var speed: RMFloatB = 1, doOnArrival: (sender: RMXSprite, objects: [AnyObject]?)-> AnyObject? = RMXSprite.stop, objects: AnyObject ... )-> AnyObject? {
        let dist = self.turnToFace(object)
        if  dist >= fabs(object.reach + self.reach) {
            #if OPENGL_OSX
                speed *= 0.5
            #endif
            self.accelerateForward(speed)
            if !self.hasGravity {
                let climb = speed * 0.1
                if self.altitude < object.altitude {
                    self.accelerateUp(climb)
                } else if self.altitude > object.altitude {
                    self.accelerateUp(-climb / 2)
                } else {
                    self.upStop()
                    RMXVector3SetY(&self.node.physicsBody!.velocity, 0)
                }
            }
            
        } else {
            let result: AnyObject? = doOnArrival(sender: self, objects: objects)
            return result ?? dist
        }
        return dist

    }
    
///TODO Theta may be -ve?
    func turnToFace(object: RMXSprite) -> RMFloatB {
        var goto = object.centerOfView
        
        
        let theta = -RMXGetTheta(vectorA: self.position, vectorB: goto)
        self.setTheta(leftRightRadians: theta)
        
        if self.hasGravity { //TODO delete and fix below
            RMXVector3SetY(&goto,self.position.y)
        }

        
        /*else {
            let phi = -RMXGetPhi(vectorA: self.position, vectorB: goto) //+ PI_OVER_2
            self.body.setPhi(upDownRadians: phi)
        }*/

        return self.distanceTo(point: goto)
    }
    
   
    
}


extension RMXSprite {
    
    func getSprite(#node: RMXNode) -> RMXSprite? {
        if node.physicsBody == nil || node.physicsBody!.type == .Static {
            return nil
        } else if node.name == nil || node.name!.isEmpty {
            let sprite = RMXSprite.new(parent: self)
            sprite.node = node
            return sprite
        } else {
            for sprite in self.children {
                if sprite.name == node.name {
                    return sprite
                }
            }
        }
        let sprite = RMXSprite.new(parent: self)
        sprite.node = node
        return sprite
    }
}
