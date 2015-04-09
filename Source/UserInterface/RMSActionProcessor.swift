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
    var activeSprite: RMXNode {
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
                self.activeSprite.body!.accelerateForward(point[2] * speed)
                self.activeSprite.body!.accelerateLeft(point[0] * speed)
                self.activeSprite.body!.accelerateUp(point[1] * speed)
        }
        if action == "stop" {
            self.activeSprite.body!.stop()
            _movement = (0,0,0)
        }
        
        if action == "look" && point.count == 2 {
//            self.activeSprite.eulerAngles.z += point[1] * speed
            self.activeSprite.body!.addTheta(leftRightRadians: point[0] * -speed)
            self.activeSprite.body!.addPhi(upDownRadians: point[1] * speed)
        }
        
        if (action == "forward") {
            if speed == 0 {
                self.activeSprite.body!.forwardStop()
            }
            else {
                self.activeSprite.body!.accelerateForward(speed)
            }
        }
        
        if (action == "back") {
            if speed == 0 {
                self.activeSprite.body!.forwardStop()
            }
            else {
                self.activeSprite.body!.accelerateForward(-speed)
            }
        }
        if (action == "left") {
            if speed == 0 {
                self.activeSprite.body!.leftStop()
            }
            else {
                self.activeSprite.body!.accelerateLeft(speed)
            }
        }
        if (action == "right") {
            if speed == 0 {
                self.activeSprite.body!.leftStop()
            }
            else {
                self.activeSprite.body!.accelerateLeft(-speed)
            }
        }
        
        if (action == "up") {
            if speed == 0 {
                self.activeSprite.body!.upStop()
            }
            else {
                self.activeSprite.body!.accelerateUp(-speed)
            }
        }
        if (action == "down") {
            if speed == 0 {
                self.activeSprite.body!.upStop()
            }
            else {
                self.activeSprite.body!.accelerateUp(speed)
            }
        }
        if (action == "jump") {
            if speed == 0 {
                self.activeSprite.actions.jump()
            }
            else {
                self.activeSprite.actions.prepareToJump()
            }
        }
        
        if action == "reset" && speed == 1 {
            self.world.reset()
        }
        
        if action == "grab" {
            self.activeSprite.actions.grabItem()
        }
        if action == "throw" && speed != 0 {
            if self.activeSprite.hasItem {
                RMXLog("Throw: \(self.activeSprite.actions.item?.label) with speed: \(speed)")
                self.activeSprite.actions.throwItem(speed)
            }
        }
        if self.activeSprite.hasItem {
            if action == "enlargeItem"   {
                let size = (self.activeSprite.actions.item?.radius)! * speed
                if size > 0.5 && size < 15 {
                    self.activeSprite.actions.item?.body!.setRadius(size)
                    self.activeSprite.actions.item?.body!.mass *= RMFloat(size)
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
//            self.mousePos = NSEvent.mouseLocation()
//            self.gameView?.cursorUpdate(<#event: NSEvent#>)
        }
        
        if action == "toggleFog" {
            RMX.toggleFog()
        }

//        RMXLog("\(self.world.activeCamera.viewDescription)\n\(action!) \(speed), \(self.world.activeSprite.position.z)\n")
//        println(self.activeSprite.position.print)
        return true
    }
    
    func animate(){
        if self.extendArm != 0 {
            self.activeSprite.actions.extendArmLength(self.extendArm)
        }
    }
        
    var extendArm: RMFloatB = 0
//    var mousePos: NSPoint = NSPoint(x: 0,y: 0)
    var isMouseLocked = false
}