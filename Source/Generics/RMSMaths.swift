//
//  RMSMaths.swift
//  RattleGL
//
//  Created by Max Bilbow on 13/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import GLKit


typealias RMXVector3 = GLKVector3
typealias RMXMatrix3 = GLKMatrix3
typealias RMXMatrix4 = GLKMatrix4
var RMXVector3Zero: GLKVector3 {
    return GLKVector3Make(0,0,0)
}

var RMXVector4Zero: GLKVector4 {
    return GLKVector4Make(0,0,0,0)
}

func RMXVector3SetX(inout v: GLKVector3, x: Float){
    v = GLKVector3Make(x, v.y, v.z)
}

func RMXVector3SetY(inout v: GLKVector3, y: Float){
    v = GLKVector3Make(v.x, y, v.z)
}

func RMXVector3SetZ(inout v: GLKVector3, z: Float){
    v = GLKVector3Make(v.x, v.y, z)
}

func RMXVector3PlusX(inout v: GLKVector3, x: Float){
    v = GLKVector3Make(v.x + x, v.y, v.z)
}

func RMXVector3PlusY(inout v: GLKVector3, y: Float){
    v = GLKVector3Make(v.x, v.y + y, v.z)
}

func RMXVector3PlusZ(inout v: GLKVector3, z: Float){
    v = GLKVector3Make(v.x, v.y, v.z + z)
}

func + (lhs: GLKVector3, rhs: GLKVector3)->GLKVector3{
    return GLKVector3Add(lhs, rhs)
}

func + (lhs: GLKVector3, rhs: Float)->GLKVector3{
    return GLKVector3AddScalar(lhs, rhs)
}


func - (lhs: GLKVector3, rhs: GLKVector3) -> GLKVector3 {
    return GLKVector3Subtract(lhs, rhs)
}
func += (inout lhs: GLKVector3, rhs: GLKVector3) {
    lhs = GLKVector3Add(lhs, rhs)
}

func * (lhs: GLKVector3, rhs: Float) -> GLKVector3 {
    return GLKVector3MultiplyScalar(lhs, rhs)
}

func * (lhs: GLKVector3, rhs: GLKVector3) -> GLKVector3 {
    return GLKVector3Multiply(lhs, rhs)
}
///Dot Product
func o (lhs: GLKVector3, rhs: GLKVector3) -> Float {
    return GLKVector3DotProduct(lhs, rhs)
}


func + (lhs: GLKMatrix4, rhs: GLKMatrix4) -> GLKMatrix4 {
    return GLKMatrix4Add(lhs,rhs)
}
/*
func RMXGetThetaAndPhi(vectorA A: GLKVector3, vectorB B: GLKVector3) -> (theta:Float, phi:Float){
    let thetaA = GLKVector2Make(A.x, A.z); let thetaB = GLKVector2Make(B.x, B.z)
    let phiA = GLKVector2Make(A.z, A.y); let phiB = GLKVector2Make(B.z, B.y)
    let theta = RMXGetTheta(vectorA: thetaA, vectorB: thetaB)
    let phi = RMXGetTheta(vectorA: phiA, vectorB: phiB)
   // NSLog("theta: \(GLKMathRadiansToDegrees(theta)), phi: \(GLKMathRadiansToDegrees(phi)) ")
    return (theta:-theta, phi:-phi)
}
*/
func RMXGetTheta(vectorA A: GLKVector2, vectorB B: GLKVector2) -> Float{
    let delta = GLKVector2Subtract(B, A)
    let r: Float = GLKVector2Length(delta)
    let alpha: Float = asinf(delta.x/r)
    let beta: Float = acosf(delta.y/r)
//    let theta: Float = GLKMathRadiansToDegrees(atanf(delta.x/delta.y))
    let result = alpha * beta >= 0 ? beta : TWO_PI - beta
    return alpha.isNaN ? 0 : result
}

func RMXGetPhi(vectorA A: GLKVector2, vectorB B: GLKVector2) -> Float{
    let delta = GLKVector2Subtract(B, A)
    let r: Float = GLKVector2Length(delta)
    let alpha: Float = asinf(delta.x/r)
    let beta: Float = acosf(delta.y/r)
    //    let theta: Float = GLKMathRadiansToDegrees(atanf(delta.x/delta.y))
    let result = alpha //alpha * beta >= 0 ? beta : TWO_PI - beta
    NSLog("PHI: \(GLKMathRadiansToDegrees(alpha))")
    return alpha.isNaN ? 0 : result
}

func RMXGetTheta(vectorA U: GLKVector3, vectorB V: GLKVector3) -> Float{
    let A = GLKVector2Make(U.x, U.z); let B = GLKVector2Make(V.x, V.z)
    return RMXGetTheta(vectorA: A,vectorB: B)
}



func RMXGetPhi(vectorA U: GLKVector3, vectorB V: GLKVector3) -> Float{
    let A = GLKVector2Make(U.z, U.y); let B = GLKVector2Make(V.z, V.y)
    return RMXGetPhi(vectorA: A,vectorB: B)
}

func x (lhs: GLKVector3, rhs: GLKVector3) -> GLKVector3 {
    return GLKVector3CrossProduct(lhs, rhs)
}

extension GLKMatrix4 {
    /*
    var upVector: RMXVector3 {
        return SCNVector3Make(m12,m22,m32)
    }
    
    var rightVector: RMXVector3 {
        return SCNVector3Make(-m11, -m21, -m31)
    }
    
    var leftVector: RMXVector3 {
        return SCNVector3Make(m11,m21,m31)
    }
    
    var forwardVector: RMXVector3 {
        return SCNVector3Make(m13,m23,m33)
    }
    */
}

extension GLKVector3 {
    var isZero: Bool {
        return (x == 0) && (y == 0) && (z == 0)
    }
    
    var length: Float {
        return GLKVector3Length(self)
    }
    
//    func setX(n: Float){
//        RMXVector3SetX(&self,n)
//    }
//    
//    func setY(n: Float){
//        y = n
//    }
//    
//    func setZ(n: Float){
//        z = n
//    }

}

let PI: Float = 3.14159265358979323846
let TWO_PI: Float = 2 * PI
let PI_OVER_2: Float = PI / 2
let PI_OVER_180: Float = PI / 180

/*
BOOL RMXVector3IsZero(RMXVector3 v)
{
    return ((v.x==0)&&(v.y==0)&&(v.z==0));
}




float RMXGetSpeed(RMXVector3 v){
    float squared = v.x*v.x + v.y*v.y + v.z*v.z;
    return sqrtf(squared);
}


RMXVector3 RMXVector3Abs(RMXVector3 v){
    return SCNVector3Make(fabs(v.x),fabs(v.y),fabs(v.z));
}
/*
SCNPhysicsBody RMXPhyisicsBodyMake() {//float m, float r){
RMXPhysicsBody b;
b.position = SCNVector3Make(0,0,0);
b.velocity = SCNVector3Make(0,0,0);
b.acceleration = SCNVector3Make(0,0,0);
b.forces = SCNVector3Make(0,0,0);
b.orientation = SCNMatrix4Identity;

b.vMatrix = GLKMatrix3Make(
0,0,0,
0,0,0,
0,0,0
);
//    b.angles.theta = b.angles.phi = 0;
//    b.mass = m;
//    b.radius = r;
//    b.dragC = 0.5;
//    b.dragArea = r*r * PI;
return b;
}
*/

func RMXVector3DivideByScalar(v: RMXVector3, s: Float)-> RMXVector3{
    vector_float3 fv = SCNVector3ToFloat3(v);
    for (int i=0; i<3;++i){
        //if (abs(v.v[i]) < 0.01SCNVector3Make)
        fv[i] /= s;
    }
    return SCNVector3FromFloat3(fv);
}

void RMXVector3RoundToZero(GLKVector3 * v, float dp){
    for (int i=0; i<3;++i){
        if (fabsf(v->v[i]) < dp)
        v->v[i] = 0;
    }
}

RMXVector3 RMXVector3Divide(RMXVector3 vTop, RMXVector3 vBottom){
    vector_float3 top = SCNVector3ToFloat3(vTop);
    vector_float3 bottom = SCNVector3ToFloat3(vBottom);
    for (int i=0; i<3;++i){
        top[i] /= bottom[i];
    }
    return SCNVector3FromFloat3(top);
}

RMXVector3 RMXVector3DivideScalar(RMXVector3 top, float bottom){
    vector_float3 fv = SCNVector3ToFloat3(top);
    for (int i=0; i<3;++i){
        fv[i] /= bottom;
    }
    return SCNVector3FromFloat3(fv);
}

RMXVector3 RMXVector3Add(RMXVector3 a ,RMXVector3 b){
    return SCNVector3Make(a.x + b.x,
        a.y + b.y,
        a.z + b.z
    );
}

RMXVector3 RMXVector3Add3(RMXVector3 a ,RMXVector3 b, RMXVector3 c ){
    return SCNVector3Make(a.x + b.x + c.x,
        a.y + b.y + c.y,
        a.z + b.z + c.z);
}



RMXVector3 RMXVector3Add4(RMXVector3 a ,RMXVector3 b, RMXVector3 c , RMXVector3 d){
    return SCNVector3Make(a.x + b.x + c.x + d.x,
        a.y + b.y + c.y + d.y,
        a.z + b.z + c.z + d.z);
}


RMXVector3 RMXVector3AddScalar(RMXVector3 inOut, float s ){
    inOut.x += s;
    inOut.y += s;
    inOut.z += s;
    return inOut;
}

RMXVector3 RMXVector3MultiplyScalarAndSpeed(RMXVector3 v, float s){
    return SCNVector3FromGLKVector3(GLKVector3MultiplyScalar(SCNVector3ToGLKVector3(RMXVector3Abs(v)),s*RMXGetSpeed(v)));
}

RMXVector3 RMXVector3MultiplyScalar(RMXVector3 v, float s){
    return SCNVector3FromGLKVector3(GLKVector3MultiplyScalar(SCNVector3ToGLKVector3(v),s));
}
RMXVector3 RMXVector3Zero(){
    return SCNVector3Make(0,0,0);
}


RMXVector3 RMXMatrix3MultiplyScalarAndSpeed(RMXMatrix3 m, float s){
    GLKVector3 result[3];
    for (int i=0;i<0;++i){
        RMXVector3 v = SCNVector3FromGLKVector3(GLKMatrix3GetRow(m,i));
        result[i] = SCNVector3ToGLKVector3(RMXVector3MultiplyScalarAndSpeed( v , s ));
    }
    
    return SCNVector3FromGLKVector3(GLKMatrix3MultiplyVector3(GLKMatrix3MakeWithRows(result[0],result[1],result[2]),GLKVector3Make(1,1,1)));
}

RMXVector3 RMXMatrix4MultiplyVector3(RMXMatrix4 m, RMXVector3 s){
    return SCNVector3FromGLKVector3(GLKMatrix4MultiplyVector3(SCNMatrix4ToGLKMatrix4(m),SCNVector3ToGLKVector3(s)));
}

RMXMatrix4 RMXMatrix4Transpose(RMXMatrix4 m){
    return SCNMatrix4FromGLKMatrix4(GLKMatrix4Transpose(SCNMatrix4ToGLKMatrix4(m)));
}

RMXVector3 RMXScaler3FromVector3(RMXVector3 x, RMXVector3 y, RMXVector3 z){
    return SCNVector3Make(RMXGetSpeed(x),RMXGetSpeed(y),RMXGetSpeed(z));
}

RMXVector3 RMXScaler3FromMatrix3(RMXMatrix3 m){
    return SCNVector3Make( RMXGetSpeed(SCNVector3FromGLKVector3(GLKMatrix3GetRow(m,0)))
        ,RMXGetSpeed(SCNVector3FromGLKVector3(GLKMatrix3GetRow(m,1)))
        ,RMXGetSpeed(SCNVector3FromGLKVector3(GLKMatrix3GetRow(m,2)))
    );
}

RMXMatrix3 RMXMatrix3RotateAboutY(float theta, RMXMatrix3  matrix){
    
    return GLKMatrix3RotateWithVector3(matrix, theta, GLKVector3Make(0,1,0));
    
}



RMXVector3 RMXMatrix3MultiplyVector3(RMXMatrix4 ml, RMXVector3 vr)
{
    GLKMatrix4 matrixLeft = SCNMatrix4ToGLKMatrix4(ml);
    GLKVector3 vectorRight = SCNVector3ToGLKVector3(vr);
    RMXVector3 v = {
        matrixLeft.m[0] * vectorRight.v[0] + matrixLeft.m[1] * vectorRight.v[0] + matrixLeft.m[0] * vectorRight.v[0],
        matrixLeft.m[3] * vectorRight.v[1] + matrixLeft.m[4] * vectorRight.v[1] + matrixLeft.m[1] * vectorRight.v[2],
        matrixLeft.m[6] * vectorRight.v[2] + matrixLeft.m[7] * vectorRight.v[2] + matrixLeft.m[2] * vectorRight.v[2] };
    return v;
}

void RMXPrintMatrix(GLKMatrix4 m){
    
}
*/