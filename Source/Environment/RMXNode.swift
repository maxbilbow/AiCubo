//
//  RMXNode.swift
//  RattleGL3-0
//
//  Created by Max Bilbow on 10/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//
import GLKit
import Foundation
import SceneKit
#if SceneKit

    typealias RMXNode = SCNNode
    #else
    typealias RMXNode = RMSNode
    protocol SCNNode {}
    #endif


protocol RMXChildNode {
    var node: RMXNode { get }
    var parentNode: RMXNode? { get }
    var parentSprite: RMXSprite? { get set }
}


#if !SceneKit

class RMSNode {
    var name: String = ""
    var velocity = RMXVector3Zero
    var parentNode: RMXNode?
    var sprite: RMXSprite
    init(sprite: RMXSprite){
        self.sprite = sprite
        self.nodeDidInitialize()
    }
    
    func nodeDidInitialize(){
        
    }
    
    
    var position: RMXVector3 = RMXVector3Zero

    var pivot: SCNMatrix4 = SCNMatrix4Identity
    var scale: RMXVector3 = RMXVector3Make(1,1,1)
    lazy var physicsBody: RMSPhysicsBody? = RMSPhysicsBody(self.sprite)
    var transform: RMXMatrix4 = RMXMatrix4Identity
    
    lazy var geometry: RMXShape? = RMXShape(self.sprite)
    
}
#endif

extension RMXSprite {

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
            
       
    
    
    
  
}

extension RMXSprite {
    
    func setRotationSpeed(speed s: RMFloatB){
        self.rotationSpeed = s
    }

}


extension RMXSprite {
    
    var position: RMXVector3 {
        return self.node.position
    }
    
    func addBehaviour(behaviour: (isOn: Bool) -> ()) {
        self.behaviours.append(behaviour)
        //self.behaviours.last?()
    }
    
    
    var viewPoint: RMXVector3{
        return self.forwardVector + self.node.position
    }
    
    var ground: RMFloatB {
        return self.node.scale.y - self.squatLevel
    }
    
    
    
    var isGrounded: Bool {
        return self.node.position.y <= self.node.scale.y / 2
    }
    
    var upThrust: RMFloatB {
        return self.node.physicsBody!.velocity.y
    }
    
    
}

extension RMXSprite {
    var upVector: RMXVector3 {
       let transform = self.orientation
         #if SceneKit
            
            return RMXVector3Make(transform.m21, transform.m22, transform.m23)
        #else
        let row = GLKMatrix4GetRow(transform, 1)
        return RMXVector3Make(row.x,row.y,row.z)
        #endif
    }
    
    var leftVector: RMXVector3 {
        
            let transform = self.orientation
        #if SceneKit
//        return RMXVector3MakeNormal(transform.m11,transform.m12,transform.m13)
                return RMXVector3Make(transform.m11,transform.m12,transform.m13)
            #else
            let row = GLKMatrix4GetRow(transform, 0)
            return RMXVector3Make(row.x,row.y,row.z)
        #endif
    }
    
    var forwardVector: RMXVector3 {
       
            let transform = self.orientation
         #if SceneKit
            return RMXVector3Make(transform.m31, transform.m32, transform.m33)
//        return RMXVector3MakeNormal(transform.m31, transform.m32, transform.m33)
            #else
            let row = GLKMatrix4GetRow(transform, 2)
            return RMXVector3Make(row.x,row.y,row.z)
        #endif
    }
    
    var orientationMat: RMXMatrix4 {
        let row1 = self.leftVector
        let row2 = self.upVector
        let row3 = self.forwardVector
        let row4 = self.position
        return RMXMatrix4Make(row1, row2, row3, row4: row4)
    }
}


extension RMXSprite {
    
    func grabNode(sprite: RMXSprite?){
        if let sprite = sprite {
            #if SceneKit
            self.insertChild(sprite)
            sprite.node.position = self.forwardVector
            #endif
        }
    }
}

extension RMXSprite {
    func setColor(col: RMXVector4){
        #if SceneKit
            let color = NSColor(red: CGFloat(col.x), green:  CGFloat(col.y), blue:  CGFloat(col.z), alpha:  CGFloat(col.w))
            self.setColor(color: color)
            #else
            self.node.geometry!.color = col
        #endif
    }
    
    func setColor(#color: NSColor){
        #if SceneKit
            self.node.geometry?.firstMaterial!.diffuse.contents = color
            self.node.geometry?.firstMaterial!.diffuse.intensity = 1
            self.node.geometry?.firstMaterial!.specular.contents = color
            self.node.geometry?.firstMaterial!.specular.intensity = 1
            self.node.geometry?.firstMaterial!.ambient.contents = color
            self.node.geometry?.firstMaterial!.ambient.intensity = 1
            self.node.geometry?.firstMaterial!.transparent.intensity = 0
            if self.isLight {
                self.node.geometry?.firstMaterial!.emission.contents = color
                self.node.geometry?.firstMaterial!.emission.intensity = 1
                //                self.geometry?.firstMaterial!.transparency = 0.5
            } else {
                //                self.geometry?.firstMaterial!.doubleSided = true
                
                
            }
            #else
            //self.shape!.color = RMXVector4Make(Float(color.redComponent), Float(color.greenComponent), Float(color.blueComponent), Float(color.brightnessComponent))
        #endif
    }

    func setShape(shapeType type: ShapeType) {
        self.shapeType = type
        #if SceneKit
            let options: [NSObject : AnyObject] = [ SCNPhysicsShapeTypeKey: SCNPhysicsShapeTypeBoundingBox, SCNPhysicsShapeKeepAsCompoundKey : false ]
        switch(type){
        case .CUBE:
            self.node.geometry = RMXShape.CUBE
            self.node.physicsBody!.physicsShape = SCNPhysicsShape(node: self.node,options: options)
            break
        case .SPHERE:
            self.node.geometry = RMXShape.SPHERE
            self.node.physicsBody!.physicsShape = SCNPhysicsShape(node: self.node,options: options)
            break
        case .CYLINDER:
            self.node.geometry = RMXShape.CYLINDER
            self.node.physicsBody!.physicsShape = SCNPhysicsShape(node: self.node,options: options)
            break
        case .PLANE:
            self.node.geometry = RMXShape.PLANE
            self.node.physicsBody!.physicsShape = SCNPhysicsShape(node: self.node,options: options)
            break
        case .FLOOR:
            self.node.geometry = RMXShape.FLOOR
            self.node.physicsBody!.physicsShape = SCNPhysicsShape(geometry: RMXShape.FLOOR,options: options)
            break
        default:
            self.node.geometry = RMXShape.CUBE
            self.node.physicsBody!.physicsShape = SCNPhysicsShape(node: self.node,options: options)
        }
        #endif
    }
    
    func makeAsSun(rDist: RMFloatB = 1000, isRotating: Bool = true, rAxis: RMXVector3 = RMXVector3Make(0,0,1)) -> RMXSprite {
        if self.type == nil {
            self.type = .PASSIVE
        }
        self.setShape(shapeType: .SPHERE)
        self.node.scale = RMXVector3Make(100,100,100)
        self.isVisible = true
        self.isRotating = isRotating
        self.setRotationSpeed(speed: 0.005)
        self.hasGravity = false
        self.isLight = true
        #if SceneKit
            self.setColor(color: NSColor.whiteColor())
            #endif
       
        self.rAxis = rAxis
       // self._rotation = PI / 4
//        self.node.pivot = RMXMatrix4Translate(self.node.pivot, rAxis * rDist)
        self.node.pivot.m41 = rDist
        return self
    }
    
    class ChildSpriteArray {
        var parent: RMXSprite
        private var type: RMXWorldType = .NULL
        private var _key: Int = 0
        
//        var current: UnsafeMutablePointer<[Int:RMXSprite]> {
//            return nodeArray[type.rawValue]
//        }
        private var nodeArray: [ [RMXSprite] ] = [ Array<RMXSprite>() ]
        var current:[RMXSprite] {
            return nodeArray[_key]
        }
        func get(key: Int) -> RMXSprite? {
            for (index, node) in enumerate(self.nodeArray[_key]) {
                if node.rmxID == key{
                    return node
                }
            }
            return nil
        }
        
        func set(node: RMXSprite) {
            self.nodeArray[_key].append(node)
        }
        
        func remove(key: Int) -> RMXSprite? {
           for (index, node) in enumerate(self.nodeArray[_key]) {
                if node.rmxID == key{
                    self.nodeArray[_key].removeAtIndex(index)
                    return node
                }
            }
            return nil
        }
        
        func plusOne(){
            if self._key + 1 > RMXWorldType.DEFAULT.rawValue {
                self._key = 0
            } else {
                self._key += 1
            }
        }
        
        func setType(type: RMXWorldType){
            self.type = type
            self._key = type.rawValue
        }
        
        func getCurrent() ->[RMXSprite]? {
            return self.current
        }
        
        func makeFirst(node: RMXSprite){
            self.remove(node.rmxID)
            self.nodeArray[_key].insert(node, atIndex: 0)
        }
        init(parent: RMXSprite){
            self.parent = parent
            if parent is RMSWorld {
                self.nodeArray.reserveCapacity(RMXWorldType.DEFAULT.rawValue)
                for (var i = 1; i <= RMXWorldType.DEFAULT.rawValue ; ++i){
                    let dict = Array<RMXSprite>()
                    self.nodeArray.append(dict)
                }
            }
        }
    }
}


