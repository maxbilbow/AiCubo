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
                if sprite.rmxID != world.observer.rmxID {
                    
                
                        sprite.isAlwaysActive = true
                    
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
                                            sprite.plusAngle(Float(random() % 360) , y: Float(random() % 360), z: Float(random() % 360))
                                            accelerating = true
                                            sprite.body.accelerateForward(10)
                                        }
                                        
                                        
                                    } else {
                                        if accelerating && timePassed < 100 {
                                            sprite.body.accelerateForward(speed)
                                        }
                                        //sprite.plusAngle(theta,y: phi)
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
        var isReadyToChase = false
        var isChasing = false
        var isFetching = false
        var pacingSpeed: Float = 3
        poppy.behaviours.append { () -> () in
            timePassed += 1
            if timePassed > 30 {
                println("time > 600")
                if world.observer.hasItem && !isReadyToChase {
                    poppy.actions.releaseItem()
                    poppy.stop()
                    poppy.body.position = world.observer.position + world.observer.body.forwardVector + world.observer.body.forwardVector
                    isReadyToChase = true
                    itemToWatch = world.observer.actions.item
                    println("poppy.stop()")
                } else { //if !world.observer.hasItem || itemToWatch != nil {
                     println("observer has no item")
//                     if !poppy.hasItem {
                        if !isChasing {
                            poppy.plusAngle(Float(random() % 360), y:0)
                            poppy.body.accelerateForward(3)
                            isChasing = true
                            isReadyToChase = false
                            println("isChasing")
                        } else if itemToWatch != nil {
                            if !world.observer.hasItem {
                                poppy.actions.grabItem(item: itemToWatch)
                                println("poppy.actions!.grabItem(item: itemToWatch")
                                itemToWatch = nil
                                isChasing = false
                                isFetching = true
                            }
                        } else if poppy.hasItem {
                            if isFetching {
                                poppy.plusAngle(Float(random() % 360), y:0)
                                poppy.body.accelerateForward(3)
                                isFetching = false
                                println("isFetching")
                            } else {
                                println("Throw or pace")
                                poppy.actions.throwItem(10)
                                poppy.body.accelerateForward(pacingSpeed)
                                pacingSpeed = -pacingSpeed
                            }
                        } else {
                            if !poppy.actions.prepareToJump() {
                                poppy.body.accelerateForward(pacingSpeed)
                                pacingSpeed = -pacingSpeed
                            }
                            println("poppy.actions?.prepareToJump() or pace")
                        }
                    }
//                else if poppy.body.distanceTo(world.observer) < 50 {
//                        poppy.plusAngle(Float(random() % 360), y:0)
//                        poppy.body.accelerateForward(3)
//                        println("poppy.body.accelerateForward(3)")
//                    } else {
//                        poppy.actions.prepareToJump()
//                        println("poppy.actions?.prepareToJump()")
//                    }
                    timePassed = 0
            } else {
                println("time = \(timePassed)")
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