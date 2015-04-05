//
//  RMXCoreExtensions.swift
//  OC to Swift oGL
//
//  Created by Max Bilbow on 17/02/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
import SceneKit

class RMXValue<T: Comparable> {
   // var n: NSValue = 0
    class func isNegative(n:Int) -> Bool {
        return n < 0
    }
    
    class func isNegative(n:Float) -> Bool {
        return n < 0
    }
    
    class func isNegative(n:Double) -> Bool {
        return n < 0
    }
    
    class func isNegative(n:T) -> Bool {
        return false
    }
    
    class func toData(sender:T, dp:String) -> String {
        
        
//        func isNegative(n:Double) -> Bool {
//            return n < 0.0
//        }
        //switch sender
        var s: String = ""
        if sender is Int {
            //s = isNegative(sender as Int) ? "" : " "
            s += String(format: "\(s)%\(dp)i",sender as! Int)
        } else if sender is Float {
            //s = isNegative(sender as Float) ? "" : " "
            s += String(format: "\(s)%\(dp)f",sender as! Float)
        } else if sender is CGFloat {
            //s = isNegative(sender as Float) ? "" : " "
            s += String(format: "\(s)%\(dp)f",Float(sender as! CGFloat) )
        }else if sender is Double {
            //s = isNegative(sender as Double) ? "" : " "
            s += String(format: "\(s)%\(dp)f",sender as! Double)
        } else {
            s = "ERROR: number is not Int, Foat of Double. "
        }
        return s
    }

}

extension Int {
    func toData(dp:String="05") -> String {
        return RMXValue.toData(self, dp: dp)///NSString(format: "%.\(dp)f", self)
    }
}

extension Float {
    func toData(dp:String="05.2") -> String {
        return RMXValue.toData(self, dp: dp)///NSString(format: "%.\(dp)f", self)
    }
    
    var size: Float {
        return fabs(self)
    }
}
extension Double {
    func toData(dp:String="05.2") -> String {
        return RMXValue.toData(self, dp: dp)
    }
}

extension CGFloat {
    func toData(dp:String="05.2") -> String {
        return RMXValue.toData(self, dp: dp)
    }
}

extension GLKVector3 {
    var print: String {
        return "\(x.toData()) \(y.toData()) \(z.toData())"
    }
    
    func negate() -> GLKVector3{
        return GLKVector3Negate(self)
    }
    
    func distanceTo(v: GLKVector3) -> Float{
        return GLKVector3Distance(self, v)
    }
}

extension SCNVector3 {
    var print: String {
        return "\(x.toData()) \(y.toData()) \(z.toData())"
    }
    
    func negate() -> SCNVector3{
        return SCNVector3Make(-x,-y,-z)
    }
    
    func distanceTo(v: SCNVector3) -> CGFloat{
        let A = SCNVector3ToGLKVector3(self); let B = SCNVector3ToGLKVector3(v)
        return CGFloat(GLKVector3Distance(A,B))
        //return RMXVector3Distance(self, v)
    }
}

extension GLKVector4 {
    var print: String {
        return "\(x.toData()) \(y.toData()) \(z.toData()) \(w.toData())"
    }
    
    func negate() -> GLKVector4{
        return GLKVector4Negate(self)
    }
    
    func distanceTo(v: GLKVector4) -> Float{
        return GLKVector4Distance(self, v)
    }
}
    