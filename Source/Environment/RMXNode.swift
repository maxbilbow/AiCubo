//
//  RMXNode.swift
//  RattleGL3-0
//
//  Created by Max Bilbow on 10/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//
import GLKit
#if SceneKit
import SceneKit
    #else
    protocol SCNNode {}
    #endif
enum RMXNodeType { case DEFAULT, POPPY, OBSERVER, SHAPE, SIMPLE_PARTICLE, WORLD }

protocol RMXChildNode {
    var parent: RMXNode? { get }
}


class RMXNode : SCNNode, RMXChildNode{
    static var COUNT: Int = 0
    var rmxID: Int = RMXNode.COUNT
    var isUnique: Bool = false
    var hasFriction = true
    var hasGravity = false
    lazy var shape: RMXShape = RMXShape(self)

    
    var parent: RMXNode? {
        #if SceneKit
            return self.parentNode as? RMXNode
            #else
            return self.parentNode
        #endif
        
    }
    
    lazy var world: RMSWorld = self as! RMSWorld
    #if OSX
    lazy var mouse: RMXMouse = RMSMouse(parentNode: self)
    #endif
    lazy var actions: RMXSpriteActions = RMXSpriteActions(self)
    var type: RMXNodeType = .DEFAULT
    var wasJustThrown:Bool = false
    var anchor = RMXVector3Zero
    
    #if !SceneKit
    var parentNode: RMXNode?
    var position: GLKVector3 = GLKVector3Zero
    var transform: RMXMatrix4 = RMXMatrix4Identity
    var scale: GLKVector3 = GLKVector3Zero
    lazy var physicsBody: RMSPhysicsBody? = RMSPhysicsBody(self)
    
    
    
//    var body: RMSPhysicsBody {
//        return self.physicsBody!
//    }
    
    var name: String {
        return "\(_name): \(self.rmxID)"
    }
    
    var altitude: RMFloat {
        return self.position.y
    }
    
    var geometry: ShapeType {
        return self.shape.type
    }
    
    #else
    
    var altitude: RMFloat {
        return self.position.y
    }
    #endif
    var body: RMSPhysicsBody? {
         #if SceneKit
        return self.physicsBody as? RMSPhysicsBody
        #else
        return self.physicsBody
        #endif
    }
    
    var centerOfView: RMXVector3 {
        return self.position + self.body!.forwardVector// * self.actions.reach
    }
    
    var isAnimated: Bool = true
    private var _name: String = ""

    var collisionBody: RMSCollisionBody! = nil
    
    var startingPoint: RMXVector3?
    
    lazy var resets: [() -> () ] = [{
        self.body!.velocity = RMXVector3Zero
        self.body!.acceleration = RMXVector3Zero
        self.position = self.startingPoint ?? RMXVector3Zero
        self.transform = RMXMatrix4Identity
    }]
    
    var behaviours: [(Bool) -> ()] = Array<(Bool) -> ()>()
    var children: [Int : RMXNode] = Dictionary<Int, RMXNode>()
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
            _isDrawable = self.shape.isVisible && self.shape.type != .NULL
        }
        return _isDrawable!
    }
    
    
    
    
    //Set automated rotation (used mainly for the sun)
    ///@todo create a behavior protocal/class instead of fun pointers.
    var rAxis = RMXVector3Make(0,0,1)
    private var _rotation: RMFloat = 0
    var rotationCenterDistance:RMFloat = 0
    var isRotating = false
    //static var COUNT: Int = 0
    var isInWorld: Bool {
        return self.body!.distanceTo(self.world) < self.world.body!.radius
    }
    
    
    class func Unique(parentNode:RMXNode?, type: RMXNodeType = .DEFAULT) -> RMXNode {
        let result = RMXNode().initWithParent(parentNode!)
        result.type = type
        result.isUnique = true
        return result
    }
    /*
    @availability(*, deprecated=10.9)
    init(parentNode:RMXNode?, type: RMXNodeType = .DEFAULT, name: String = "RMXNode")
    {
//        self.parentNode = parentNode
        //        self.rmxID = RMXNode.COUNT
        _name = name
        
        self.type = type

        #if SceneKit
            super.init()
            self.geometry = self.shape
            self.physicsBody = RMSPhysicsBody(self)
            self.position = RMXVector3Zero
        #endif
        parentNode?.addChildNode(self)

        
        self.nodeDidInitialize()
    } */
    #if SceneKit
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.geometry = self.shape
        self.physicsBody = RMSPhysicsBody(self)
        self.position = RMXVector3Zero
        self.nodeDidInitialize()
    }
    
    override init(){
        super.init()
        self.geometry = self.shape
        self.physicsBody = RMSPhysicsBody(self)
        self.position = RMXVector3Zero
        self.nodeDidInitialize()
    }
    
   
    #else
    init(){
        self.nodeDidInitialize()
    }
    
    #endif
    
    private var _asObserver = false
    private var _asShape = false

    func initWithParent(parentNode: RMXNode) -> RMXNode {
        #if SceneKit
            parentNode.addChildNode(self)
            #else
            self.parentNode = parentNode
        #endif
        self.world = parentNode.world
        return self
    }
    
    func nodeDidInitialize(){
        RMXNode.COUNT++
        if self.parentNode != nil {
            self.world = self.parent!.world
        }
        func restIf() -> Bool {
            return RMXVector3Length(self.body!.velocity) < 0.01
        }
        self.prepareToRest = restIf
    }
    
    func getName() -> String {
        return _name
    }
    
    func setLabel(name: String){
        _name = name
    }
    
    var label: String {
        return "\(_name): \(self.rmxID)"
    }
    
    @availability(*, deprecated=0.0, obsoleted=1.0, message="Because !")
    func addInitCall(reset: () -> ()){
        self.resets.append(reset)
        self.resets.last?()
    }
   
    func reset(){
        for re in resets {
            re()
        }
        for child in children {
            child.1.reset()
        }
    }
    
    
    var isAlert = true
    var wasJustWoken = false
    var wantsToSleep = false
    var shouldAnimate: Bool {
        if self.isAlwaysActive {
            return true
        } else if self.wasJustWoken {
            self.wasJustWoken == false
            return true
        } else if self.wantsToSleep {
            return self.prepareToRest()
        } else {
            return false
        }
    }
    
    lazy var prepareToRest: (() -> Bool) = {
        return RMXVector3Length(self.body!.velocity) < 0.01
    }

    
    func setRestCondition(restIf: () -> Bool) {
        self.prepareToRest = restIf
    }
    

    ///Useful for global counters across many files

    func getBool(forKey key: String) -> Variable {
        if let b = self.variables[key] {
            return b
        } else {
            let v = Variable(bool: false)
            self.variables.updateValue(v, forKey: key)
            return v
        }
    }
    
    class Variable {
        var i: RMFloat = 0
        var isActive: Bool = false
        let bools: [String:Bool] = [ "isTrue" : false ]
        init(i: RMFloat = 0){
            self.i = i
        }
        
        init(bool: Bool){
            self.isActive = bool
        }
    }
            
    var hasBehaviour = true
    
    
    func insertChildNode(child: RMXNode){
        #if SceneKit
            self.addChildNode(child)
            #else
            child.parentNode = self
        #endif
        child.world = self.world
        self.children[child.rmxID] = child
        #if SceneKit
        self.insertChildNode(child, atIndex: 0)
        #endif
    }
    
    
    func insertChildNode(#children: [Int:RMXNode]){
        for child in children {
            self.insertChildNode(child.1)
        }
    }

    
    func expellChild(id rmxID: Int){
        if let child = self.children[rmxID] {
            if child.parentNode! == self {
                //child.parent! = self.world
                self.children.removeValueForKey(rmxID)
            }
        }
        
    }
    
    func expellChild(child: RMXNode){
        if child.parentNode! == self {
            child.parent!.world = self.world
            self.children.removeValueForKey(child.rmxID)
        }
    }
    
    func removeBehaviours(){
        self.behaviours.removeAll()
    }
    
    func setBehaviours(areOn: Bool){
        self.hasBehaviour = areOn
        for child in children{
            child.1.hasBehaviour = areOn
        }
    }
    
    func animate() {
        for behaviour in self.behaviours {
            behaviour(self.hasBehaviour)
        }
        for child in children {
            child.1.animate()
        }
        if self.isAnimated && self.shouldAnimate {
            self.actions.animate()
            self.body!.animate()
            self.actions.manipulate()
        }
        
        ///add this as a behaviour (create the variables outside of function before adding)
        if self.isRotating {
            self._rotation += self.body!.rotationSpeed / self.rotationCenterDistance
            var temp = RMX.circle(count: self._rotation, radius: self.rotationCenterDistance * 2, limit:  self.rotationCenterDistance)
            self.position = RMXVector3Make(temp.x - self.rotationCenterDistance,temp.y,0)
        }
        
    }
    
    func toggleGravity() {
        self.hasGravity = !self.hasGravity
    }
    
    func toggleFriction() {
        self.hasFriction = !self.hasFriction
    }
    
    
    func setAsShape(type: ShapeType = .CUBE) -> RMXNode {//, mass: RMFloat? = nil, isAnimated: Bool? = true, hasGravity: Bool? = false) -> RMXNode {
        if self._asShape { return self }
        self.shape.type = type
        self.shape.isVisible = true
        #if SceneKit
            switch(type) {
            case .CUBE:
                self.geometry = RMXArt.CUBE
                break
            case .SPHERE:
                self.geometry = RMXArt.SPHERE
                break
            case .CYLINDER:
                self.geometry = RMXArt.CYLINDER
                break
            case .PLANE:
                self.geometry = RMXArt.PLANE
                break
            default:
                self.geometry = RMXArt.CYLINDER
            }
        #endif
        self.resets.append({
            self.shape.isVisible = true
        })
        self._asShape = true
        return self
    }
    
    func setAsObserver() -> RMXNode {
        self.type = .OBSERVER
        if _asObserver { return self }
        self.resets.append({
            self.actions.armLength = self.radius * RMFloat(2)
            
            self.body!.mass = 9

            self.body!.setRadius(20)

            self.position = RMXVector3Make(0,self.radius,-20)
            self.hasGravity = true
            self.isAlwaysActive = true
        })
        _asObserver = true
        self.resets.last?()
        return self
    }

    func resetDrawable(){
        self._isDrawable = nil
    }
}

extension RMXNode {
    
    func setRotationSpeed(speed s: RMFloat){
        self.body!.rotationSpeed = s
    }
    
    var hasItem: Bool {
        return self.actions.item != nil
    }
    
    
}


extension RMXNode {
    
    func addBehaviour(behaviour: (isOn: Bool) -> ()) {
        self.behaviours.append(behaviour)
        //self.behaviours.last?()
    }
    
    
    var viewPoint: RMXVector3{
        return self.body!.forwardVector + self.position
    }
    
    var ground: RMFloat {
        return self.body!.radius - self.actions.squatLevel
    }
    
    func stop() {
        self.body!.velocity = RMXVector3Zero
    }
    
    func rotate(radiansTheta theta: RMFloat,radiansPhi phi: RMFloat = 0,radiansRoll roll: RMFloat = 0,  speed: RMFloat = 1){
        self.body!.addTheta(leftRightRadians: theta * -speed)
        self.body!.addPhi(upDownRadians: phi * speed)
        self.body!.addRoll(sideRollRadians: roll * speed)
    }
    
    var isGrounded: Bool {
        return self.position.y <= self.radius
    }
    
    var upThrust: RMFloat {
        return self.body!.velocity.y
    }
    
    var downForce: RMFloat {
        return self.body!.forces.y
    }
    
    var isLightSource: Bool {
        return self.shape.isLight
    }
    
    var radius: RMFloat {
        #if SceneKit
        return self.body!.radius//.scale.y
        #else
        return self.body!.radius
        #endif
    }
    
}



