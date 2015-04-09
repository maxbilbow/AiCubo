//
//  RMXInitialize.swift
//  RattleGL
//
//  Created by Max Bilbow on 23/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import GLKit

extension RMX {
    static let RANDOM_MOVEMENT = true
    
    static func addBasicCollisionTo(forNode sprite: RMXNode, withActors actors: [Int:RMXNode]){//, inObjets
//        sprite.isAlwaysActive = true
        if sprite.type == .OBSERVER {
            sprite.addBehaviour{ (isOn: Bool)->() in
                if let closest = sprite.world.closestObjectTo(sprite) {
                let distTest = closest.body!.radius + sprite.body!.radius
                    if closest.rmxID != sprite.rmxID {
                        let dist = sprite.body!.distanceTo(closest)
                        if dist <= distTest {
                            closest.body!.velocity += sprite.body!.velocity
                        }
                    }
                }
            }
        }
        /*
        
            if sprite.type != .OBSERVER {
                sprite.addBehaviour{ (isOn: Bool)->() in
                    if !isOn {
                        return
                    }
                    for player in actors {
                        let actor = player.1
                        if actor.rmxID != sprite.rmxID {
                            let distTest = actor.body.radius + sprite.body.radius
                            let dist = sprite.body.distanceTo(actor)
                            if dist <= distTest {
                                sprite.body.velocity = GLKVector3Add(sprite.body.velocity, actor.body.velocity)
                            } else if dist < distTest && actor.type == .OBSERVER{
                                sprite.actions.prepareToJump()
                            }
                        }
                    }
                }

      } */
    }
    static func buildScene(world: RMSWorld) -> RMSWorld{
        
        let poppy = self.makePoppy(world: world)
        
        let observer = world.activeSprite
        let actors = [ 0:observer, 1:poppy ]
        
        autoreleasepool {
            for child in world.children {
                self.addBasicCollisionTo(forNode: child.1, withActors: actors)
            }
            for child in world.children {
                let sprite = child.1
                if sprite.isUnique {
                    return
                }
                if sprite.isAnimated {
                    sprite.addBehaviour{ (isOn: Bool)->() in
                        return
                        if !sprite.hasGravity && world.observer.actions.item != nil {
                            if sprite.body!.distanceTo((world.observer.actions.item)!) < 50 {
                                sprite.hasGravity = true
                            }
                        }
                    }
                var timePassed = 0
                var timeLimit = random() % 600
                let speed:RMFloatB = RMFloatB(random() % 15)/3
//                    let theta = Float(random() % 100)/100
//                    let phi = Float(random() % 100)/100
//                    var target = world.furthestObjectFrom(sprite)
                var randomMovement = false
                var accelerating = false
                    sprite.addBehaviour{ (isOn:Bool) -> () in
                        if !isOn { return }
                    if !self.RANDOM_MOVEMENT { return }
                    if sprite.hasGravity { //Dont start until gravity has been toggled once
                        randomMovement = true
                    }
                
                    if randomMovement && !sprite.hasGravity {
                        if timePassed >= timeLimit {
                            if sprite.hasItem {
                                sprite.actions.turnToFace(observer)
                                sprite.actions.throwItem(500)
                            }
                            timePassed = 0
                            timeLimit = random() % 1600 + 10
                            
                            if sprite.body!.distanceTo(world) > world.radius - 50 {
                                accelerating = false
                                timeLimit = 600
                            } else {
                              let rmxID = random() % RMXNode.COUNT
                                if let target = world.children[rmxID] {
                                sprite.actions.headTo(target, speed: speed, doOnArrival: { (sender, objects) -> AnyObject? in
//                                        if let target = world.furthestObjectFrom(sprite) {
//                                            
//                                        }
                                    sprite.actions.grabItem(item: target)
                                    return nil
                                })
                                
                                accelerating = true
                                }
                            }
                        } else {
                            if accelerating {
                                sprite.body!.accelerateForward(speed)
                            }
                            timePassed++
                        }
                    }
                }
                }
            }
        }
        

        return world
    }
    static func makePoppy(#world: RMSWorld) -> RMXNode{
        let poppy: RMXNode = RMXNode.Unique(world).setAsObserver().setAsShape(type: .CYLINDER)
        poppy.type = .POPPY
        poppy.body!.setRadius(8)
        poppy.startingPoint = RMXVector3Make(100,poppy.radius,-50)
        poppy.position = poppy.startingPoint!
        var itemToWatch: RMXNode! = nil
        poppy.isAlwaysActive = true
        var timePassed = 0
        var state: PoppyState = .IDLE
        var speed: RMFloatB = 0.01
        let updateInterval = 1
        
        poppy.behaviours.append { (isOn: Bool) -> () in
            
            func idle(sender: RMXNode, objects: [AnyObject]? = []) -> AnyObject? {
                sender.body!.addTheta(leftRightRadians: 5 * PI_OVER_180)
                sender.body!.accelerateForward(speed)
                return nil
            }
            
            func fetch(sender: RMXNode, objects: [AnyObject]?) -> AnyObject? {
                //                sender.body.hasGravity = (objects?[0] as! RMXNode).hasGravity
                return sender.actions.grabItem(item: itemToWatch)
            }
            
            func drop(sender: RMXNode, objects: [AnyObject]?) -> AnyObject?  {
                sender.actions.releaseItem()
                return nil
            }
            
            func getReady(sender: RMXNode, objects: [AnyObject]?)  -> AnyObject? {
                sender.body!.completeStop()
                return nil
            }
            
            let observer = world.observer
            switch (state) {
            case .IDLE:
                if observer.hasItem {
                    itemToWatch = observer.actions.item
                    state = .READY_TO_CHASE
                    poppy.hasGravity = observer.hasGravity
                } else {
                    idle(poppy)
                }
                break
            case .READY_TO_CHASE:
                if !observer.hasItem {
                    state = .CHASING
                    poppy.hasGravity = itemToWatch.hasGravity
                } else {
                    poppy.actions.headTo(itemToWatch, speed: speed * 10, doOnArrival: getReady)
                }
                break
            case .CHASING:
                if  observer.hasItem {
                    itemToWatch = observer.actions.item
                    poppy.hasGravity = observer.hasGravity
                    state = .READY_TO_CHASE
                } else if poppy.hasItem {
                    itemToWatch = nil
                    state = .FETCHING
                    poppy.hasGravity = observer.hasGravity
                } else {
                    poppy.actions.headTo(itemToWatch, speed: speed * 10, doOnArrival: fetch, objects: observer)
                }
                break
            case .FETCHING:
                if !poppy.hasItem  {
                    state = .IDLE
                    poppy.hasGravity = observer.hasGravity
                } else {
                    poppy.actions.headTo(observer, speed: speed * 10, doOnArrival: drop)
                }
                break
            default:
                poppy.hasGravity = observer.hasGravity
                if observer.hasItem {
                    state = .READY_TO_CHASE
                } else {
                    state = .IDLE
                    
                }
            }
        }
        poppy.setColor(RMXVector4Make(0.1,0.1,0.1,1.0))
        
        #if SceneKit
            let r: RMFloatB = 0.3
            #else
            let r = poppy.radius / 2
            #endif
        let head = RMXNode().initWithParent(poppy).setAsShape(type: .SPHERE)
        head.body!.setRadius(r)
        head.setColor(RMXVector4Make(0.1,0.1,0.1,0.1))
        head.startingPoint = RMXVector3Make(0,head.scale.y, -head.scale.z)
        head.position = head.startingPoint!
        poppy.insertChildNode(head)
        
       
        return poppy
    }
    

    
    #if OPENGL_OSX
    static func SetUpGLProxy(type: RMXWorldType) -> RMSWorld {
        RMXGLProxy.run(type)
        return RMXGLProxy.world
    }
    #endif
}


