//
//  iOSControllers.swift
//  RattleGLES
//
//  Created by Max Bilbow on 25/03/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
import GLKit

#if OPENGL_ES
import UIKit
#endif

extension RMXController {
#if OPENGL_ES
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
                let point = recognizer.velocityInView(gvc.view); let speed:Float = -0.0025
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
            let speed:Float = 0.01
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
        let x: Float = Float(recognizer.scale) * 0.05
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
    
    
    func accelerometer() {
        if true { return }
        else {
            let g = self.motionManager.deviceMotion.gravity
            self.world.physics.directionOfGravity = GLKVector3Make(Float(g.x), Float(g.y), Float(g.z))
        }
        
        let key = "accelerometerCounter"
        //let i = self.world.clock?.getCounter(forKey:key)
        if i == 1 { self.world.clock?.setCounter(forKey: key) } else { return }
        if self.motionManager.deviceMotion != nil {
            var x,y,z, q, r, s, t, u, v,a,b,c,e,f,g,h,i,j,k,l,m:Double
            x = self.motionManager.deviceMotion.gravity.x
            y = self.motionManager.deviceMotion.gravity.y
            z = self.motionManager.deviceMotion.gravity.z
            q = self.motionManager.deviceMotion.magneticField.field.x
            r = self.motionManager.deviceMotion.magneticField.field.y
            s = self.motionManager.deviceMotion.magneticField.field.z
            t = self.motionManager.deviceMotion.rotationRate.x
            u = self.motionManager.deviceMotion.rotationRate.y
            v = self.motionManager.deviceMotion.rotationRate.z
            a = self.motionManager.deviceMotion.attitude.pitch
            b = self.motionManager.deviceMotion.attitude.roll
            c = self.motionManager.deviceMotion.attitude.yaw
            e = self.motionManager.gyroData.rotationRate.x
            f = self.motionManager.gyroData.rotationRate.y
            g = self.motionManager.gyroData.rotationRate.z
            if self.motionManager.magnetometerData != nil {
                h = self.motionManager.magnetometerData.magneticField.x
                i = self.motionManager.magnetometerData.magneticField.y
                j = self.motionManager.magnetometerData.magneticField.z
            } else { h=0;i=0;j=0 }
            k = self.motionManager.deviceMotion.userAcceleration.x
            l = self.motionManager.deviceMotion.userAcceleration.y
            m = self.motionManager.deviceMotion.userAcceleration.z
            
            let d = self.motionManager.deviceMotion.magneticField.accuracy.value
            
            println("           Gravity,\(x.toData()),\(y.toData()),\(z.toData())")
            println("   Magnetic Field1,\(q.toData()),\(r.toData()),\(s.toData())")
            println("   Magnetic Field2,\(h.toData()),\(i.toData()),\(j.toData())")
            println("     Rotation Rate,\(t.toData()),\(u.toData()),\(v.toData())")
            println("Gyro Rotation Rate,\(e.toData()),\(f.toData()),\(g.toData())")
            println("          Attitude,\(a.toData()),\(b.toData()),\(c.toData())")
            println("          userAcc1,\(k.toData()),\(l.toData()),\(m.toData())")
            
            
            if self.motionManager.accelerometerData != nil {
                let dp = "04.1"
                println("          userAcc2,\(self.motionManager.accelerometerData!.acceleration.x.toData()),\(self.motionManager.accelerometerData!.acceleration.y.toData()),\(self.motionManager.accelerometerData!.acceleration.z.toData())")
                // println("      Magnetic field accuracy: \(d)")
            }
        }
        else {
            //log("No motion?!")
        }
        // println()
    }
    
    #endif
}
