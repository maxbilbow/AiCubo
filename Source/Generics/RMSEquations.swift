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
    static func doASum(radius: RMFloatB, count i: RMFloatB, noOfShapes limit: RMFloatB ) -> RMXVector4{
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
            return RMXVector4Make(randomFloat(radius*2)-radius,randomFloat(2*radius),randomFloat(radius*2)-radius, randomFloat(radius))
        }
        
    }

    static func randomFloat(radius: RMFloatB) -> RMFloatB{
        return RMFloatB(random() % Int(radius))
    }
    
    static var last1:RMFloatB = 1
    static var last2:RMFloatB = 0
    static func thing(radius maxR: RMFloatB, count i: RMFloatB, noOfShapes limit: RMFloatB) -> RMXVector4 {
        let thisOne = self.last1 + self.last2
        last1 = thisOne
        last2 = last1
        let r = limit * limit / thisOne
        let theta = Float(i)
        return RMXVector4Make(r * i * RMFloatB(sinf(theta)),i,r * i * RMFloatB(cosf(theta)),1)
    }

    static func circle ( count i: RMFloatB, radius r: RMFloatB, limit: RMFloatB) -> RMXVector4 {
        let x = RMFloatB(sin(i)*sin(i)*r)
        let y = RMFloatB(sin(i)*cos(i)*r)
        let z = RMFloatB(cos(i)*cos(i)*r)
        return  RMXVector4Make(x,y, z,limit)
        
    }
    static func randomSpurt (count i: Int) -> RMXVector4 {
        let result = RMXVector4Make(
            RMFloatB(random() % 360 + i),RMFloatB(random() % 360 + i),
            RMFloatB(random() % 360 + i),RMFloatB(random() % 360 + 10)
        )
        return result;
    }

    static func equateContours(x: RMFloatB, y: RMFloatB)-> RMFloatB{
        return x + y;//((x*x +3*y*y) / 0.1 * 50*50 ) + (x*x +5*y*y)*exp2f(1-50*50)/2;
    }


    static func point_on_circle (radius: RMFloatB, angle_in_degrees: RMFloatB,  centre: RMFloatB)->RMXVector4
    {
        let I: RMFloatB = 1
        let x:RMFloatB = centre + radius * RMFloatB(exp( PI * I * ( angle_in_degrees  / 180.0 ) ))
        let y:RMFloatB = 0
        let z:RMFloatB = centre + radius * RMFloatB(exp ( PI * I * ( angle_in_degrees  / 180.0 ) ))
        return RMXVector4Make(x, y, z,0)
    }
}


