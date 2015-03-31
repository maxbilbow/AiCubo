//
//  RMXInteraction.swift
//  RattleGL
//
//  Created by Max Bilbow on 17/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import GLKit

class RMXSpriteActions : RMSNodeProperty {
    var armLength: Float = 0
    lazy private var _reach: Float = self.body.radius
    var reach:Float {
        return self.body.radius + _reach
    }
    
    var jumpStrength: Float = 10
    var squatLevel:Float = 0
    private var _prepairingToJump: Bool = false
    private var _goingUp:Bool = false
    private var _ignoreNextJump:Bool = false
    private var _itemWasAnimated:Bool = false
    private var _itemHadGravity:Bool = false
    
    var altitude: Float {
        return self.body.position.y
    }
    var item: RMSParticle?
    var itemPosition: RMXVector3 = RMXVector3Zero
    
    var sprite: RMSParticle {
        return self.parent// as! RMSParticle
    }

    func throwItem(strength: Float) -> Bool
    {
        if self.item != nil {
            self.item!.isAnimated = true
            self.item!.setHasGravity(_itemHadGravity)
            let fwd4 = self.body.forwardVector
            let fwd3 = GLKVector3Make(fwd4.x, fwd4.y, fwd4.z)
            self.item!.body.velocity = self.body.velocity + GLKVector3MultiplyScalar(fwd3,strength)
            self.item!.wasJustThrown = true
            self.item = nil
            return true
        } else {
            return false
        }
    }
    
    func manipulate() {
        if self.item != nil {
            self.item?.wasJustWoken = true
            let fwd4 = self.body.forwardVector
            let fwd3 = GLKVector3Make(fwd4.x, fwd4.y, fwd4.z)
            self.item?.position = self.sprite.viewPoint + GLKVector3MultiplyScalar(fwd3, self.armLength + self.item!.body.radius + self.body.radius)
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
            self.armLength = self.reach// self.body.distanceTo(self.item!)
            if RMX.isDebugging { NSLog(item!.name) }
        }
    }
    
    func grabItem(item: RMSParticle? = nil) -> Bool {
        if self.item != nil {
            self.releaseItem()
        } else {
            let item: RMSParticle? = item ?? self.parent.world.closestObjectTo(self.sprite)
            if item != nil && self.body.distanceTo(item!) <= self.reach {
                self.setItem(item)
            }
        }
        if item != nil { return true }
        else { return false }
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
    
    enum JumpState { case PREPARING_TO_JUMP, JUMPING, GOING_UP, COMING_DOWN, NOT_JUMPING }
    private var _jumpState: JumpState = .NOT_JUMPING
    private var _maxSquat: Float = 0
    
    func jumpTest() -> JumpState {
        switch (_jumpState) {
        case .NOT_JUMPING:
            return _jumpState
        case .PREPARING_TO_JUMP:
            if self.squatLevel > _maxSquat{
                _jumpState = .JUMPING
            } else {
                let increment: Float = _maxSquat / 50
                self.squatLevel += increment
            }
            break
        case .JUMPING:
            if self.altitude > self.body.radius * 2 || _jumpStrength < self.body.weight {//|| self.body.velocity.y <= 0 {
                _jumpState = .GOING_UP
                self.squatLevel = 0
            } else {
                RMXVector3PlusY(&self.body.velocity, _jumpStrength)
            }
            break
        case .GOING_UP:
            if self.body.velocity.y <= 0 {
                _jumpState = .COMING_DOWN
            } else {
                //Anything to do?
            }
            break
        case .COMING_DOWN:
            if self.altitude <= self.parent.body.radius {
                _jumpState = .NOT_JUMPING
            }
            break
        default:
            fatalError("Shouldn't get here")
        }
        return _jumpState
    }
    
    func prepareToJump() -> Bool{
        if _jumpState == .NOT_JUMPING && self.parent.isGrounded {
            _jumpState = .PREPARING_TO_JUMP
            _maxSquat = self.body.radius / 4
            return true
        } else {
            return false
        }
    }
    
    private var _jumpStrength: Float {
        return fabs(self.body.weight * self.jumpStrength * self.squatLevel/_maxSquat)
    }
    func jump() {
        if _jumpState == .PREPARING_TO_JUMP {
            _jumpState = .JUMPING
        }
    }

    func setReach(reach: Float) {
        _reach = reach
    }
    
    private class func stop(sender: RMSParticle, objects: [AnyObject]?) -> AnyObject? {
        sender.body.completeStop()
        return nil
    }
    
    func headTo(object: RMSParticle, var speed: Float = 1, doOnArrival: (sender: RMSParticle, objects: [AnyObject]?)-> AnyObject? = RMXSpriteActions.stop, objects: AnyObject ... )-> AnyObject? {
        let dist = self.turnToFace(object)
        if  dist >= fabs(object.actions.reach + self.reach) {
            #if OPENGL_OSX
                speed *= 0.5
            #endif
            self.body.accelerateForward(speed)
            if !self.parent.hasGravity {
                let climb = speed * 0.1
                if self.parent.altitude < object.altitude {
                    self.body.accelerateUp(climb)
                } else if self.parent.altitude > object.altitude {
                    self.body.accelerateUp(-climb / 2)
                } else {
                    self.body.upStop()
                    RMXVector3SetY(&self.body.velocity, 0)
                }
            }
            
        } else {
            let result: AnyObject? = doOnArrival(sender: self.parent, objects: objects)
            return result ?? dist
        }
        return dist

    }
    func turnToFace(object:RMSParticle) -> Float {
        var goto =  object.centerOfView
        
        
        let theta = -RMXGetTheta(vectorA: self.position, vectorB: goto)
        self.body.setTheta(leftRightRadians: theta)
        
        if self.parent.hasGravity { //TODO delete and fix below
            RMXVector3SetY(&goto,self.parent.position.y)
        }

        
        /*else {
            let phi = -RMXGetPhi(vectorA: self.position, vectorB: goto) //+ PI_OVER_2
            self.body.setPhi(upDownRadians: phi)
        }*/

        return self.body.distanceTo(goto)
    }
    
   
    override func animate() {
        super.animate()
        if self.parent.parent! == self.world {
//            if self.parent.isObserver {
//                println("\(self.jumpTest().hashValue) V:\(self.parent.body.velocity.y) G:\(self.body.acceleration.y)")
//            }
        }
    }
}