// Playground - noun: a place where people can play

import Cocoa
import GLKit

var str = "Hello, playground"

func getTheta(vectorA A: GLKVector2, vectorB B: GLKVector2) -> Float{
    
    let delta = GLKVector2Subtract(B, A)
    let r: Float = GLKVector2Length(delta)
    let alpha: Float = GLKMathRadiansToDegrees(asinf(delta.x/r))
    let beta: Float = GLKMathRadiansToDegrees(acosf(delta.y/r))
    let theta: Float = GLKMathRadiansToDegrees(atanf(delta.x/delta.y))
    let result = alpha * beta >= 0 ? beta : 360 - beta
    
    return alpha.isNaN ? 0 : result
}


let A = GLKVector2Make(0, 0)
let B = GLKVector2Make(-2, -3)
println(getTheta(vectorA: A, vectorB: B))

let PI_OVER_180 = 3.144 / 180

GLKMathDegreesToRadians(1)


func RMXGetTheta(vectorA A: GLKVector2, vectorB B: GLKVector2) -> Float{
    //
    let delta = GLKVector2Subtract(B, A)
    let r: Float = GLKVector2Length(delta)
    //        let alpha: Float = asinf(delta.y/r)
    //        let beta: Float = acosf(delta.x/r)
    //    return alpha
    
    let adj = GLKVector2Length(A)
    let opp = GLKVector2Length(B)
    let theta = acos(opp/adj)
    return theta
}
println(GLKMathRadiansToDegrees( RMXGetTheta(vectorA: A, vectorB: B)))