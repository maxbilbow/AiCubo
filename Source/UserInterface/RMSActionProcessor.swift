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


    import SceneKit

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
    
    init(world: RMSWorld, gameView: GameView){
        self.world = world
        self.gameView = gameView
        RMXLog()
    }

    var gameView: GameView
    
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
            self.activeSprite.lookAround(theta: point[0] * speed,phi: point[1] * speed)
        }
        
        if action == "roll" {
//            self.activeSprite.addRoll(rollRadians: speed)
            self.activeSprite.lookAround(roll: speed)
        }

        
        if action == "rollLeft"  {
            self.activeSprite.lookAround(roll: -speed)
        }
        
        if action == "rollRight"  {
            self.activeSprite.lookAround(roll: speed)
        }
        
        
        if (action == "forward") {
            if speed == 0 {
                self.activeSprite.stop()
            }
            else {
                self.activeSprite.accelerateForward(speed)
            }
        }
        
        if (action == "back") {
            if speed == 0 {
                self.activeSprite.stop()
            }
            else {
                self.activeSprite.accelerateForward(-speed)
            }
        }
        if (action == "left") {
            if speed == 0 {
                self.activeSprite.stop()
            }
            else {
                self.activeSprite.accelerateLeft(speed)
            }
        }
        if (action == "right") {
            if speed == 0 {
                self.activeSprite.stop()
            }
            else {
                self.activeSprite.accelerateLeft(-speed)
            }
        }
        
        if (action == "up") {
            if speed == 0 {
                self.activeSprite.stop()
            }
            else {
                self.activeSprite.accelerateUp(-speed)
            }
        }
        if (action == "down") {
            if speed == 0 {
                self.activeSprite.stop()
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
        
        if action == "nextCamera" && speed == 1 {
            let cameraNode = self.activeSprite.getNextCamera()
            #if SceneKit
                self.gameView.pointOfView = cameraNode
                #else
                self.world.activeCamera = cameraNode.camera as! RMXCamera
            #endif
            
        } else if action == "previousCamera" && speed == 1 {
            let cameraNode = self.activeSprite.getPreviousCamera()
            #if SceneKit
                self.gameView.pointOfView = cameraNode
                #else
                self.world.activeCamera = cameraNode.camera as! RMXCamera
            #endif
        }
        
        if action == "reset" {
            self.activeSprite.node.position = self.activeSprite.startingPoint
            self.activeSprite.node.physicsBody!.resetTransform()

        }
        
        return true
        
    }
    
    func animate(){
        if self.extendArm != 0 {
            self.activeSprite.extendArmLength(self.extendArm)
        }
        let node = self.activeSprite.node.presentationNode()
         RMXLog("\n    vel:\(self.activeSprite.node.physicsBody!.velocity.print)\n    Pos:\(node.position.print)\n transform:\n\(node.transform.print)\n  orientation:\n\(self.activeSprite.orientation.print)")
         }
        
    var extendArm: RMFloatB = 0
//    var mousePos: NSPoint = NSPoint(x: 0,y: 0)
    var isMouseLocked = false
}