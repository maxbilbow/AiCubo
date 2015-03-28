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
                    
                        sprite.isAlwaysActive = true
                        //                        sprite.shape!.node = self.rootNode.childNodeWithName("ship1", recursively: true)!
                        //                        sprite.body.position = RMXVector3Zero()
                        //                        sprite.shape?.draw()
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
                    }
                }
                
                
            }
        }
        
        //self.world = world
        return world
    }
    
    #if OPENGL_OSX
    static func SetUpGLProxy() -> RMSWorld {
        RMXGLProxy.run()
        return RMXGLProxy.world
    }
    #endif
}