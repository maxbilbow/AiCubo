//
//  RMSWorld.swift
//  RattleGL
//
//  Created by Max Bilbow on 10/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import GLKit

enum RMXWorldType: Int { case NULL = -1, TESTING_ENVIRONMENT, SMALL_TEST, FETCH, DEFAULT }
class RMSWorld : RMXSprite {
    static var TYPE: RMXWorldType = .SMALL_TEST
    let gravityScaler: RMFloatB = 0.05
    ///TODO: Create thos for timekeeping
    var clock: RMXClock?

//    lazy var actionProcessor: RMSActionProcessor = RMSActionProcessor(world: self)
    
    
    lazy var sun: RMXSprite = RMXSprite.Unique(self).makeAsSun(rDist: self.radius)
    private let GRAVITY: RMFloatB = 9.8
    
    
    lazy var activeCamera: RMXCamera = RMXCamera(self)
    
    lazy var activeSprite: RMXSprite = RMXSprite.Unique(self).asObserver()
    lazy var physics: RMXPhysics = RMXPhysics(world: self)
    
    lazy var observer: RMXSprite = self.activeSprite
    lazy var poppy: RMXSprite = RMX.makePoppy(world: self)
    lazy var players: [Int: RMXSprite] = [
        self.activeSprite.rmxID: self.activeSprite ,
        self.poppy.rmxID: self.poppy,
        self.sun.rmxID: self.sun
    ]
    
    var worldType: RMXWorldType = .DEFAULT
    
    init(node: RMXNode,worldType type: RMXWorldType = .DEFAULT, name: String = "The World", radius r: RMFloatB = 3000) {
        super.init()//parentNode: parent, type: .WORLD, name: name)
        self.worldType = type
        self.setName(name)
        self.node.scale = RMXVector3Make(r*2,r*2,r*2)
        println(self.radius)
    }
    
    override func spriteDidInitialize() {
        super.spriteDidInitialize()
        self.world = self
        self.isAnimated = false
        self.isVisible = false
        
        self.worldDidInitialize()
    }

    
    func worldDidInitialize() {
        self.node.scale = RMXVector3Make(6000,6000,6000)

        //for player in players {
          //  RMX.addBasicCollisionTo(forNode: observer)
        //}
        func createEnvironment() {
            self.insertChildren(children: self.players)
        }
        //DEFAULT
        self.environments.setType(.DEFAULT)
        RMXArt.initializeTestingEnvironment(self,withAxis: true, withCubes: 0)
        createEnvironment()
        
        //FETCH
        self.environments.setType(.FETCH)
        RMXArt.initializeTestingEnvironment(self,withAxis: false, withCubes: 10, radius: 100)
        createEnvironment()
        
        //SMALL_TEST
        self.environments.setType(.SMALL_TEST)
        RMXArt.initializeTestingEnvironment(self, withAxis: false, withCubes: 500, radius: 500)
        RMX.buildScene(self)
        createEnvironment()

        //TESTING ENVIRONMENT
        self.environments.setType(.TESTING_ENVIRONMENT)
        RMXArt.initializeTestingEnvironment(self)
        RMX.buildScene(self)
        createEnvironment()

        setWorldType()

    }
  
    func setWorldType(worldType type: RMXWorldType = RMSWorld.TYPE){
        self.worldType = type
        self.environments.setType(type)
        #if SceneKit
            //replace childNodes in SCNNode
        #endif
    }
   
            
    func µAt(someBody: RMXSprite) -> RMFloatB {
        if !someBody.isInWorld && someBody.isObserver {
            return 0.0000001
        } else if (someBody.position.y <= someBody.ground   ) {
            return 0.2// * RMXGetSpeed(someBody->body.velocity);//Rolling wheel resistance
        } else {
            return 0.01 //air;
        }

    }
    func massDensityAt(someBody: RMXSprite) -> RMFloatB {
        if !someBody.isInWorld && someBody.isObserver {
            return 0.0000001
        } else if someBody.position.y < someBody.ground   {// 8 / 10 ) {// someBody.ground )
            return 99.1 //water or other
        } else {
            return 0.01
        }
    }
    func collisionTest(sender: RMXSprite) -> Bool{
    //Have I gone through a barrier?
        let node = sender.node
        let velocity = node.physicsBody!.velocity
        let v = velocity.y
        let p = sender.position.y
        let next = node.physicsBody!.velocity + sender.position
        let bounceY: RMFloatB = -v
        let g = sender.ground
        let coushin: RMFloatB = 2
        if p <= g && v < 0 && sender.isInWorld {
            if p < g / coushin {
                RMXVector3SetY(&node.physicsBody!.velocity, bounceY * coushin)
                RMXVector3SetY(&node.position, g)
            } else {
                RMXVector3SetY(&node.physicsBody!.velocity, sender.hasGravity ? 0 : bounceY * coushin)
                RMXVector3SetY(&node.position, g)
            }
            return true
        }
        if RMXVector3Length(next) >= self.radius && sender.type != .OBSERVER {
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

    
   
    
}

