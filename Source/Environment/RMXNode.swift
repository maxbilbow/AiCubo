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
    

    
    func addBehaviour(behaviour: (isOn: Bool) -> ()) {
        self.behaviours.append(behaviour)
        //self.behaviours.last?()
    }
    
    
    var viewPoint: RMXVector3{
        return self.forwardVector + self.position
    }
    
    var ground: RMFloatB {
        return self.node.scale.y - self.squatLevel
    }
    
    
    
    var isGrounded: Bool {
        return self.position.y <= self.node.scale.y / 2
    }
    
    var upThrust: RMFloatB {
        return self.node.physicsBody!.velocity.y
    }
    
    
}


extension RMXSprite {
    var transform: RMXMatrix4 {
        return self.node.presentationNode().transform
    }

    var position: RMXVector3 {
        return self.node.presentationNode().position
    }
    
    var upVector: RMXVector3 {
        let transform = self.transform
        let v = RMXVector3Make(transform.m21, transform.m22, transform.m23)
        return v
    }
    
    var leftVector: RMXVector3 {
        let transform = self.transform
        let v = RMXVector3Make(transform.m11,transform.m12,transform.m13)
        return v
    }
    
    var forwardVector: RMXVector3 {
        let transform = self.transform
        let v = RMXVector3Make(transform.m31, transform.m32, transform.m33)
        return v
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
            self.shape!.color = col
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
    func makeAsSun(rDist: RMFloatB = 1000, isRotating: Bool = true, rAxis: RMXVector3 = RMXVector3Make(0,0,1)) -> RMXSprite {
        if self.type == nil {
            self.type = .BACKGROUND
        }
        self.node = RMXModels.getNode(shapeType: ShapeType.SPHERE.rawValue, mode: .ABSTRACT, radius: 100)
        self.isVisible = true
        self.isRotating = isRotating
        self.setRotationSpeed(speed: 1 * PI_OVER_180 / 10)
        self.hasGravity = false
        self.isLight = true
        #if SceneKit
            self.setColor(color: NSColor.whiteColor())
            #endif
       
        self.rAxis = rAxis
       // self._rotation = PI / 4
//        self.node.pivot = RMXMatrix4Translate(self.node.pivot, rAxis * rDist)
        self.node.pivot.m41 = (self.world.radius + rDist + self.radius) * 10
        self.node.position = self.world.position
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


