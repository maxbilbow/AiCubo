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
    
     let _testing = false
     let _hasMotion = true
    
    let motionManager: CMMotionManager = CMMotionManager()
   
    
    
    override func viewDidLoad(coder: NSCoder!){
        super.viewDidLoad(coder)
        if _hasMotion {
            self.motionManager.startAccelerometerUpdates()
            self.motionManager.startDeviceMotionUpdates()
            self.motionManager.startGyroUpdates()
            self.motionManager.startMagnetometerUpdates()
        }
        
        self.moveSpeed *= -0.2
        #if SceneKit
            self.lookSpeed *= 0.1
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
        
        func pauseButton (view: UIView)  {
            let button: UIButton = UIButton(frame: CGRectMake(0, view.bounds.height - 30, view.bounds.width / 3, 20))
            
            button.setTitle("< CAM ", forState:UIControlState.Normal)
            button.addTarget(self, action: Selector("previousCamera:"), forControlEvents:UIControlEvents.TouchDown)
            button.enabled = true
            view.addSubview(button)
            
            let behaviours: UIButton = UIButton(frame: CGRectMake(view.bounds.width / 3, view.bounds.height - 30, view.bounds.width / 3, 20))
            
            behaviours.setTitle("CAM >", forState:UIControlState.Normal)
//            behaviours.setTitle("BHAVIOURS OFF", forState:UIControlState.Selected)
            behaviours.addTarget(self, action: Selector("nextCamera:"), forControlEvents:UIControlEvents.TouchDown)
            behaviours.enabled = true
            view.addSubview(behaviours)
        }
        
        
        let w = self.gameView!.bounds.size.width
        let h = self.gameView!.bounds.size.height
        let leftView: UIView = UIImageView(frame: CGRectMake(0, 0, w/2, h))
        let rightView: UIView = UIImageView(frame: CGRectMake(w/2, 0, w/2, h))
        pauseButton(leftView)
        
        
        
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
        self.world!.usesBehaviour = !self.world!.usesBehaviour
        self.world!.setBehaviours(self.world!.usesBehaviour)
    }
    
    
    
}



