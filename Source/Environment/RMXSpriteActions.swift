//
//  RMXInteraction.swift
//  RattleGL
//
//  Created by Max Bilbow on 17/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import GLKit

public class RMXSpriteActions {
    var armLength: Float = 0
    private var _reach: Float?
    var reach:Float {
        return _reach ?? self.body.radius * 10
    }
    var jumpStrength: Float = 1
    var squatLevel:Float = 0
    private var _prepairingToJump: Bool = false
    private var _goingUp:Bool = false
    private var _ignoreNextJump:Bool = false
    private var _itemWasAnimated:Bool = false
    private var _itemHadGravity:Bool = false
    var parent: RMSParticle
    var world: RMSWorld
    var item: RMSParticle?
    var itemPosition: RMXVector3 = RMXVector3Zero
    
    var sprite: RMSParticle {
        return self.parent// as! RMSParticle
    }
    
    var body: RMSPhysicsBody {
        return self.sprite.body
    }
    
    init(parent: RMSParticle) {
        self.parent = parent
        self.world = parent.world ?? parent as! RMSWorld
    }
    
    func throwItem(strength: Float)
    {
        if self.item != nil {
            self.item!.isAnimated = true
            self.item!.setHasGravity(_itemHadGravity)
            let fwd4 = self.body.forwardVector
            let fwd3 = GLKVector3Make(fwd4.x, fwd4.y, fwd4.z)
            self.item!.body.velocity = self.body.velocity + GLKVector3MultiplyScalar(fwd3,strength)
            self.item = nil
        } else {
            return
        }
    }
    
    func manipulate() {
        if self.item != nil {
            self.item?.wasJustWoken = true
            let fwd4 = self.body.forwardVector
            let fwd3 = GLKVector3Make(fwd4.x, fwd4.y, fwd4.z)
            self.item?.body.position = self.sprite.viewPoint + GLKVector3MultiplyScalar(fwd3, self.armLength + self.item!.body.radius + self.body.radius)
        }
    }
    
    private func setItem(item: RMSParticle!){
        self.item = item
        if item != nil {
            self.item?.wasJustWoken = true
            //self.sprite.itemPosition = item!.body.position
            _itemWasAnimated = item!.isAnimated
            _itemHadGravity = item!.hasGravity
            self.item!.setHasGravity(false)
            self.item!.isAnimated = true
            self.armLength = self.body.distanceTo(self.item!)
            if RMX.isDebugging { NSLog(item!.name) }
        }
    }
    
    public func grabItem() {
        if self.item != nil {
            self.releaseItem()
        } else {
            let item: RMSParticle? = self.parent.world?.closestObjectTo(self.sprite)
            self.setItem(item)
        }
        if item != nil { RMXLog("HOLDING: \(item!.name)") }
    }
    
    func releaseItem() {
        if item != nil { RMXLog("DROPPED: \(item!.name)") }
        if self.item != nil {
            self.item?.wasJustWoken = true
            self.item!.isAnimated = true //_itemWasAnimated
            self.item!.setHasGravity(_itemHadGravity)
            self.setItem(nil)
        }
    }
    
    func extendArmLength(i: Float)    {
        if self.armLength + i > 1 {
            self.armLength += i
        }
    }
    
    func applyForce(force: RMXVector3) {
        self.body.acceleration += force
    }
    
    func jumpTest() {
        if (_prepairingToJump || _goingUp || self.squatLevel != 0){// || self.squatLevel > 0){
            var i: Float = self.body.radius / 200
            if (_prepairingToJump){
                self.squatLevel += i
                if (self.squatLevel >= self.sprite.ground/4-i) {
                    self.jump()
                    _ignoreNextJump = true
                }
            } else if (self.squatLevel != 0 ) || ( _goingUp ){
                //if (self.goingUp) {
                self.squatLevel -= i * 4
                if (self.squatLevel <= 0) {
                    self.squatLevel = 0
                    _goingUp = false;
                    self.body.upStop()
                }
            }
        }
    }
    
    func prepareToJump() {
        if !_goingUp || _ignoreNextJump {
            _prepairingToJump = true
        }
    }
    
    func jump() {
        if _ignoreNextJump {
            _ignoreNextJump = false
            _goingUp = false
            _prepairingToJump = false
            return
        }
        else if (self.sprite.hasGravity && _prepairingToJump && !_goingUp) {
            let y = self.body.weight * self.jumpStrength * self.body.radius / self.squatLevel
            RMXVector3PlusY(&self.body.acceleration, y)
            _goingUp = true;
            _prepairingToJump = false;
        }
        
    }

    func setReach(reach: Float) {
        _reach = reach
    }
    
}