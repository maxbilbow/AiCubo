//
//  RMSWorld.swift
//  RattleGL
//
//  Created by Max Bilbow on 10/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import GLKit
import SceneKit

enum RMXWorldType: Int { case NULL = -1, TESTING_ENVIRONMENT, SMALL_TEST, FETCH, DEFAULT }
class RMSWorld : RMXSprite {

    override init(node: RMXNode) {
        super.init(node: RMXModels.getNode(shapeType: ShapeType.ROCK.rawValue, mode: .WORLD, radius: 50))
    }
    static var TYPE: RMXWorldType = .SMALL_TEST
    ///TODO: Create thos for timekeeping
    var clock: RMXClock?

//    lazy var actionProcessor: RMSActionProcessor = RMSActionProcessor(world: self)
    
    
    lazy var sun: RMXSprite = RMXSprite.Unique(self, asType: .BACKGROUND).makeAsSun(rDist: self.radius * 2)
    private let GRAVITY: RMFloatB = 0
    
    
    lazy var activeCamera: RMXCamera = RMXCamera(self)
    
    lazy var activeSprite: RMXSprite = RMXSprite.Unique(self, asType: .PLAYER).asShape(size: 20, shape: .SPHERE).asPlayerOrAI()
    lazy var physics: RMXPhysics = RMXPhysics(world: self)
    
    lazy var observer: RMXSprite = self.activeSprite
    lazy var poppy: RMXSprite = RMX.makePoppy(world: self)
    lazy var players: [Int: RMXSprite] = [
        self.activeSprite.rmxID: self.activeSprite ,
        self.poppy.rmxID: self.poppy,
        self.sun.rmxID: self.sun
    ]
    
    var worldType: RMXWorldType = .DEFAULT
    
    override func spriteDidInitialize() {
        super.spriteDidInitialize()
        self.scene = globalScene
        self.world = self
        self.isAnimated = false
        self.isVisible = false
        
        self.worldDidInitialize()
    }

    
    func worldDidInitialize() {
        self.type = .WORLD
        self.scene!.physicsWorld.gravity = RMXVector3Zero

//        self.setColor(color: NSColor.yellowColor())
        let node = SCNNode()
        node.scale = RMXVector3Make(9000,9000,9000)
        node.physicsField = SCNPhysicsField.radialGravityField()
//        self.node.physicsField!.falloffExponent = 0
        node.physicsField!.scope = .InsideExtent
        self.scene!.rootNode.addChildNode(self.node)
        self.scene!.rootNode.addChildNode(node)
        
//        let drag = SCNNode()
//        drag.scale = self.node.scale
//        drag.physicsField = SCNPhysicsField.dragField()
//        drag.physicsField!.strength = 1
        




        //DEFAULT
        self.environments.setType(.DEFAULT)
        RMXArt.initializeTestingEnvironment(self,withAxis: true, withCubes: 100, radius: 500 + self.radius)
        self.insertChildren(children: self.players)

        setWorldType()

    }
  
    func setWorldType(worldType type: RMXWorldType = .DEFAULT){
        self.worldType = type
        self.environments.setType(type)
        #if SceneKit
            //replace childNodes in SCNNode
        #endif
    }
 
    func massDensityAt(someBody: RMXSprite) -> RMFloatB {
        if !someBody.isInWorld && someBody.isObserver {
            return 0.01
        } else if someBody.position.y < someBody.ground   {// 8 / 10 ) {// someBody.ground )
            return 99.1 //water or other
        } else {
            return 0.01
        }
    }
    
    func collisionTest(sender: RMXSprite) -> Bool{
        return false
    //Have I gone through a barrier?
//        return true
//        if !sender.hasGravity { return false }
        let node = sender.node
        let velocity = node.physicsBody!.velocity
        let v = velocity.y
        let p = sender.position.y
        let next = sender.position
        let bounceY: RMFloatB = -v
        let g = sender.node.scale.y / 2 //.ground
        let coushin: RMFloatB = 0
        if p <= g && v < 0{ //&& sender.isInWorld {
            if p < g {/// coushin {
                RMXVector3SetY(&node.physicsBody!.velocity, bounceY * coushin)
                RMXVector3SetY(&node.position, g)
            } else {
                RMXVector3SetY(&node.physicsBody!.velocity, sender.hasGravity ? 0 : bounceY * coushin)
                RMXVector3SetY(&node.position, g)
            }
            return true
        }
        if RMXVector3Length(next) >= self.radius && sender.type != .PLAYER {
            sender.headTo(self)
            node.physicsBody!.velocity = velocity.negate()
        }
        
        return false
    }
    
    func gravityAt(sender: RMXSprite) -> RMXVector3 {
        return self.physics.gravityFor(sender)
    }
    
    
    func closestObjectTo(sender: RMXSprite)->RMXSprite? {
        var closest: Int = -1
        var dista: RMFloatB = RMFloatB.infinity// = sender.body.distanceTo(closest)
        for object in children {
            let child = object
            if child != sender {
                let distb: RMFloatB = sender.distanceTo(child)
                if distb < dista {
                    closest = child.rmxID
                    dista = distb
                }
            }
        }
        if let result = self.childSpriteArray.get(closest) {
                return result
            }
        return nil
    }
    
    func furthestObjectFrom(sender: RMXSprite)->RMXSprite? {
        var furthest: Int = -1
        var dista: RMFloatB = 0// = sender.body.distanceTo(closest)
        for object in children {
            let child = object
            if child != sender {
                let distb: RMFloatB = sender.distanceTo(child)
                if distb > dista {
                    furthest = child.rmxID
                    dista = distb
                }
            }
        }
        if let result = self.childSpriteArray.get(furthest){
                return result
        }   else { return nil }
    }
    
  
    //private var _hasGravity = false
    override func toggleGravity() {
        for object in children {
            let child = object
            if (child != self.observer) && !(child.isLight) {
                child.hasGravity = self.hasGravity
            }
        }
        super.toggleGravity()
    }

    
    override func animate() {
        self.sun.animate()
    }
    
}

