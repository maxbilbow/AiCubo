//
//  Accelorometer.swift
//  AiCubo
//
//  Created by Max Bilbow on 28/03/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
import GLKit

extension RMXDPad {
    func accelerometer() {
//        if true { return }
//        else {
//            let g = self.motionManager.deviceMotion.gravity
//            self.world!.physics.directionOfGravity = RMXVector3Make(RMFloatB(g.x), RMFloatB(g.y), RMFloatB(g.z))
//        }
        
        let key = "accelerometerCounter"
//        let i = self.world!.clock?.getCounter(forKey:key)
//        if i == 1 { self.world!.clock?.setCounter(forKey: key) } else { return }
        if self.motionManager.deviceMotion != nil {
            let tilt = RMFloatB(self.motionManager.deviceMotion.gravity.y)
            let tiltSpeed = RMFloatB(fabs(self.moveSpeed)*2)
            let tiltThreshold: RMFloatB = 0.1
            if tilt > tiltThreshold {
                let speed = (1.0 + tilt) * tiltSpeed
                self.action(action: "roll", speed: speed)
            } else if tilt < -tiltThreshold {
                let speed = (-1.0 + tilt) * tiltSpeed
                self.action(action: "roll", speed: speed)
            }
            
            if !_testing { return }
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
            NSLog("No motion?!")
        }
        // println()
    }
}