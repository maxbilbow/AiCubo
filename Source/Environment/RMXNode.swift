//
//  RMXNode.swift
//  RattleGL3-0
//
//  Created by Max Bilbow on 10/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//
import GLKit
import Foundation
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
    var _rotation: RMFloatB = 0
    var isVisible: Bool = true
    var isLight: Bool = false
    var shapeType: ShapeType = .NULL
    var shape: RMXShape? {
        #if SceneKit
        return self.geometry as? RMXShape
        #else
            return self.geometry
        #endif
    }

    
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
    var position: GLKVector3 {
        let row = GLKMatrix4GetColumn(self.transform, 3)
       return GLKVector3Make(row.x, row.y, row.z)
    }
    var transform: RMXMatrix4 = RMXMatrix4Identity
    var pivot: RMXMatrix4 = RMXMatrix4Identity
    var scale: GLKVector3 = GLKVector3Zero
    lazy var physicsBody: RMSPhysicsBody? = RMSPhysicsBody(self)
    
    
    
//    var body: RMSPhysicsBody {
//        return self.physicsBody!
//    }
    
    var name: String {
        return "\(_name): \(self.rmxID)"
    }
    
    var altitude: RMFloatB {
        return self.position.y
    }
    
    lazy var geometry: RMXShape? = RMXShape(self)
    
    #else
    
    var altitude: RMFloatB {
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
        return self.position + self.forwardVector// * self.actions.reach
    }
    
    var isAnimated: Bool = true
    private var _name: String = ""

    var collisionBody: RMSCollisionBody! = nil
    
    var startingPoint: RMXVector3?
    
    lazy var resets: [() -> () ] = [{
        self.body!.velocity = RMXVector3Zero
        self.body!.acceleration = RMXVector3Zero
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
            _isDrawable = self.shape!.isVisible && self.shape!.type != .NULL
        }
        return _isDrawable!
    }
    
    
    
    
    //Set automated rotation (used mainly for the sun)
    ///@todo create a behavior protocal/class instead of fun pointers.
    var rAxis = RMXVector3Make(0,0,1)
//    private var _rotation: RMFloatB = 0
    var rotationCenterDistance:RMFloatB = 0
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
        self.nodeDidInitialize()
    }
    
    override init(){
        super.init()
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
        self.geometry = RMXShape(self)
        self.physicsBody = RMSPhysicsBody(self)
        self.transform = RMXMatrix4Identity
        self.pivot = RMXMatrix4Identity
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
        var i: RMFloatB = 0
        var isActive: Bool = false
        let bools: [String:Bool] = [ "isTrue" : false ]
        init(i: RMFloatB = 0){
            self.i = i
        }
        
        init(bool: Bool){
            self.isActive = bool
        }
    }
            
    var hasBehaviour = true
    
    
    func insertChildNode(child: RMXNode){
        #if SceneKit
            child.removeFromParentNode()
            self.addChildNode(child)
            #else
            child.parentNode = self
        #endif
        child.world = self.world
        self.children[child.rmxID] = child
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
            #if SceneKit
            self.position = RMXVector3Make(temp.x - self.rotationCenterDistance,temp.y,0)
            #else
            self.transform = RMXMatrix4Translate(self.transform, RMXVector3Make(temp.x - self.rotationCenterDistance,temp.y,0))
            #endif
        }
//        if self.isObserver { RMXLog("\n\(self.orientationMat.print)\n\(self.transform.print),\n   POS: \(self.viewPoint.print)") }
//        if self.isObserver { RMXLog("\n\n   LFT: \(self.leftVector.print),\n    UP: \(self.upVector.print)\n   FWD: \(self.forwardVector.print)\n\n") }
        
    }
    
    func toggleGravity() {
        self.hasGravity = !self.hasGravity
    }
    
    func toggleFriction() {
        self.hasFriction = !self.hasFriction
    }
    
    
    func setAsShape(type: ShapeType = .CUBE) -> RMXNode {//, mass: RMFloatB? = nil, isAnimated: Bool? = true, hasGravity: Bool? = false) -> RMXNode {
        if self._asShape { return self }
        self.shape!.type = type
        self.shape!.isVisible = true
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
            case .FLOOR:
                self.geometry = RMXShape.FLOOR
                break
            default:
                self.geometry = RMXArt.CYLINDER
            }
        #endif
        self.resets.append({
            self.shape!.isVisible = true
        })
        self._asShape = true
        return self
    }
    
    func setAsObserver() -> RMXNode {
        self.type = .OBSERVER
        if _asObserver { return self }
        self.resets.append({
            self.actions.armLength = self.radius * RMFloatB(2)
            
            self.body!.mass = 9

            self.body!.setRadius(20)

            self.transform = RMXMatrix4Translate(self.transform,RMXVector3Make(0,self.radius,-20))
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
    
    func setRotationSpeed(speed s: RMFloatB){
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
        return self.forwardVector + self.position
    }
    
    var ground: RMFloatB {
        return self.body!.radius - self.actions.squatLevel
    }
    
    func stop() {
        self.body!.velocity = RMXVector3Zero
    }
    
    func rotate(radiansTheta theta: RMFloatB,radiansPhi phi: RMFloatB = 0,radiansRoll roll: RMFloatB = 0,  speed: RMFloatB = 1){
        self.body!.addTheta(leftRightRadians: theta * -speed)
        self.body!.addPhi(upDownRadians: phi * speed)
        self.body!.addRoll(sideRollRadians: roll * speed)
    }
    
    var isGrounded: Bool {
        return self.position.y <= self.radius
    }
    
    var upThrust: RMFloatB {
        return self.body!.velocity.y
    }
    
    var downForce: RMFloatB {
        return self.body!.forces.y
    }
    

    
    var radius: RMFloatB {
        #if SceneKit
        return self.body!.radius//.scale.y
        #else
        return self.body!.radius
        #endif
    }
    
}

extension RMXNode {
    var upVector: RMXVector3 {
        #if SceneKit
//            return RMXVector3Make(0,1,0)
        return RMXVector3MakeNormal(self.transform.m21, self.transform.m22, self.transform.m23)
        #else
        let row = GLKMatrix4GetRow(self.transform, 1)
        return RMXVector3MakeNormal(row.x,row.y,row.z)
        #endif
    }
    
    var leftVector: RMXVector3 {
        #if SceneKit
        return RMXVector3MakeNormal(self.transform.m11, self.transform.m12, self.transform.m13)
            #else
            let row = GLKMatrix4GetRow(self.transform, 0)
            return RMXVector3MakeNormal(row.x,row.y,row.z)
        #endif
    }
    
    var forwardVector: RMXVector3 {
        #if SceneKit
        return RMXVector3MakeNormal(self.transform.m31, self.transform.m32, self.transform.m33)
            #else
            let row = GLKMatrix4GetRow(self.transform, 2)
            return RMXVector3MakeNormal(row.x,row.y,row.z)
        #endif
    }
    
    var orientationMat: RMXMatrix4 {
        let row1 = self.leftVector
        let row2 = self.upVector
        let row3 = self.forwardVector
        return RMXMatrix4Make(row1, row2, row3)
    }
}


extension RMXNode {
    
    func grabNode(node: SCNNode?){
        if let node = node {
            #if SceneKit
            self.addChildNode(node)
            node.position = self.viewPoint
            #endif
        }
    }
}

extension RMXNode {
    func setColor(col: RMXVector4){
        #if SceneKit
            let color = NSColor(red: CGFloat(col.x), green:  CGFloat(col.y), blue:  CGFloat(col.z), alpha:  CGFloat(col.w))
            self.setColor(color: color)
            #else
            self.shape!.color = col
        #endif
    }
    
    func setColor(#color: NSColor){
        #if SceneKit
            self.geometry?.firstMaterial!.diffuse.contents = color
            self.geometry?.firstMaterial!.diffuse.intensity = 1
            self.geometry?.firstMaterial!.specular.contents = color
            self.geometry?.firstMaterial!.specular.intensity = 1
            self.geometry?.firstMaterial!.ambient.contents = color
            self.geometry?.firstMaterial!.ambient.intensity = 1
            self.geometry?.firstMaterial!.transparent.intensity = 0
            if self.isLight {
                self.geometry?.firstMaterial!.emission.contents = color
                self.geometry?.firstMaterial!.emission.intensity = 1
                //                self.geometry?.firstMaterial!.transparency = 0.5
            } else {
                //                self.geometry?.firstMaterial!.doubleSided = true
                
                
            }
            #else
            self.shape!.color = RMXVector4Make(Float(color.redComponent), Float(color.greenComponent), Float(color.blueComponent), Float(color.brightnessComponent))
        #endif
    }

    func setShape(shapeType type: ShapeType) {
        self.shapeType = type
        #if SceneKit
        switch(type){
        case .CUBE:
            self.geometry = RMXShape.CUBE
            break
        case .SPHERE:
            self.geometry = RMXShape.SPHERE
            break
        case .CYLINDER:
            self.geometry = RMXShape.CYLINDER
            break
        case .PLANE:
            self.geometry = RMXShape.PLANE
            break
        case .FLOOR:
            self.geometry = RMXShape.FLOOR
            break
        default:
            self.geometry = RMXShape.CUBE
        }
        #endif
    }
    
    func makeAsSun(rDist: RMFloatB = 1000, isRotating: Bool = true, rAxis: RMXVector3 = RMXVector3Make(1,0,0)) -> RMXNode {
        self.setShape(shapeType: .SPHERE)
        self.isVisible = true
        self.rotationCenterDistance = rDist
        self.isRotating = isRotating
        self.setRotationSpeed(speed: 1)
        self.hasGravity = false
        self.isLight = true
        #if SceneKit
            self.setColor(color: NSColor.whiteColor())
            #endif
        self.rAxis = rAxis
       // self._rotation = PI / 4
        return self
    }
}
