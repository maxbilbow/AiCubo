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
    static var TYPE: RMXWorldType = .DEFAULT
    let gravityScaler: RMFloat = 0.05
    ///TODO: Create thos for timekeeping
    var clock: RMXClock?

    lazy var actionProcessor: RMSActionProcessor = RMSActionProcessor(world: self)
    
    
    lazy var sun: RMXNode = RMXNode.Unique(self).shape.makeAsSun(rDist: self.radius)
    private let GRAVITY: RMFloat = 9.8
    
    
    lazy var activeCamera: RMXCamera! = RMXCamera(self.activeSprite)
    
    lazy var activeSprite: RMXNode = RMXNode.Unique(self).setAsObserver()
    lazy var physics: RMXPhysics = RMXPhysics(world: self)
    
    lazy var observer: RMXNode = self.activeSprite
    lazy var poppy: RMXNode = RMX.makePoppy(witWorld: self)
    lazy var players: [Int: RMXNode] = [
        self.activeSprite.rmxID: self.activeSprite ,
        self.poppy.rmxID: self.poppy,
        self.sun.rmxID: self.sun
    ]
    lazy var achildrenctiveCamera: RMXCamera = RMXCamera(self.observer)
    
    var worldType: RMXWorldType = .DEFAULT
    
    init(worldType type: RMXWorldType = .DEFAULT, name: String = "The World", radius: RMFloat = 2000, parent: RMXNode! = nil) {
        super.init(parent: parent, type: .WORLD, name: name)
        
        self.worldType = type
        self.world = self
        self.body!.radius = radius
        self.activeSprite.addInitCall { () -> () in
            self.observer.position = RMXVector3Make(20, 20, 20)
        }
//        self.activeCamera = RMXCamera(self.activeSprite)
        self.isAnimated = false
        self.shape.isVisible = false
        self.addInitCall ({
            self.worldDidInitialize()
        })
    }
    #if SceneKit
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    #endif
    
    private var _firstFetch = true
    
    
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
        self.actionProcessor.animate()
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

    
    func action(action: String = "reset",speed: RMFloat = 0, point: [RMFloat] = []) {
        self.actionProcessor.movement( action,speed: speed, point: point)
    }
    
    
    
    
}

