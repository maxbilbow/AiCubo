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
                self.world.action(action: "stop")
                self.world.action(action: "extendArm", speed: 0)
                self.log()
            }
        }
        func handleTapLeft(recognizer: UITapGestureRecognizer) {
            self.log("Left Tap")
            self.world.action(action: "grab")
            _handleRelease(recognizer.state)
        }
        
        func handleTapRight(recognizer: UITapGestureRecognizer) {
            self.log("Right Tap")
            self.world.action(action: "throw", speed: 10)
            _handleRelease(recognizer.state)
        }
        
        func noTouches(recognizer: UIGestureRecognizer) {
            if recognizer.state == UIGestureRecognizerState.Ended {
                self.world.action(action: "stop")
                self.log("noTouches?")
            }
            _handleRelease(recognizer.state)
        }
        
        func handleDoubleTouch(recognizer: UITapGestureRecognizer) {
            self.log("Double Touch")
            _handleRelease(recognizer.state)
        }
        
        func handleDoubleTouchTap(recognizer: UITapGestureRecognizer) {
            self.log()
            self.world.action(action: "toggleGravity")
            _handleRelease(recognizer.state)
        }
        
        func handleTripleTap(recognizer: UITapGestureRecognizer) {
            self.log("Triple Tap")
            self.world.reset()
            _handleRelease(recognizer.state)
        }
        
        func longPressGestureRecognizer(recognizer: UILongPressGestureRecognizer){
            self.log()
            self.world.action(action: "toggleAllGravity")
            _handleRelease(recognizer.state)
        }
        
        
        //The event Le method
        func handlePanLeftSide(recognizer: UIPanGestureRecognizer) {
            if recognizer.numberOfTouches() == 1 {
                if recognizer.state == UIGestureRecognizerState.Ended {
                    self.world.action(action: "stop")
                    self.log("stop")
                } else {
                    let point = recognizer.velocityInView(gvc.view); let speed:Float = -0.01
                    self.world.action(action: "move", speed: speed, point: [Float(point.x),0, Float(point.y)])
                    self.log("start")
                }
            }
            _handleRelease(recognizer.state)
            
        }
        
        //The event handling method
        func handlePanRightSide(recognizer: UIPanGestureRecognizer) {
            if recognizer.numberOfTouches() == 1 {
                let point = recognizer.velocityInView(gvc.view);
                let speed:Float = 0.02
                self.world.action(action: "look", speed: speed, point: [Float(point.x), Float(point.y)])
            } else if recognizer.numberOfTouches() == 2 {
                if recognizer.state == UIGestureRecognizerState.Ended {
                    self.world.action(action: "jump")
                    self.log("Jump")
                } else {
                    self.log("Prepare to jump")
                    self.world.action(action: "jump", speed: 1)
                }
            }
            _handleRelease(recognizer.state)
        }
        
        func handlePanDownTwo(recognizer: UIPanGestureRecognizer) {
            _handleRelease(recognizer.state)
        }
        
        
        func handleSwipeUp(recognizer: UISwipeGestureRecognizer) {
            self.log()
            self.world.action(action: "forward", speed: 1)
            _handleRelease(recognizer.state)
        }
        func handleSwipeDown(recognizer: UISwipeGestureRecognizer) {
            self.log()
            self.world.action(action: "back", speed: 1)
            _handleRelease(recognizer.state)
        }
        func handleSwipeLeft(recognizer: UISwipeGestureRecognizer) {
            self.log()
            self.world.action(action: "left", speed: 1)
            _handleRelease(recognizer.state)
        }
        func handleSwipeRight(recognizer: UISwipeGestureRecognizer) {
            self.log()
            self.world.action(action: "right", speed: 1)
            _handleRelease(recognizer.state)
        }
        func handlePinch(recognizer: UIPinchGestureRecognizer) {
            let x: Float = Float(recognizer.scale) * 0.2
            self.log()
            self.world.action(action: "enlargeItem", speed: x)
            _handleRelease(recognizer.state)
        }
        
        
        func longPressLeft(recognizer: UILongPressGestureRecognizer) {
            self.log()
            if recognizer.state == UIGestureRecognizerState.Began {
                self.world.action(action: "extendArm", speed: -1)
                self.world.action(action: "toggleAllGravity")
            } else if recognizer.state == UIGestureRecognizerState.Ended {
                self.world.action(action: "extendArm", speed: 0)
            }
            _handleRelease(recognizer.state)
        }
        
        func longPressRight(recognizer: UILongPressGestureRecognizer) {
            self.log()
            if recognizer.state == UIGestureRecognizerState.Began {
                self.world.action(action: "extendArm", speed: 1)
                self.world.action(action: "toggleAllGravity")
            } else if recognizer.state == UIGestureRecognizerState.Ended {
                self.world.action(action: "extendArm", speed: 0)
            }
            _handleRelease(recognizer.state)
        }
        
    }
    