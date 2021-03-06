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
   
    
    
    override func viewDidLoad(coder: NSCoder! = nil){
        super.viewDidLoad(coder: coder)
        if _hasMotion {
            self.motionManager.startAccelerometerUpdates()
            self.motionManager.startDeviceMotionUpdates()
            self.motionManager.startGyroUpdates()
            self.motionManager.startMagnetometerUpdates()
        }
        
        self.moveSpeed *= -0.05
        #if SceneKit
            self.lookSpeed *= -0.01
            #else
        self.lookSpeed *= -0.02
        #endif
    }
    override func update() {
        super.update()
        self.accelerometer()
    }
//    
//    override var view: RMXView {
//        return super.view as! RMXView
//    }
    override func setUpGestureRecognisers(){
//        let image = UIImage(contentsOfFile: "popNose.png")
//        button.setImage(image, forState: UIControlState.Normal)
        let topBar: CGFloat = 40; let buttonCount: CGFloat = 5
        func pauseButton (view: UIView)  {
            let button: UIButton = UIButton(frame: CGRectMake(0, 0, view.bounds.width / buttonCount, topBar))
            
            button.setTitle("<SWITCH> ", forState:UIControlState.Normal)
            button.addTarget(self, action: Selector("switchEnvironment:"), forControlEvents:UIControlEvents.TouchDown)
            button.enabled = true
            button.backgroundColor = UIColor.grayColor()
            view.addSubview(button)
            
            let behaviours: UIButton = UIButton(frame: CGRectMake(view.bounds.width / buttonCount, 0, view.bounds.width / buttonCount, topBar))
            
            behaviours.setTitle("<Toggle AI>", forState:UIControlState.Normal)
//            behaviours.setTitle("BHAVIOURS OFF", forState:UIControlState.Selected)
            behaviours.addTarget(self, action: Selector("toggleBehaviours:"), forControlEvents:UIControlEvents.TouchDown)
            behaviours.enabled = true
            behaviours.backgroundColor = UIColor.grayColor()
            view.addSubview(behaviours)
            
            let gravity: UIButton = UIButton(frame: CGRectMake(view.bounds.width * 2 / buttonCount, 0, view.bounds.width / buttonCount, topBar))
            
            gravity.setTitle("<Gravity>", forState:UIControlState.Normal)
            //            behaviours.setTitle("BHAVIOURS OFF", forState:UIControlState.Selected)
            gravity.addTarget(self, action: Selector("toggleAllGravity:"), forControlEvents:UIControlEvents.TouchDown)
            gravity.enabled = true
            gravity.backgroundColor = UIColor.grayColor()
            view.addSubview(gravity)
            
            let playerGravity: UIButton = UIButton(frame: CGRectMake(view.bounds.width * 3 / buttonCount, 0, view.bounds.width / buttonCount, topBar))
            
            playerGravity.setTitle("<My Gravity>", forState:UIControlState.Normal)
            //            behaviours.setTitle("BHAVIOURS OFF", forState:UIControlState.Selected)
            playerGravity.addTarget(self, action: Selector("toggleGravity:"), forControlEvents:UIControlEvents.TouchDown)
            playerGravity.enabled = true
            playerGravity.backgroundColor = UIColor.grayColor()
            view.addSubview(playerGravity)
            
            let jump: UIButton = UIButton(frame: CGRectMake(view.bounds.width * 4 / buttonCount, 0, view.bounds.width / buttonCount, topBar))
            
            jump.setTitle("<JUMP>", forState:UIControlState.Normal)
            //            behaviours.setTitle("BHAVIOURS OFF", forState:UIControlState.Selected)
            jump.addTarget(self, action: Selector("jump:"), forControlEvents:UIControlEvents.TouchDown)
            jump.enabled = true
            jump.backgroundColor = UIColor.grayColor()
            view.addSubview(jump)
        }
        
        
        let w = self.gameView!.bounds.size.width
        let h = self.gameView!.bounds.size.height - topBar
        let leftView: UIView = UIImageView(frame: CGRectMake(0, topBar, w/2, h))
        let rightView: UIView = UIImageView(frame: CGRectMake(w/2, topBar, w/2, h))
        pauseButton(self.view)
        
        
        
        func setLeftView() {
            
            let view = leftView            
            let movement:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self,action: "handleMovement:")
//            movement.numberOfTouchesRequired = 1
            movement.minimumPressDuration = 0
            view.addGestureRecognizer(movement)
            
            view.userInteractionEnabled = true
            
            
            let twoFingerTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,  action: "toggleAllGravity:")
            twoFingerTap.numberOfTouchesRequired = 2
            twoFingerTap.numberOfTapsRequired = 1
            view.addGestureRecognizer(twoFingerTap)
            
            self.gameView!.addSubview(leftView)
        }
        
        func setRightView() {
            
            let view = rightView
            let look:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self,action: "handleOrientation:")
//            look.minimumPressDuration = 0
            view.addGestureRecognizer(look)
            

            view.addGestureRecognizer(UILongPressGestureRecognizer(target: self,  action: "longPressRight:"))
            view.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: "handlePinch:"))
            view.userInteractionEnabled = true
            self.gameView!.addSubview(rightView)
            
            let twoFingerTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,  action: "toggleGravity:")
            twoFingerTap.numberOfTouchesRequired = 2
            twoFingerTap.numberOfTapsRequired = 1
            view.addGestureRecognizer(twoFingerTap)
 
                
            // add a tap gesture recognizer
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "grabOrThrow:"))
           

        }
        
        
    
        
        setLeftView(); setRightView()//; setUpButtons()
        
    }
    
    var i = 0
    var moveOrigin: CGPoint = CGPoint(x: 0,y: 0)
    var lookOrigin: CGPoint = CGPoint(x: 0,y: 0)
    func toggleBehaviours(recogniser: UITapGestureRecognizer){
        self.world!.hasBehaviour = !self.world!.hasBehaviour
        self.world!.setBehaviours(self.world!.hasBehaviour)
    }
    
    func jump(recogniser: UITapGestureRecognizer){
        self.action(action: "jump", speed: 1)
    }
    
}



