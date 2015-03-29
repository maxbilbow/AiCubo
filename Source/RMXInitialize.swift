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
        autoreleasepool {
            for sprite in world.sprites {
                if sprite.rmxID != world.observer.rmxID {
                    
                
                        sprite.isAlwaysActive = true
                    
                        sprite.addBehaviour({
                            let dist = sprite.body.distanceTo(world.observer)
                            let distTest = sprite.body.radius + world.observer.body.radius + world.observer.actions!.reach
                            if dist <= distTest  {
                                sprite.body.velocity = GLKVector3Add(sprite.body.velocity, world.observer.body.velocity)
                            } else if dist < distTest * 0.8 {
                                sprite.actions?.prepareToJump()
                            }
                        })
                        if sprite.isAnimated {
                            sprite.addBehaviour({
                                if !sprite.hasGravity && world.observer.actions!.item != nil {
                                    if sprite.body.distanceTo((world.observer.actions?.item)!) < 50 {
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
        
        self.addAnimals(toWorld: world)
        return world
    }
    static func addAnimals(toWorld world: RMSWorld){
        let poppy: RMSParticle = RMSParticle(world: world, parent: world, name: "Poppy").setAsObserver().setAsShape()!
        poppy.body.position = GLKVector3Make(100,poppy.body.radius,-50)
            var itemToWatch: RMSParticle! = nil
        poppy.isAlwaysActive = true
        var timePassed = 0
        
        poppy.behaviours.append { () -> () in
            if timePassed > 600 {
                if poppy.hasItem {
                    poppy.body.accelerateForward(-10)
                    itemToWatch = nil
                } else if world.observer.hasItem {
                    poppy.stop()
                    itemToWatch = world.observer.actions!.item!
                } else if itemToWatch != nil {
                    poppy.plusAngle(Float(random() % 360), y:0)
                    poppy.body.accelerateForward(10)
                    poppy.actions!.grabItem(item: itemToWatch)
                } else {
                    poppy.plusAngle(Float(random() % 360), y:0)
                    poppy.body.accelerateForward(3)
                }
                timePassed = 0
            } else if poppy.body.distanceTo(world.observer) < 50 {
                if !poppy.actions!.throwItem(10) {
                    poppy.actions?.prepareToJump()
                }
                 timePassed++
                
            }
        }
        world.insertSprite(poppy)
    }
    
    #if OPENGL_OSX
    static func SetUpGLProxy() -> RMSWorld {
        RMXGLProxy.run()
        return RMXGLProxy.world
    }
    #endif
}