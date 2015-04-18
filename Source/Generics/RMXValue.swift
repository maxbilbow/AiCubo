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
    
    var size: RMFloat {
        return RMFloat(self.distanceTo(SCNVector3Zero))
    }
    
    var sum: RMFloat {
        return RMFloat(x + y + z)
    }
    
    var average: RMFloat {
        return self.sum / 3
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

extension GLKQuaternion {
    var print: String {
        return "\(x.toData()) \(y.toData()) \(z.toData()) \(w.toData()) V: \(v.print)"
    }
}


extension SCNVector4 {
    var print: String {
        return "\(x.toData()) \(y.toData()) \(z.toData()) \(w.toData())"
    }
    
    func negate() -> SCNVector4{
        return SCNVector4Make(-x,-y,-z,-w)
    }
    
    func distanceTo(v: SCNVector4) -> CGFloat{
        return CGFloat(GLKVector4Distance(SCNVector4ToGLKVector4(self), SCNVector4ToGLKVector4(v)))
    }
}


extension SCNMatrix4 {
    var print: String {
        let row1 = "   ROW1: \(m11.toData()) \(m12.toData()) \(m13.toData()) \(m14.toData())"
        let row2 = "   ROW2: \(m21.toData()) \(m22.toData()) \(m23.toData()) \(m24.toData())"
        let row3 = "   ROW3: \(m31.toData()) \(m32.toData()) \(m33.toData()) \(m34.toData())"
        let row4 = "   ROW4: \(m41.toData()) \(m42.toData()) \(m43.toData()) \(m44.toData())"
        return "\(row1)\n\(row2)\n\(row3)\n\(row4)\n"
    }
    
    
}


extension GLKMatrix4 {
    var print: String {
        let row1 = "   ROW1: \(m00.toData()) \(m01.toData()) \(m02.toData()) \(m03.toData())"
        let row2 = "   ROW2: \(m10.toData()) \(m11.toData()) \(m12.toData()) \(m13.toData())"
        let row3 = "   ROW3: \(m20.toData()) \(m21.toData()) \(m22.toData()) \(m23.toData())"
        let row4 = "   ROW4: \(m30.toData()) \(m31.toData()) \(m32.toData()) \(m33.toData())"
        return "\(row1)\n\(row2)\n\(row3)\n\(row4)\n"
    }
}