//
//  RMSActionProcessor.swift
//  RattleGL
//
//  Created by Max Bilbow on 22/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
#if OSX
import AppKit
    #elseif iOS
    import UIKit
    
    #endif

#if SceneKit
    import SceneKit
    #endif

enum RMXMoveType { case PUSH, DRAG }

extension RMX {
    static var willDrawFog: Bool = false
    
    static func toggleFog(){
        RMX.willDrawFog = !RMX.willDrawFog
        #if OPENGL_OSX
            DrawFog(RMX.willDrawFog)
        #endif
    }
}
class RMSActionProcessor {
    //let keys: RMXController = RMXController()
    var activeSprite: RMXSprite {
        return self.world.observer
    }
    var world: RMSWorld
    
    init(world: RMSWorld){
        self.world = world
        RMXLog()
    }

    var gameView: GameView?
    
    private var _movement: (x:RMFloatB, y:RMFloatB, z:RMFloatB) = (x:0, y:0, z:0)
    private var _panThreshold: RMFloatB = 70
    func movement(action: String!, speed: RMFloatB = 0,  point: [RMFloatB]) -> Bool{
        if action == nil { return false }
        
        if action == "move" && point.count == 3 {
                self.activeSprite.accelerateForward(point[2] * speed)
                self.activeSprite.accelerateLeft(point[0] * speed)
                self.activeSprite.accelerateUp(point[1] * speed)
            
            let sprite = self.activeSprite.node
            sprite
        }
        if action == "stop" {
            self.activeSprite.stop()
            _movement = (0,0,0)
        }
        
        if action == "look" && point.count == 2 {
//            self.activeSprite.eulerAngles.z += point[1] * speed
            self.activeSprite.addTheta(leftRightRadians: point[0] * -speed)
            self.activeSprite.addPhi(upDownRadians: point[1] * speed)
        }
        
        if action == "roll" {//&& self.activeSprite.hasGravity == false {
            //            self.activeSprite.eulerAngles.z += point[1] * speed
            self.activeSprite.addRoll(rollRadians: speed)
        }

        
        if action == "rollLeft"  {
            //            self.activeSprite.eulerAngles.z += point[1] * speed
            self.activeSprite.addRoll(rollRadians: speed)
        }
        
        if action == "rollRight"  {
            //            self.activeSprite.eulerAngles.z += point[1] * speed
            self.activeSprite.addRoll(rollRadians: -speed)
        }
        
        
        if (action == "forward") {
            if speed == 0 {
                self.activeSprite.forwardStop()
            }
            else {
                self.activeSprite.accelerateForward(speed)
            }
        }
        
        if (action == "back") {
            if speed == 0 {
                self.activeSprite.forwardStop()
            }
            else {
                self.activeSprite.accelerateForward(-speed)
            }
        }
        if (action == "left") {
            if speed == 0 {
                self.activeSprite.leftStop()
            }
            else {
                self.activeSprite.accelerateLeft(speed)
            }
        }
        if (action == "right") {
            if speed == 0 {
                self.activeSprite.leftStop()
            }
            else {
                self.activeSprite.accelerateLeft(-speed)
            }
        }
        
        if (action == "up") {
            if speed == 0 {
                self.activeSprite.upStop()
            }
            else {
                self.activeSprite.accelerateUp(-speed)
            }
        }
        if (action == "down") {
            if speed == 0 {
                self.activeSprite.upStop()
            }
            else {
                self.activeSprite.accelerateUp(speed)
            }
        }
        
        if (action == "jump") {
            if speed == 0 {
                self.activeSprite.jump()
            }
            else {
                self.activeSprite.prepareToJump()
            }
        }
        
        if action == "reset" && speed == 1 {
            self.world.reset()
        }
        
        if action == "grab" {
            self.activeSprite.grabItem()
        }
        if action == "throw" && speed != 0 {
            if self.activeSprite.hasItem {
                RMXLog("Throw: \(self.activeSprite.item?.name) with speed: \(speed)")
                self.activeSprite.throwItem(speed)
            }
        }
        if self.activeSprite.hasItem {
            if action == "enlargeItem"   {
                let size = (self.activeSprite.item?.radius)! * speed
                if size > 0.5 && size < 15 {
                    self.activeSprite.item?.setRadius(size)
                    self.activeSprite.item?.node.physicsBody!.mass *= RMFloat(size)
                }

            }
            
            if action == "extendArm" {// && (self.extendArm != speed && self.extendArm != 0) {
                if self.extendArm != speed {
                    self.extendArm = speed * 5
                }
            }
        } else {
            if action == "toggleAllGravity" && speed == 1{
                self.world.toggleGravity()
            }
        }
        
        if action == "toggleGravity" && speed == 1 {
            self.activeSprite.toggleGravity()
        }
        
        
        if action == "toggleMouseLock" && speed == 1{
            #if OPENGL_OSX
            self.activeSprite.mouse.toggleFocus()
            #endif
        }

        
        if action == "lockMouse" && speed == 1 {
            self.isMouseLocked = !self.isMouseLocked

        }
        
        if action == "switchEnvitonment" {
            self.world.environments.plusOne()
        }
        
        if action == "toggleFog" {
            RMX.toggleFog()
        }
        
        if action == "increase" {
            self.activeSprite.node.pivot.m43 += speed
            
        } else if action == "decrease" {
            self.activeSprite.node.pivot.m43 -= speed
        }
        return true
    }
    
    func animate(){
        if self.extendArm != 0 {
            self.activeSprite.extendArmLength(self.extendArm)
        }
    }
        
    var extendArm: RMFloatB = 0
//    var mousePos: NSPoint = NSPoint(x: 0,y: 0)
    var isMouseLocked = false
}