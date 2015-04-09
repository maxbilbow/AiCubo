//
//  iOSControllers.swift
//  RattleGLES
//
//  Created by Max Bilbow on 25/03/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
import GLKit

//#if OPENGL_ES
import UIKit
//#endif

extension RMXDPad {
        private func _handleRelease(state: UIGestureRecognizerState) {
            if state == UIGestureRecognizerState.Ended {
                self.action(action: "stop")
                self.action(action: "extendArm", speed: 0)
                self.log()
            }
        }
    
        func handleTapLeft(recognizer: UITapGestureRecognizer) {
            self.log("Left Tap")
            self.action(action: "grab")
            _handleRelease(recognizer.state)
        }
        
        func handleTapRight(recognizer: UITapGestureRecognizer) {
            self.log("Right Tap")
            self.action(action: "throw", speed: 20)
            _handleRelease(recognizer.state)
        }
        
        func noTouches(recognizer: UIGestureRecognizer) {
            if recognizer.state == UIGestureRecognizerState.Ended {
                self.action(action: "stop")
                self.log("noTouches?")
            }
            _handleRelease(recognizer.state)
        }
        
        func handleDoubleTouch(recognizer: UITapGestureRecognizer) {
            self.log("Double Touch")
            _handleRelease(recognizer.state)
        }
        
        func toggleGravity(recognizer: UITapGestureRecognizer) {
            self.log()
            self.action(action: "toggleGravity", speed: 1)
            _handleRelease(recognizer.state)
        }
        
        
    func toggleAllGravity(recognizer: UITapGestureRecognizer) {
        self.log()
        self.action(action: "toggleAllGravity", speed: 1)
        _handleRelease(recognizer.state)
    }
    
    
    func handleMovement(recogniser: UILongPressGestureRecognizer){
        let point = recogniser.locationInView(recogniser.view)
        if recogniser.state == .Began {
            self.moveOrigin = point
        } else if recogniser.state == .Ended {
            _handleRelease(recogniser.state)
        } else {
            let forward = RMFloatB(point.y - self.moveOrigin.y)
            let sideward = RMFloatB(point.x - self.moveOrigin.x)
            self.action(action: "move", speed: self.moveSpeed, point: [sideward,0, forward])
        }
        
    }
    
        ///The event handling method
        func handleOrientation(recognizer: UIPanGestureRecognizer) {
            if recognizer.numberOfTouches() == 1 {
                let point = recognizer.velocityInView(self.view)
                self.action(action: "look", speed: self.lookSpeed, point: [Float(point.x), -Float(point.y)])
            }
//            _handleRelease(recognizer.state)
        }
    
    func handlePinch(recognizer: UIPinchGestureRecognizer) {
            let x: Float = Float(recognizer.scale) * 0.2
            self.log()
            self.action(action: "enlargeItem", speed: x)
            _handleRelease(recognizer.state)
        }
        
    
    func pauseGame(recogniser: UITapGestureRecognizer){
        if RMSWorld.TYPE == .TESTING_ENVIRONMENT {
            RMSWorld.TYPE = .FETCH
        } else {
            RMSWorld.TYPE = .TESTING_ENVIRONMENT
        }
    }
        func longPressLeft(recognizer: UILongPressGestureRecognizer) {
            self.log()
            if recognizer.state == UIGestureRecognizerState.Began {
                self.action(action: "extendArm", speed: -1)
                self.action(action: "toggleAllGravity")
            } else if recognizer.state == UIGestureRecognizerState.Ended {
                self.action(action: "extendArm", speed: 0)
            }
            _handleRelease(recognizer.state)
        }
        
        func longPressRight(recognizer: UILongPressGestureRecognizer) {
            self.log()
            if recognizer.state == UIGestureRecognizerState.Began {
                self.action(action: "extendArm", speed: 1)
                self.action(action: "toggleAllGravity")
            } else if recognizer.state == UIGestureRecognizerState.Ended {
                self.action(action: "extendArm", speed: 0)
            }
            _handleRelease(recognizer.state)
        }
    
    
    
    }




