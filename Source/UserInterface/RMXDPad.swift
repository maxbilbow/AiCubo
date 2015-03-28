//
//  RMXDPad.swift
//  RattleGL
//
//  Created by Max Bilbow on 23/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import GLKit


import CoreMotion
import UIKit
    

class RMXDPad : RMXInterface {
    
    private let _testing = false
    private let _hasMotion = false
    
    let motionManager: CMMotionManager = CMMotionManager()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        if _hasMotion {
            self.motionManager.startAccelerometerUpdates()
            self.motionManager.startDeviceMotionUpdates()
            self.motionManager.startGyroUpdates()
            self.motionManager.startMagnetometerUpdates()
        }

        self.controllers["accelorometer"] = ( _hasMotion , self.accelerometer )
        

    }
    override func update() {
        super.update()
    }
//    
//    override var view: RMXView {
//        return super.view as! RMXView
//    }
    override func setUpGestureRecognisers(){
        let w = self.gvc.view.bounds.size.width
        let h = self.gvc.view.bounds.size.height
        let leftView: UIView = UIImageView(frame: CGRectMake(0, 0, w/2, h))
        let rightView: UIView = UIImageView(frame: CGRectMake(w/2, 0, w/2, h))
        
        func setLeftView() {
            
            let view = leftView
            let lPan:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self,action: "handlePanLeftSide:")
            view.addGestureRecognizer(lPan)
            
            let tapLeft: UITapGestureRecognizer = UITapGestureRecognizer(target: self,  action: "handleTapLeft:")
            view.addGestureRecognizer(tapLeft)
            
            
            view.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: "handlePinchLeft:"))
            
            view.addGestureRecognizer(UILongPressGestureRecognizer(target: self,  action: "longPressLeft:"))
            
            view.userInteractionEnabled = true
            
            self.gvc.view.addSubview(leftView)
        }
        
        func setRightView() {
            
            let view = rightView
            let rPan:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self,action: "handlePanRightSide:")
            view.addGestureRecognizer(rPan)
            
            let tapRight: UITapGestureRecognizer = UITapGestureRecognizer(target: self,  action: "handleTapRight:")
            view.addGestureRecognizer(tapRight)
            
            
            
            view.addGestureRecognizer(UILongPressGestureRecognizer(target: self,  action: "longPressRight:"))
            
            view.userInteractionEnabled = true
            self.gvc.view.addSubview(rightView)
            
        }
        
        
        
        func setForBothViews(){
            
            
            let view = self.gvc.view
            
            view.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: "handlePinch:"))
            
            let twoFingerTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,  action: "handleDoubleTouchTap:")
            twoFingerTap.numberOfTouchesRequired = 2
            twoFingerTap.numberOfTapsRequired = 1
            view.addGestureRecognizer(twoFingerTap)
            

            //        lp.minimumPressDuration =
            
            
        }
        
        setLeftView(); setRightView(); setForBothViews()
        
        func misc() {
            
            let tt: UITapGestureRecognizer = UITapGestureRecognizer(target: self,  action: "handleTripleTap:")
            tt.numberOfTapsRequired = 3
            rightView.addGestureRecognizer(tt)
            
            let twoFingers: UITapGestureRecognizer = UITapGestureRecognizer(target: self,  action: "handleDoubleTouch:")
            twoFingers.numberOfTouchesRequired = 2
            self.gvc.view.addGestureRecognizer(twoFingers)
            
            
            
            let swipeUp: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self,  action: "handleSwipeUp:")
            swipeUp.numberOfTouchesRequired = 1
            swipeUp.direction = UISwipeGestureRecognizerDirection.Up
            self.gvc.view.addGestureRecognizer(swipeUp)
            
            let swipeDown: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self,  action: "handleSwipeDown:")
            swipeDown.numberOfTouchesRequired = 1
            swipeDown.direction = UISwipeGestureRecognizerDirection.Down
            self.gvc.view.addGestureRecognizer(swipeDown)
            
            let swipeLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self,  action: "handleSwipeLeft:")
            swipeLeft.numberOfTouchesRequired = 1
            swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
            self.gvc.view.addGestureRecognizer(swipeLeft)
            
            let swipeRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self,  action: "handleSwipeRight:")
            swipeRight.numberOfTouchesRequired = 1
            swipeRight.direction = UISwipeGestureRecognizerDirection.Right
            self.gvc.view.addGestureRecognizer(swipeRight)
            
            let swipeDownTwo: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self,  action: "handleSwipeDownTwo:")
            swipeDownTwo.numberOfTouchesRequired = 2
            swipeDownTwo.direction = UISwipeGestureRecognizerDirection.Down
            self.gvc.view.addGestureRecognizer(swipeDownTwo)
        }
    }
    
    var i = 0
    
}


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

