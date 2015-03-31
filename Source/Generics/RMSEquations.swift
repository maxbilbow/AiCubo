//
//  RMSEquations.swift
//  RattleGLES
//
//  Created by Max Bilbow on 23/03/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
import GLKit

extension RMX {
    static func doASum(radius: Float, count i: Float, noOfShapes limit: Float ) -> GLKVector4{
//        return thing(radius: radius, count: i, noOfShapes: limit )
        let option: Int = random() % 5
        switch option {
//        case 0:
//            return circle ( count: i,  radius: radius, limit: limit)
//        case 1:
//            return randomSpurt(count: Int(radius))
//        case 2:
//            return point_on_circle(radius,angle_in_degrees: tan(i),centre: 0)
//        case 3:
//            return thing(radius: radius, count: i, noOfShapes: limit )
        default:
            let radius = ceil(radius)
            return GLKVector4Make(randomFloat(radius*2)-radius,randomFloat(2*radius),randomFloat(radius*2)-radius, randomFloat(radius))
        }
        
        
    }

    static func randomFloat(radius: Float) -> Float{
        return Float(random() % Int(radius))
    }
    static var last1:Float = 1
    static var last2:Float = 0
    static func thing(radius maxR: Float, count i: Float, noOfShapes limit: Float) -> GLKVector4 {
        let thisOne = self.last1 + self.last2
        last1 = thisOne
        last2 = last1
        let r = limit * limit / thisOne
        let theta = i
        return GLKVector4Make(r * i * sinf(theta),i,r * i * cosf(theta),1)
    }

    static func circle ( count i: Float, radius r: Float, limit: Float) -> GLKVector4 {
        
        return  GLKVector4Make(sin(i)*sin(i)*r, sin(i)*cos(i)*r, cos(i)*cos(i)*r,limit)
        
    }
    static func randomSpurt (count i: Int) -> GLKVector4 {
        let result = GLKVector4Make(
            Float(random() % 360 + i),Float(random() % 360 + i),
            Float(random() % 360 + i),Float(random() % 360 + 10)
        )
        return result;
    }

    static func equateContours(x: Float, y: Float)-> Float{
        return x + y;//((x*x +3*y*y) / 0.1 * 50*50 ) + (x*x +5*y*y)*exp2f(1-50*50)/2;
    }


    static func point_on_circle (radius: Float, angle_in_degrees: Float,  centre: Float)->GLKVector4
    {
        let I: Float = 1
        let x:Float = centre + radius * exp( PI * I * ( angle_in_degrees  / 180.0 ) )
        let y:Float = 0
        let z:Float = centre + radius * exp ( PI * I * ( angle_in_degrees  / 180.0 ) )
        return GLKVector4Make(x, y, z,0)
    }
}


