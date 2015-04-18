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

    override var radius: RMFloatB {
        return 250
    }
    override init(node: RMXNode) {
        super.init(node: RMXModels.getNode(shapeType: ShapeType.NULL.rawValue, mode: .ABSTRACT, radius: 500))
    }
    static var TYPE: RMXWorldType = .SMALL_TEST
    ///TODO: Create thos for timekeeping
    var clock: RMXClock?

//    lazy var actionProcessor: RMSActionProcessor = RMSActionProcessor(world: self)
    
    
    lazy var sun: RMXSprite = RMXSprite.Unique(self, asType: .BACKGROUND).makeAsSun(rDist: self.radius)
    private let GRAVITY: RMFloatB = 0
    
    
    lazy var activeCamera: RMXCamera = RMXCamera(self)
    
    lazy var activeSprite: RMXSprite = RMXSprite.Unique(self, asType: .PLAYER).asShape(radius: 5, height: 15, shape: .CYLINDER, color: NSColor.yellowColor()).asPlayerOrAI()

    
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
        let earth = RMXModels.getNode(shapeType: ShapeType.ROCK.rawValue, mode: .BACKGROUND, radius: self.radius)
        earth.physicsField = SCNPhysicsField.radialGravityField()
//        earth.physicsField!.scope = .OutsideExtent
        earth.physicsField!.categoryBitMask = Int(SCNPhysicsCollisionCategory.Default.rawValue)
//        earth.categoryBitMask = Int(SCNPhysicsCollisionCategory.Default.rawValue)
        
//        self.node.physicsField = SCNPhysicsField.radialGravityField()
//        self.node.categoryBitMask = Int(SCNPhysicsCollisionCategory.Default.rawValue)
//        self.node.physicsField!.scope = .OutsideExtent
        
        self.scene!.rootNode.addChildNode(self.node)
        self.scene!.rootNode.addChildNode(earth)
        
//        let drag = SCNNode()
//        drag.scale = self.node.scale
//        drag.physicsField = SCNPhysicsField.dragField()
//        drag.physicsField!.strength = 1
        


        //cameras
        let sunCam: SCNNode = SCNNode()
        self.scene!.rootNode.addChildNode(sunCam)
        
        sunCam.camera = RMXCamera()
        sunCam.position = RMXVector3Make(0,0,self.sun.node.pivot.m41)
        self.observer.addCamera(sunCam)
        self.observer.addCamera(poppy.node)
        
        
        
        //DEFAULT
        self.environments.setType(.DEFAULT)
        RMXArt.initializeTestingEnvironment(self,withAxis: true, withCubes: 100, radius: 500 + self.radius)
        self.insertChildren(children: self.players)

        setWorldType()

    }
  
    func setWorldType(worldType type: RMXWorldType = .DEFAULT){
        self.worldType = type
        self.environments.setType(type)
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

