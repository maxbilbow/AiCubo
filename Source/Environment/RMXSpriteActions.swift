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
    var armLength: RMFloat = 0
    lazy private var _reach: RMFloat = self.owner.radius
    var reach:RMFloat {
        return self.owner.radius + _reach
    }
    
    var jumpStrength: RMFloat = 10
    var squatLevel:RMFloat = 0
    private var _prepairingToJump: Bool = false
    private var _goingUp:Bool = false
    private var _ignoreNextJump:Bool = false
    private var _itemWasAnimated:Bool = false
    private var _itemHadGravity:Bool = false
    
    var altitude: RMFloat {
        return self.owner.position.y
    }
    var item: RMXNode?
    var itemPosition: RMXVector3 = RMXVector3Zero
    
    var sprite: RMXNode {
        return self.owner// as! RMXNode
    }

    func throwItem(strength: RMFloat) -> Bool
    {
        if self.item != nil {
            self.item!.isAnimated = true
            self.item!.hasGravity = _itemHadGravity
            let fwd4 = self.owner.forwardVector
            let fwd3 = RMXVector3Make(fwd4.x, fwd4.y, fwd4.z)
            self.item!.body!.velocity = self.owner.body!.velocity + RMXVector3MultiplyScalar(fwd3,strength)
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
            let fwd4 = self.owner.forwardVector
            let fwd3 = RMXVector3Make(fwd4.x, fwd4.y, fwd4.z)
            self.item!.transform = RMXMatrix4Translate(self.item!.transform, self.owner.viewPoint + RMXVector3MultiplyScalar(fwd3, self.armLength + self.item!.radius + self.owner.radius))
        }
    }
    
    private func setItem(item: RMXNode!){
        self.item = item
        
        if item != nil {
            self.owner.insertChildNode(item)
            self.item?.wasJustWoken = true
            //self.sprite.itemPosition = item!.body.position
            _itemWasAnimated = item!.isAnimated
            _itemHadGravity = item!.hasGravity
            self.item!.hasGravity = false
            self.item!.isAnimated = true
            self.armLength = self.reach
        }
    }
    
    func grabItem(item: RMXNode? = nil) -> Bool {
        if self.item != nil {
            self.releaseItem()
        } else if item != nil {
            self.setItem(item)
        }else if let item = self.owner.world.closestObjectTo(self.sprite) {
            if  self.owner.body!.distanceTo(item) <= self.reach {
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
            self.item!.hasGravity = _itemHadGravity
            self.item!.removeFromParentNode()
            self.world.insertChildNode(self.item!)
            self.setItem(nil)
        }
    }
    
    func extendArmLength(i: RMFloat)    {
        if self.armLength + i > 1 {
            self.armLength += i
        }
    }
    
    func applyForce(force: RMXVector3) {
        self.owner.body!.acceleration += force
    }
    
    enum JumpState { case PREPARING_TO_JUMP, JUMPING, GOING_UP, COMING_DOWN, NOT_JUMPING }
    private var _jumpState: JumpState = .NOT_JUMPING
    private var _maxSquat: RMFloat = 0
    
    func jumpTest() -> JumpState {
        
        switch (_jumpState) {
        case .NOT_JUMPING:
            return _jumpState
        case .PREPARING_TO_JUMP:
            if self.squatLevel > _maxSquat{
                _jumpState = .JUMPING
            } else {
                let increment: RMFloat = _maxSquat / 50
                self.squatLevel += increment
            }
            break
        case .JUMPING:
            if self.altitude > self.owner.body!.radius * 2 || _jumpStrength < self.owner.body!.weight {//|| self.body.velocity.y <= 0 {
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
            if self.altitude <= self.owner.body!.radius {
                _jumpState = .NOT_JUMPING
            }
            break
        default:
            fatalError("Shouldn't get here")
        }
        return _jumpState
    }
    
    func prepareToJump() -> Bool{
        if _jumpState == .NOT_JUMPING && self.owner.isGrounded {
            _jumpState = .PREPARING_TO_JUMP
            _maxSquat = self.owner.body!.radius / 4
            return true
        } else {
            return false
        }
    }
    
    private var _jumpStrength: RMFloat {
        return fabs(self.owner.body!.weight * self.jumpStrength * self.squatLevel/_maxSquat)
    }
    func jump() {
        if _jumpState == .PREPARING_TO_JUMP {
            _jumpState = .JUMPING
        }
    }

    func setReach(reach: RMFloat) {
        _reach = reach
    }
    
    private class func stop(sender: RMXNode, objects: [AnyObject]?) -> AnyObject? {
        sender.body!.completeStop()
        return nil
    }
    
    func headTo(object: RMXNode, var speed: RMFloat = 1, doOnArrival: (sender: RMXNode, objects: [AnyObject]?)-> AnyObject? = RMXSpriteActions.stop, objects: AnyObject ... )-> AnyObject? {
        let dist = self.turnToFace(object)
        if  dist >= fabs(object.actions.reach + self.reach) {
            #if OPENGL_OSX
                speed *= 0.5
            #endif
            self.owner.body!.accelerateForward(speed)
            if !self.owner.hasGravity {
                let climb = speed * 0.1
                if self.owner.altitude < object.altitude {
                    self.owner.body!.accelerateUp(climb)
                } else if self.owner.altitude > object.altitude {
                    self.owner.body!.accelerateUp(-climb / 2)
                } else {
                    self.owner.body!.upStop()
                    RMXVector3SetY(&self.body.velocity, 0)
                }
            }
            
        } else {
            let result: AnyObject? = doOnArrival(sender: self.owner, objects: objects)
            return result ?? dist
        }
        return dist

    }
    
    func turnToFace(object: RMXNode) -> RMFloat {
        var goto = object.centerOfView
        
        
        let theta = -RMXGetTheta(vectorA: self.position, vectorB: goto)
        self.owner.body!.setTheta(leftRightRadians: theta)
        
        if self.owner.hasGravity { //TODO delete and fix below
            RMXVector3SetY(&goto,self.owner.position.y)
        }

        
        /*else {
            let phi = -RMXGetPhi(vectorA: self.position, vectorB: goto) //+ PI_OVER_2
            self.body.setPhi(upDownRadians: phi)
        }*/

        return self.owner.body!.distanceTo(point: goto)
    }
    
   
    override func animate() {
        super.animate()
        self.jumpTest()
//        if self.parent.parent! == self.world {
////            if self.parent.isObserver {
////                println("State: \(self._jumpState.hashValue), Grounded? \(self.parent.isGrounded), SqLevel: \(self.squatLevel), MaxSq: \(_maxSquat) V:\(self.parent.body.velocity.y) G:\(self.body.acceleration.y)")
////            }
//        }
    }
}