//
//  RMSWorld.swift
//  RattleGL
//
//  Created by Max Bilbow on 10/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import GLKit

enum RMXWorldType { case DEFAULT, TESTING_ENVIRONMENT, FETCH }
class RMSWorld : RMXNode {
    static var TYPE: RMXWorldType = .TESTING_ENVIRONMENT
    let gravityScaler: RMFloat = 0.05
    ///TODO: Create thos for timekeeping
    var clock: RMXClock?

//    lazy var actionProcessor: RMSActionProcessor = RMSActionProcessor(world: self)
    
    
    lazy var sun: RMXNode = RMXNode.Unique(self).shape.makeAsSun(rDist: self.radius)
    private let GRAVITY: RMFloat = 9.8
    
    
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
    
    var worldType: RMXWorldType = .TESTING_ENVIRONMENT
    
    init(worldType type: RMXWorldType = .DEFAULT, name: String = "The World", radius: RMFloat = 2000, parent: RMXNode! = nil) {
        super.init()//parentNode: parent, type: .WORLD, name: name)
        
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
        self.body!.setRadius(6000)
        self.world = self
        self.isAnimated = false
        self.shape.isVisible = false
        
        self.worldDidInitialize()
    }
    
    func worldDidInitialize() {
        self.insertChildNode(children: self.players)
        switch (self.worldType){
        case .TESTING_ENVIRONMENT:
            RMXArt.initializeTestingEnvironment(self)
            RMX.buildScene(self)
            break
        case .FETCH:
            RMXArt.initializeTestingEnvironment(self,withAxis: false, withCubes: 100)
            if _firstFetch {
                for child in children {
                    self.players[child.0] = child.1
                }
                _firstFetch = false
            }
            for player in players {
                RMX.addBasicCollisionTo(forNode: player.1, withActors: self.children)
            }
            
            break
        default:
            RMXArt.initializeTestingEnvironment(self,withAxis: true, withCubes: 0)
        }
//        self.reset()
    }
  
    func setWorldType(worldType type: RMXWorldType = .DEFAULT){
        self.worldType = type
        self.children.removeAll(keepCapacity: true)
        self.worldDidInitialize()
    }
   
            
    func µAt(someBody: RMXNode) -> RMFloat {
        if !someBody.isInWorld && someBody.isObserver {
            return 0.0000001
        } else if (someBody.position.y <= someBody.ground   ) {
            return 0.2// * RMXGetSpeed(someBody->body.velocity);//Rolling wheel resistance
        } else {
            return 0.01 //air;
        }

    }
    func massDensityAt(someBody: RMXNode) -> RMFloat {
        if !someBody.isInWorld && someBody.isObserver {
            return 0.0000001
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
        let bounceY: RMFloat = -v
        let g = sender.ground
        if p <= g && v < 0 && sender.isInWorld {
            if p < g / sender.body!.coushin {
                RMXVector3SetY(&sender.body!.velocity, bounceY * sender.body!.coushin)
                RMXMatrix4SetY(&sender.transform, g)
            } else {
                RMXVector3SetY(&sender.body!.velocity, sender.hasGravity ? 0 : bounceY * sender.body!.coushin)
                RMXMatrix4SetY(&sender.transform, g)
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
        var dista: RMFloat = RMFloat.infinity// = sender.body.distanceTo(closest)
        for object in children {
            let child = object.1
            if child != sender {
                let distb: RMFloat = sender.body!.distanceTo(child)
                if distb < dista {
                    closest = child.rmxID
                    dista = distb
                }
            }
        }
        if let result = children[closest] {
            if dista < sender.actions.reach + result.radius  {
                return result
            }
        }
        return nil
    }
    
    func furthestObjectFrom(sender: RMXNode)->RMXNode? {
        var furthest: Int = -1
        var dista: RMFloat = 0// = sender.body.distanceTo(closest)
        for object in children {
            let child = object.1
            if child != sender {
                let distb: RMFloat = sender.body!.distanceTo(child)
                if distb > dista {
                    furthest = child.rmxID
                    dista = distb
                }
            }
        }
        if let result = children[furthest] {
                return result
        }   else { return nil }
    }
    
  
    //private var _hasGravity = false
    override func toggleGravity() {
        for object in children {
            let child = object.1
            if (child != self.observer) && !(child.isLightSource) {
                child.hasGravity = self.hasGravity
            }
        }
        super.toggleGravity()
    }

    
   
    
    
    
    
}

