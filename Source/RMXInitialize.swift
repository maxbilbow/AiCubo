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
    
    static func buildScene() -> RMSWorld{
        let world: RMSWorld = RMXArt.initializeTestingEnvironment()
        RMXLog("BUILDING")
        
        let poppy = self.addPoppy(toWorld: world)
        let observer = world.activeSprite!
        let objects = [ (rmxID: observer.rmxID , reach: observer.actions.reach), (rmxID: poppy.rmxID, reach: poppy.actions.reach) ]
        autoreleasepool {
            for sprite in world.sprites {
                sprite.isAlwaysActive = true
                if sprite.type == .DEFAULT {
                    for object in objects {
                        if object.rmxID != sprite.rmxID {
                        let distTest = object.reach
                        sprite.addBehaviour({
                            let dist = sprite.body.distanceTo(world.observer)
                            
                            if dist <= distTest  {
                                sprite.body.velocity = GLKVector3Add(sprite.body.velocity, world.observer.body.velocity)
                            } else if dist < distTest * 0.5 {
                                sprite.actions.prepareToJump()
                            }
                        })
                        }
                    }
                    if sprite.isAnimated {
                        sprite.addBehaviour({
                            if !sprite.hasGravity && world.observer.actions.item != nil {
                                if sprite.body.distanceTo((world.observer.actions.item)!) < 50 {
                                    sprite.setHasGravity(true)
                                }
                            }
                        })
                    var timePassed = 0
                    var timeLimit = random() % 600
                    let speed:Float = Float(random() % 15)
                    let theta = Float(random() % 100)/100
                    let phi = Float(random() % 100)/100
                    var randomMovement = false
                    var accelerating = false
                    sprite.addBehaviour({ () -> () in
                        if !self.RANDOM_MOVEMENT { return }
                        if sprite.hasGravity { //Dont start until gravity has been toggled once
                            randomMovement = true
                        }
                    
                        if randomMovement && !sprite.hasGravity {
                            if timePassed >= timeLimit {
                                timePassed = 0
                                timeLimit = random() % 600
                                
                                if sprite.body.distanceTo(world) > world.body.radius - 50 {
                                    accelerating = false
                                    timeLimit = 600
                                } else {
                                    let theta = GLKMathDegreesToRadians(Float(random() % 360))
                                    let phi = GLKMathDegreesToRadians(Float(random() % 360))
                                    sprite.rotate(radiansTheta: theta,radiansPhi: phi)
                                    accelerating = true
                                    sprite.body.accelerateForward(10)
                                }
                            } else {
                                if accelerating && timePassed < 100 {
                                    sprite.body.accelerateForward(speed)
                                }
                                timePassed++
                            }
                        }
                    })
                    }
                }
            }
        }
        

        return world
    }
    static func addPoppy(toWorld world: RMSWorld) -> RMSParticle {
        let poppy: RMSParticle = RMSParticle(world: world, parent: world, name: "Poppy").setAsObserver().setAsShape()!
        poppy.body.radius = 8
        poppy.body.position = GLKVector3Make(100,poppy.body.radius,-50)
            var itemToWatch: RMSParticle! = nil
        poppy.isAlwaysActive = true
        var timePassed = 0
        var state: PoppyState = .IDLE
        var pacingSpeed: Float = 3
        let updateInterval = 1

        poppy.behaviours.append { () -> () in
            
            func idle(sender: RMSParticle, objects: [AnyObject]? = []) -> AnyObject? {
                sender.body.addTheta(leftRightRadians: GLKMathDegreesToRadians(10))
                sender.body.accelerateForward(0.1)
                return nil
            }
            
            func fetch(sender: RMSParticle, objects: [AnyObject]?) -> AnyObject? {
//                sender.body.hasGravity = (objects?[0] as! RMSParticle).hasGravity
                return sender.actions.grabItem(item: itemToWatch)
            }
            
            func drop(sender: RMSParticle, objects: [AnyObject]?) -> AnyObject?  {
                sender.actions.releaseItem()
                return nil
            }
            
            func getReady(sender: RMSParticle, objects: [AnyObject]?)  -> AnyObject? {
                sender.body.completeStop()
                return nil
            }
            
            timePassed += 1
           
            
//                NSLog("State: \(state.rawValue), theta: \(GLKMathRadiansToDegrees(poppy.body.theta)), phi: \(GLKMathRadiansToDegrees(poppy.body.phi)) ")
            
            if false { //timePassed < updateInterval {
                if state == .IDLE {
                    idle(poppy)
                }
            } else {
                timePassed = 0
                let observer = world.observer
                switch (state) {
                case .IDLE:
                    if observer.hasItem {
                        itemToWatch = observer.actions.item
                        state = .READY_TO_CHASE
                        poppy.body.hasGravity = observer.hasGravity
                    } else {
                        idle(poppy)
                    }
                    break
                case .READY_TO_CHASE:
                    if !observer.hasItem {
                        state = .CHASING
                        //poppy.body.hasGravity = itemToWatch.hasGravity
                    } else {
                        poppy.actions.headTo(itemToWatch,doOnArrival: getReady)
                    }
                    break
                case .CHASING:
                    if  observer.hasItem {
                        itemToWatch = observer.actions.item
                        poppy.body.hasGravity = observer.hasGravity
                        state = .READY_TO_CHASE
                    } else if poppy.hasItem {
                        itemToWatch = nil
                        state = .FETCHING
                        poppy.body.hasGravity = observer.hasGravity
                    } else {
                        poppy.actions.headTo(itemToWatch,doOnArrival: fetch, objects: observer)
                    }
                    break
                case .FETCHING:
                    if !poppy.hasItem  {
                        state = .IDLE
                        poppy.body.hasGravity = observer.hasGravity
                    } else {
                        poppy.actions.headTo(observer,doOnArrival: drop)
                    }
                    break
                default:
                    poppy.body.hasGravity = observer.hasGravity
                    if observer.hasItem {
                        state = .READY_TO_CHASE
                    } else {
                        state = .IDLE
                        
                    }
                }
            }
        }
        world.insertSprite(poppy)
        return poppy
    }
    
    #if OPENGL_OSX
    static func SetUpGLProxy() -> RMSWorld {
        RMXGLProxy.run()
        return RMXGLProxy.world
    }
    #endif
}


