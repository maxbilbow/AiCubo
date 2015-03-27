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
    static func buildScene() -> RMSWorld{
        let world: RMSWorld = RMXArt.initializeTestingEnvironment()
        RMXLog("BUILDING")
        autoreleasepool {
            for sprite in world.sprites {
                if sprite.rmxID != world.observer.rmxID {
                    
                    // animate the 3d object
                    
                    //ship.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 2, z: 0, duration: 1000)))
                    if sprite.isAnimated {
                        sprite.isAlwaysActive = true
                        //                        sprite.shape!.node = self.rootNode.childNodeWithName("ship1", recursively: true)!
                        //                        sprite.body.position = RMXVector3Zero()
                        //                        sprite.shape?.draw()
                        sprite.addBehaviour({
                            let dist = sprite.body.distanceTo(world.observer)
                            let distTest = sprite.body.radius + world.observer.body.radius + world.observer.actions!.reach
                            if dist <= distTest / 2 {
                                sprite.body.velocity = GLKVector3Add(sprite.body.velocity, world.observer.body.velocity)
                            } else if dist < distTest * 10 {
                                sprite.actions?.prepareToJump()
                            }
                        })
                        
                        sprite.addBehaviour({
                            if !sprite.hasGravity && world.observer.actions!.item != nil {
                                if sprite.body.distanceTo((world.observer.actions?.item)!) < 50 {
                                    sprite.setHasGravity(true)
                                }
                            }
                        })
                    }
                }
                
                
            }
        }
        //self.world = world
        return world
    }
    
    #if OPENGL_OSX
    static func SetUpGLProxy() -> RMSWorld {
        let world = self.buildScene()
        RMXGLProxy.actions = RMSActionProcessor(world: world)
//        RMXGLProxy.world = world
        return world
    }
    #endif
}