// Playground - noun: a place where people can play

import Cocoa
import GLKit

var str = "Hello, playground"

func getTheta(vectorA A: GLKVector2, vectorB B: GLKVector2) -> Float{
    
    let delta = GLKVector2Subtract(B, A)
    let r: Float = GLKVector2Length(delta)
//    let alpha: Float = asinf(delta.y/r)
//    let beta: Float = acosf(delta.x/r)
    return asinf(delta.x/r)
}


let A = GLKVector2Make(1, 1)
let B = GLKVector2Make(3, 2)
println(GLKMathRadiansToDegrees( getTheta(vectorA: A, vectorB: B)))

let PI_OVER_180 = 3.144 / 180

GLKMathDegreesToRadians(1)
