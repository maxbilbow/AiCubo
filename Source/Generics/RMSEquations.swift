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
    static func doASum(radius: RMFloat, count i: RMFloat, noOfShapes limit: RMFloat ) -> RMXVector4{
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

    static func randomFloat(radius: RMFloat) -> RMFloat{
        return RMFloat(random() % Int(radius))
    }
    
    static var last1:RMFloat = 1
    static var last2:RMFloat = 0
    static func thing(radius maxR: RMFloat, count i: RMFloat, noOfShapes limit: RMFloat) -> RMXVector4 {
        let thisOne = self.last1 + self.last2
        last1 = thisOne
        last2 = last1
        let r = limit * limit / thisOne
        let theta = Float(i)
        return RMXVector4Make(r * i * RMFloat(sinf(theta)),i,r * i * RMFloat(cosf(theta)),1)
    }

    static func circle ( count i: RMFloat, radius r: RMFloat, limit: RMFloat) -> RMXVector4 {
        let x = RMFloat(sin(i)*sin(i)*r)
        let y = RMFloat(sin(i)*cos(i)*r)
        let z = RMFloat(cos(i)*cos(i)*r)
        return  RMXVector4Make(x,y, z,limit)
        
    }
    static func randomSpurt (count i: Int) -> RMXVector4 {
        let result = RMXVector4Make(
            RMFloat(random() % 360 + i),RMFloat(random() % 360 + i),
            RMFloat(random() % 360 + i),RMFloat(random() % 360 + 10)
        )
        return result;
    }

    static func equateContours(x: RMFloat, y: RMFloat)-> RMFloat{
        return x + y;//((x*x +3*y*y) / 0.1 * 50*50 ) + (x*x +5*y*y)*exp2f(1-50*50)/2;
    }


    static func point_on_circle (radius: RMFloat, angle_in_degrees: RMFloat,  centre: RMFloat)->RMXVector4
    {
        let I: RMFloat = 1
        let x:RMFloat = centre + radius * RMFloat(exp( PI * I * ( angle_in_degrees  / 180.0 ) ))
        let y:RMFloat = 0
        let z:RMFloat = centre + radius * RMFloat(exp ( PI * I * ( angle_in_degrees  / 180.0 ) ))
        return RMXVector4Make(x, y, z,0)
    }
}


