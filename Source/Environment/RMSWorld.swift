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
class RMSWorld : RMXNode {
    static var TYPE: RMXWorldType = .DEFAULT
    let gravityScaler: RMFloatB = 0.01
    ///TODO: Create thos for timekeeping
    var clock: RMXClock?

//    lazy var actionProcessor: RMSActionProcessor = RMSActionProcessor(world: self)
    
    
    lazy var sun: RMXNode = RMXNode.Unique(self).makeAsSun(rDist: self.radius)
    private let GRAVITY: RMFloatB = 9.8
    
    
    lazy var activeCamera: RMXCamera! = RMXCamera(self.activeSprite)
    
    lazy var activeSprite: RMXNode = RMXNode.Unique(self).setAsObserver()
    lazy var physics: RMXPhysics = RMXPhysics(world: self)
    
    lazy var observer: RMXNode = self.activeSprite
    lazy var poppy: RMXNode = RMX.makePoppy(world: self)
    lazy var players: [Int: RMXNode] = [
        self.activeSprite.rmxID: self.activeSprite ,
        self.poppy.rmxID: self.poppy,
        self.sun.rmxID: self.sun
    ]
    
    var worldType: RMXWorldType = .DEFAULT
    
    init(worldType type: RMXWorldType = .DEFAULT, name: String = "The World", radius: RMFloatB = 1000, parent: RMXNode! = nil) {
        super.init()//parentNode: parent, type: .WORLD, name: name)
        self.worldType = type
        self.setLabel(name)
    }
    #if SceneKit
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override init(){
        super.init()
    }
    #endif
    
    private var _firstFetch = true
    
    override func nodeDidInitialize() {
        super.nodeDidInitialize()
        self.body!.setRadius(3000)
        self.world = self
        self.isAnimated = false
        self.isVisible = false
        
        self.worldDidInitialize()
    }

    
    func worldDidInitialize() {
        //for player in players {
            RMX.addBasicCollisionTo(forNode: observer)
        //}
        func createEnvironment() {
            self.insertChildNode(children: self.players)
        }
        //DEFAULT
        self.environments.setType(.DEFAULT)
        RMXArt.initializeTestingEnvironment(self,withAxis: true, withCubes: 0)
        createEnvironment()
        
        //FETCH
        self.environments.setType(.FETCH)
        RMXArt.initializeTestingEnvironment(self,withAxis: false, withCubes: 100, radius: 500, gravity: true)
        RMX.buildScene(self)
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
  
    func setWorldType(worldType type: RMXWorldType = .FETCH){
        self.worldType = type
        self.environments.setType(type)
        #if SceneKit
            //replace childNodes in SCNNode
        #endif
    }
   
            
    func µAt(someBody: RMXNode) -> RMFloatB {
        if !someBody.isInWorld && someBody.isObserver {
            return 0.0000001
        } else if (someBody.position.y <= someBody.ground   ) {
            return 0.2// * RMXGetSpeed(someBody->body.velocity);//Rolling wheel resistance
        } else {
            return 0.01 //air;
        }

    }
    func massDensityAt(someBody: RMXNode) -> RMFloatB {
        if !someBody.isInWorld && someBody.isObserver {
            return 0.01
        } else if someBody.position.y < someBody.ground   {// 8 / 10 ) {// someBody.ground )
            return 99.1 //water or other
        } else {
            return 0.01
        }
    }
    func collisionTest(sender: RMXNode) -> Bool{
    //Have I gone through a barrier?
        let velocity = sender.body!.velocity
        let v = velocity.y
        let p = sender.position.y
        let next = sender.body!.velocity + sender.position
        let bounceY: RMFloatB = -v
        let g = sender.ground
        if p <= g && v < 0 && sender.isInWorld {
            if p < g / sender.body!.coushin {
                RMXVector3SetY(&sender.body!.velocity, bounceY * sender.body!.coushin)
                RMXVector3SetY(&sender.position, g)
            } else {
                RMXVector3SetY(&sender.body!.velocity, sender.hasGravity ? 0 : bounceY * sender.body!.coushin)
                RMXVector3SetY(&sender.position, g)
            }
            return true
        }
        if RMXVector3Length(next) >= self.radius && sender.type != .OBSERVER {
            sender.actions.headTo(self)
            sender.body!.velocity = velocity.negate()
        }
        
        return false
    }
    
    func gravityAt(sender: RMXNode) -> RMXVector3 {
        return self.physics.gravityFor(sender)
    }
    
    
   
    override func animate() {
        super.animate()
    }
    
    override func reset() {
        super.reset()
    }
    
    func closestObjectTo(sender: RMXNode)->RMXNode? {
        var closest: Int = -1
        var dista: RMFloatB = RMFloatB.infinity// = sender.body.distanceTo(closest)
        for object in children {
            let child = object
            if child != sender {
                let distb: RMFloatB = sender.body!.distanceTo(child)
                if distb < dista {
                    closest = child.rmxID
                    dista = distb
                }
            }
        }
        if let result = self.childNodeArray.get(closest) {
                return result
            }
        return nil
    }
    
    func furthestObjectFrom(sender: RMXNode)->RMXNode? {
        var furthest: Int = -1
        var dista: RMFloatB = 0// = sender.body.distanceTo(closest)
        for object in children {
            let child = object
            if child != sender {
                let distb: RMFloatB = sender.body!.distanceTo(child)
                if distb > dista {
                    furthest = child.rmxID
                    dista = distb
                }
            }
        }
        if let result = self.childNodeArray.get(furthest){
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

