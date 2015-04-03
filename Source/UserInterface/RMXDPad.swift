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
        self.moveSpeed *= -0.05
        self.lookSpeed *= -0.02

    }
    override func update() {
        super.update()
    }
//    
//    override var view: RMXView {
//        return super.view as! RMXView
//    }
    override func setUpGestureRecognisers(){
//        let image = UIImage(contentsOfFile: "popNose.png")
//        button.setImage(image, forState: UIControlState.Normal)
        
        func pauseButton (view: UIView)  {
            let button: UIButton = UIButton(frame: CGRectMake(0, view.bounds.height - 30, view.bounds.width / 3, 20))
            
            button.setTitle("SWITCH", forState:UIControlState.Normal)
            button.addTarget(self, action: Selector("pauseGame:"), forControlEvents:UIControlEvents.TouchDown)
            button.enabled = true
            view.addSubview(button)
            
            let behaviours: UIButton = UIButton(frame: CGRectMake(view.bounds.width / 3, view.bounds.height - 30, view.bounds.width / 3, 20))
            
            behaviours.setTitle("BHAVIOURS", forState:UIControlState.Normal)
//            behaviours.setTitle("BHAVIOURS OFF", forState:UIControlState.Selected)
            behaviours.addTarget(self, action: Selector("toggleBehaviours:"), forControlEvents:UIControlEvents.TouchDown)
            behaviours.enabled = true
            view.addSubview(behaviours)
        }
        
        
        let w = self.gvc.view.bounds.size.width
        let h = self.gvc.view.bounds.size.height
        let leftView: UIView = UIImageView(frame: CGRectMake(0, 0, w/2, h))
        let rightView: UIView = UIImageView(frame: CGRectMake(w/2, 0, w/2, h))
        pauseButton(leftView)
        
        
        
        func setLeftView() {
            
            let view = leftView
            let lPan:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self,action: "panVelocityLeft:")
//            lPan.numberOfTouchesRequired = 1
//            view.addGestureRecognizer(lPan)
            
            let movement:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self,action: "handleMovement:")
//            movement.numberOfTouchesRequired = 1
            movement.minimumPressDuration = 0
            view.addGestureRecognizer(movement)
            
            view.userInteractionEnabled = true
            
            
            let twoFingerTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,  action: "toggleAllGravity:")
            twoFingerTap.numberOfTouchesRequired = 2
            twoFingerTap.numberOfTapsRequired = 1
            view.addGestureRecognizer(twoFingerTap)
            
            self.gvc.view.addSubview(leftView)
        }
        
        func setRightView() {
            
            let view = rightView
            let look:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self,action: "handleOrientation:")
//            look.minimumPressDuration = 0
            view.addGestureRecognizer(look)
            
            let tapRight: UITapGestureRecognizer = UITapGestureRecognizer(target: self,  action: "handleTapRight:")
            view.addGestureRecognizer(tapRight)
            
            
            
            view.addGestureRecognizer(UILongPressGestureRecognizer(target: self,  action: "longPressRight:"))
            view.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: "handlePinch:"))
            view.userInteractionEnabled = true
            self.gvc.view.addSubview(rightView)
            
            let twoFingerTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,  action: "toggleGravity:")
            twoFingerTap.numberOfTouchesRequired = 2
            twoFingerTap.numberOfTapsRequired = 1
            view.addGestureRecognizer(twoFingerTap)
            
            
        }
        
        
    
        
        setLeftView(); setRightView()//; setUpButtons()
        
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
    var moveOrigin: CGPoint = CGPoint(x: 0,y: 0)
    var lookOrigin: CGPoint = CGPoint(x: 0,y: 0)
    func toggleBehaviours(recogniser: UITapGestureRecognizer){
        self.world.hasBehaviour = !self.world.hasBehaviour
        self.world.setBehaviours(self.world.hasBehaviour)
    }
    
}



