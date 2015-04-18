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
    
    static func addBasicCollisionTo(forNode sprite: RMXSprite){//, withActors actors: [Int:RMXSprite]){//, inObjets
//        if sprite.type == .OBSERVER {
            sprite.addBehaviour{ (isOn: Bool)->() in
                if let children = sprite.world!.childSpriteArray.getCurrent() {
                for child in children {
                   // let child = closest.1
//                    if sprite.isObserver{ print("\(child.rmxID) ")}
                    if child.rmxID != sprite.rmxID && child.isAnimated {
                        let distTest = sprite.node.scale.z + child.node.scale.z
                        let dist = sprite.distanceTo(child)
                        if dist <= distTest {
//                            if sprite.isObserver{ print("HIT: \(child.rmxID)\n") }
                            child.node.physicsBody!.velocity += sprite.node.physicsBody!.velocity
                            sprite.world!.childSpriteArray.remove(child.rmxID)
                            sprite.world!.childSpriteArray.makeFirst(child)
                            return
                        }
                    }
                }
            }
        }
    
//            if sprite.type != .OBSERVER {
//                sprite.addBehaviour{ (isOn: Bool)->() in
//                    if !isOn {
//                        return
//                    }
//                    for player in actors {
//                        let actor = player.1
//                        if actor.rmxID != sprite.rmxID {
//                            let distTest = actor.body!.radius + sprite.body!.radius
//                            let dist = sprite.body!.distanceTo(actor)
//                            if dist <= distTest {
//                                sprite.body!.velocity = GLKVector3Add(sprite.body!.velocity, actor.body!.velocity)
//                            }
//                        }
//                    }
//                }
//
//      } 
    }
    static func buildScene(world: RMSWorld) -> RMSWorld{
        
//        let poppy = self.makePoppy(world: world)
//        
        let observer = world.activeSprite
//        let actors = [ 0:observer, 1:poppy ]
        
        autoreleasepool {

            for child in world.children {
                let sprite = child
                if sprite.isUnique {
                    return
                }
                if sprite.type == RMXSpriteType.AI {
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
                                sprite.turnToFace(observer)
                                sprite.throwItem(500)
                            }
                            timePassed = 0
                            timeLimit = random() % 1600 + 10
                            
                            if sprite.distanceTo(point: RMXVector3Zero) > world.radius - 50 {
                                accelerating = false
                                timeLimit = 600
                            } else {
                              let rmxID = random() % RMXSprite.COUNT
                                if let target = world.childSpriteArray.get(rmxID) {
                                sprite.headTo(target, speed: speed, doOnArrival: { (sender, objects) -> AnyObject? in
//                                        if let target = world.furthestObjectFrom(sprite) {
//                                            
//                                        }
                                    sprite.grabItem(item: target)
                                    return nil
                                })
                                
                                accelerating = true
                                }
                            }
                        } else {
                            if accelerating {
                                sprite.accelerateForward(speed)
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
    static func makePoppy(#world: RMSWorld) -> RMXSprite{
        let poppy: RMXSprite = RMXSprite.Unique(world, asType: .AI).asShape(radius: 3, shape: .DOG).asPlayerOrAI()

        poppy.initPosition(startingPoint: RMXVector3Make(100,poppy.node.scale.y / 2,-50))
        var itemToWatch: RMXSprite! = nil
//        poppy.isAlwaysActive = true
        var timePassed = 0
        var state: PoppyState = .IDLE
        var speed: RMFloatB = 0.01
        let updateInterval = 1
        
        poppy.behaviours.append { (isOn: Bool) -> () in
            
            func idle(sender: RMXSprite, objects: [AnyObject]? = []) -> AnyObject? {
                sender.lookAround(theta: 1)
                sender.accelerateForward(speed)
                return nil
            }
            
            func fetch(sender: RMXSprite, objects: [AnyObject]?) -> AnyObject? {
                //                sender.body.hasGravity = (objects?[0] as! RMXSprite).hasGravity
                return sender.grabItem(item: itemToWatch)
            }
            
            func drop(sender: RMXSprite, objects: [AnyObject]?) -> AnyObject?  {
                sender.releaseItem()
                return nil
            }
            
            func getReady(sender: RMXSprite, objects: [AnyObject]?)  -> AnyObject? {
                sender.completeStop()
                return nil
            }
            
            let observer = world.observer
            switch (state) {
            case .IDLE:
                if observer.hasItem {
                    itemToWatch = observer.item
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
                    poppy.headTo(itemToWatch, speed: speed * 10, doOnArrival: getReady)
                }
                break
            case .CHASING:
                if  observer.hasItem {
                    itemToWatch = observer.item
                    poppy.hasGravity = observer.hasGravity
                    state = .READY_TO_CHASE
                } else if poppy.hasItem {
                    itemToWatch = nil
                    state = .FETCHING
                    poppy.hasGravity = observer.hasGravity
                } else {
                    poppy.headTo(itemToWatch, speed: speed * 10, doOnArrival: fetch, objects: observer)
                }
                break
            case .FETCHING:
                if !poppy.hasItem  {
                    state = .IDLE
                    poppy.hasGravity = observer.hasGravity
                } else {
                    poppy.headTo(observer, speed: speed * 10, doOnArrival: drop)
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
        poppy.setColor(GLKVector4Make(0.1,0.1,0.1,1.0))
        /*
        #if SceneKit
            let r: RMFloatB = 0.3
            #else
            let r = poppy.radius / 2
            #endif
        let head = RMXSprite.new(parent: poppy).asShape(scale: RMXVector3Make(r,r,r),shape: .SPHERE)
        head.setRadius(r)
        head.setColor(RMXVector4Make(0.1,0.1,0.1,0.1))
        head.startingPoint = RMXVector3Make(0,head.node.scale.y, -head.node.scale.z)
        head.node.position = head.startingPoint!
        poppy.insertChild(head) */
        
       
        return poppy
    }
    

    
    #if OPENGL_OSX
    static func SetUpGLProxy(type: RMXWorldType) -> RMSWorld {
        RMXGLProxy.run(type)
        return RMXGLProxy.world
    }
    #endif
}


