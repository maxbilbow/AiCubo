//
//  RMSMaths.swift
//  RattleGL
//
//  Created by Max Bilbow on 13/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation

import GLKit
import SceneKit
//#if !SceneKit
//    
//typealias RMXVector3 = GLKVector3
//    typealias RMXVector4 = GLKVector4
//typealias RMXMatrix3 = GLKMatrix3
//typealias RMXMatrix4 = GLKMatrix4
//    typealias RMFloat = Float
//    typealias RMFloatB = Float
//    #else

    typealias RMXVector3 = SCNVector3
    typealias RMXVector4 = SCNVector4
    typealias RMXMatrix4 = SCNMatrix4
    typealias RMFloat = CGFloat
    #if OSX
        typealias RMFloatB = CGFloat
        #elseif iOS
        typealias RMFloatB = Float
        #endif
//#endif

    //#if true
        let RMXVector3Zero = SCNVector3Zero
        let RMXVector4Zero = SCNVector4Zero
        let RMXMatrix4Identity = SCNMatrix4Identity
        let RMXMatrix4Zero = SCNMatrix4MakeScale(0,0,0)
  //      #else
//        let RMXVector3Zero = GLKVector3Zero
//        let RMXVector4Zero = GLKVector4Zero
//        let RMXMatrix4Identity = GLKMatrix4Identity
//        let RMXMatrix4Zero = GLKMatrix4MakeScale(0,0,0)
//    #endif

let GLKVector3Zero = GLKVector3Make(0,0,0)
let GLKVector4Zero = GLKVector4Make(0,0,0,0)

func RMXVector3Make(x:RMFloatB, y:RMFloatB, z:RMFloatB) -> RMXVector3 {
    #if true
       return SCNVector3Make(x,y,z)
        #else
        return GLKVector3Make(x,y,z)
    #endif
}

func RMXVector4Make(x:RMFloatB, y:RMFloatB, z:RMFloatB, w: RMFloatB) -> RMXVector4 {
    #if true
        return SCNVector4Make(x,y,z,w)
        #else
        return GLKVector4Make(x,y,z,w)
    #endif
}

func RMXVector3Length(v: RMXVector3) -> RMFloatB {
    #if true
        return RMFloatB(GLKVector3Length(SCNVector3ToGLKVector3(v)))
        #else
        return GLKVector3Length(v)
    #endif
}

func RMXVector3SetX(inout v: RMXVector3, x: RMFloatB){
    #if true
        v.x = x
        #else
    v = GLKVector3Make(x, v.y, v.z)
    #endif
}

func RMXVector3SetY(inout v: RMXVector3, y: RMFloatB){
    #if true
        v.y = y
        #else
    v = GLKVector3Make(v.x, y, v.z)
    #endif
}


func RMXMatrix4SetY(inout m: RMXMatrix4, y: RMFloatB){
    #if true
        m.m42 = y
        #else
        let r = GLKMatrix4GetRow(m,3)
        m = GLKMatrix4MakeWithRows(
            GLKMatrix4GetRow(m,0),
            GLKMatrix4GetRow(m,1),
            GLKMatrix4GetRow(m,2),
            GLKVector4Make(r.x,y,r.z,1)
            )
    #endif
}

func RMXVector3SetZ(inout v: RMXVector3, z: RMFloatB){
    #if true
        v.z = z
        #else
    v = GLKVector3Make(v.x, v.y, z)
    #endif
}

func RMXVector3PlusX(inout v: RMXVector3, x: RMFloatB){
    #if true
        v.x += x
        #else
    v = GLKVector3Make(v.x + x, v.y, v.z)
    #endif
}

func RMXVector3PlusY(inout v: RMXVector3, y: RMFloatB){
    #if true
        v.y += y
        #else
    v = GLKVector3Make(v.x, v.y + y, v.z)
    #endif
}

func RMXVector3PlusZ(inout v: RMXVector3, z: RMFloatB){
    #if true
        v.z += z
        #else
    v = GLKVector3Make(v.x, v.y, v.z + z)
    #endif
}

func RMXMatrix4Transpose(mat: RMXMatrix4)->RMXMatrix4 {
    #if true
        return SCNMatrix4FromGLKMatrix4(GLKMatrix4Transpose(SCNMatrix4ToGLKMatrix4(mat)))
        #else
        return GLKMatrix4Transpose(mat)
    #endif
}

func RMXMatrix4Make(row1: RMXVector3, row2: RMXVector3, row3: RMXVector3, row4: RMXVector3 = RMXVector3Zero) -> RMXMatrix4 {
    #if true
        return SCNMatrix4(
            m11: row1.x, m12: row1.y, m13: row1.z, m14: 0,
            m21: row2.x, m22: row2.y, m23: row2.z, m24: 0,
            m31: row3.x, m32: row3.y, m33: row3.z, m34: 0,
            m41: row4.x, m42: row4.y, m43: row4.z, m44: 1
            )
    #else
        return GLKMatrix4MakeWithColumns(
            GLKVector4MakeWithVector3(row1, 0),
            GLKVector4MakeWithVector3(row2, 0),
            GLKVector4MakeWithVector3(row3, 0),
            GLKVector4MakeWithVector3(row4, 1)
        )
    #endif
}

func RMXMatrix4MultiplyVector3(mat: RMXMatrix4, v: RMXVector3) -> RMXVector3{
    #if true
        return SCNVector3FromGLKVector3(GLKMatrix4MultiplyVector3(GLKMatrix4Transpose(SCNMatrix4ToGLKMatrix4(mat)),SCNVector3ToGLKVector3(v)))
        #else
        return GLKMatrix4MultiplyVector3(GLKMatrix4Transpose(mat), v)
    #endif
}
func RMXVector3Divide(n:RMXVector3, d: RMXVector3) -> RMXVector3 {
    #if true
    return SCNVector3FromGLKVector3(GLKVector3Divide(SCNVector3ToGLKVector3(n),SCNVector3ToGLKVector3(d)))
        #else
    return GLKVector3Divide(n, d)
    #endif
}

func + (lhs: SCNVector3, rhs: SCNVector3)->SCNVector3{
    return SCNVector3Make(
        lhs.x + rhs.x,
        lhs.y + rhs.y,
        lhs.z + rhs.z
    )
}


func + (lhs: GLKVector3, rhs: Float)->GLKVector3{
    return GLKVector3AddScalar(lhs, rhs)
}

func + (lhs: GLKVector3, rhs: GLKVector3)->GLKVector3{
    return GLKVector3Add(lhs, rhs)
}

func + (lhs: GLKVector3, rhs: SCNVector3)->SCNVector3{
    return SCNVector3FromGLKVector3(lhs) + rhs
}

func + (lhs: SCNVector3, rhs: GLKVector3)->SCNVector3 {
    return lhs + SCNVector3FromGLKVector3(rhs)
}

func - (lhs: GLKVector3, rhs: GLKVector3) -> GLKVector3 {
    return GLKVector3Subtract(lhs, rhs)
}
func += (inout lhs: GLKVector3, rhs: GLKVector3) {
    lhs = GLKVector3Add(lhs, rhs)
}

func += (inout lhs: GLKVector3, rhs: SCNVector3) {
    lhs = GLKVector3Add(lhs, SCNVector3ToGLKVector3(rhs))
}

func += (inout lhs: SCNVector3, rhs: GLKVector3) {
    #if iOS
        lhs.x += Float(rhs.x)
        lhs.y += Float(rhs.y)
        lhs.z += Float(rhs.z)
    #else
        lhs.x += CGFloat(rhs.x)
        lhs.y += CGFloat(rhs.y)
        lhs.z += CGFloat(rhs.z)
    #endif
}

func += (inout lhs: SCNVector3, rhs: SCNVector3) {
        lhs.x += rhs.x
        lhs.y += rhs.y
        lhs.z += rhs.z
}

func * (lhs: RMXVector3, rhs: RMFloatB) -> RMXVector3 {
    return RMXVector3MultiplyScalar(lhs, rhs)
}

func *= (inout lhs: RMXVector3, rhs: RMFloatB) {
    lhs = RMXVector3MultiplyScalar(lhs, rhs)
}

func * (inout lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
    return SCNVector3FromGLKVector3(GLKVector3Multiply(SCNVector3ToGLKVector3(lhs), SCNVector3ToGLKVector3(rhs)))
}

func *= (inout lhs: SCNVector3, rhs: SCNVector3) {
    lhs = lhs * rhs
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

func + (lhs: SCNMatrix4, rhs: SCNMatrix4) -> SCNMatrix4 {
    return SCNMatrix4FromGLKMatrix4(GLKMatrix4Add(SCNMatrix4ToGLKMatrix4(lhs),SCNMatrix4ToGLKMatrix4(rhs)))
}

func * (lhs:GLKMatrix4, rhs:GLKMatrix4) -> GLKMatrix4 {
    return GLKMatrix4Multiply(lhs, rhs)
}

func * (lhs:SCNMatrix4, rhs:SCNMatrix4) -> SCNMatrix4 {
    return SCNMatrix4Mult(lhs,rhs)
}

func *= (inout lhs:GLKMatrix4, rhs:GLKMatrix4) {
    lhs = GLKMatrix4Multiply(rhs, lhs)
}

func *= (inout lhs:SCNMatrix4, rhs:SCNMatrix4) {
    lhs = SCNMatrix4Mult(rhs,lhs)
}

func RMXVector3Distance(a:RMXVector3,b:RMXVector3)->RMFloatB {
    #if true
        let A = SCNVector3ToGLKVector3(a); let B = SCNVector3ToGLKVector3(b)
        return RMFloatB(GLKVector3Distance(A,B))
        #else
        return GLKVector3Distance(a,b)
    #endif
}
func RMXMatrix4RotateY(matrix: RMXMatrix4, theta: RMFloatB) -> RMXMatrix4 {
    return RMXMatrix4Rotate(matrix, theta,0,1,0)
}
func RMXMatrix4Rotate(mat: RMXMatrix4, angle: RMFloatB, x: RMFloatB, y: RMFloatB, z: RMFloatB)-> RMXMatrix4{
    #if true
        return SCNMatrix4Rotate(mat, angle, x, y, z)
        #else
        return GLKMatrix4Rotate(mat, angle, x, y, z)
    #endif
}

func RMXMatrix4MakeRotation(radians: RMFloatB,v: RMXVector3) -> RMXMatrix4 {
    #if true
        return SCNMatrix4MakeRotation(radians, v.x,v.y,v.z)
        #else
        return GLKMatrix4MakeRotation(radians, v.x,v.y,v.z)
    #endif
}

func RMXMatrix4RotateWithVector3(mat: RMXMatrix4, angle: RMFloatB, vector: RMXVector3) -> RMXMatrix4{
    #if true
        return SCNMatrix4Rotate(mat, angle, vector.x, vector.y, vector.z)
        #else
        return GLKMatrix4RotateWithVector3(mat, angle, vector)
    #endif
}
func RMXMatrix4Translate(mat: RMXMatrix4, v: RMXVector3)-> RMXMatrix4 {
    #if true
        return SCNMatrix4Translate(mat, v.x, v.y, v.z)
        #else
        return GLKMatrix4Translate(mat, v.x, v.y, v.z)
    #endif
}
func SCNMatrix4Normalize(mat: SCNMatrix4) -> SCNMatrix4{
    let mat = GLKMatrix4MakeWithRows(
        GLKVector4Normalize(GLKVector4Make(Float(mat.m11),Float(mat.m12),Float(mat.m13),Float(mat.m14))),
        GLKVector4Normalize(GLKVector4Make(Float(mat.m21),Float(mat.m22),Float(mat.m23),Float(mat.m24))),
        GLKVector4Normalize(GLKVector4Make(Float(mat.m31),Float(mat.m32),Float(mat.m33),Float(mat.m34))),
        GLKVector4Zero
    )
    
    return SCNMatrix4FromGLKMatrix4(mat)
}

func RMXVector3MakeNormal(x:RMFloatB,y:RMFloatB,z:RMFloatB) -> RMXVector3 {
     var v = RMXVector3Make(x,y,z)
    #if true
        v = SCNVector3FromGLKVector3(GLKVector3Normalize(SCNVector3ToGLKVector3(v)))
        #else
        v = GLKVector3Normalize(v)
    #endif
    return v
}
func RMXMatrix4SetPosition(m4:RMXMatrix4, v3 row: RMXVector3) -> RMXMatrix4{
    return RMXMatrix4SetPosition(m4, v4: RMXVector4Make(row.x,row.y,row.z,0))
}

func RMXSetOrientation(m1:RMXMatrix4, orientation m4: RMXMatrix4) -> RMXMatrix4 {
    #if true
        return SCNMatrix4(
        m11: m4.m11, m12: m4.m12, m13: m4.m13, m14: m4.m14,
        m21: m4.m21, m22: m4.m22, m23: m4.m23, m24: m4.m24,
        m31: m4.m31, m32: m4.m32, m33: m4.m33, m34: m4.m34,
        m41: m1.m41, m42: m1.m42, m43: m1.m43, m44: m1.m44
        )
        #else
        return GLKMatrix4Make(
            m4.m00, m4.m01, m4.m02, m4.m03,
            m4.m10, m4.m11, m4.m12, m4.m13,
            m4.m20, m4.m21, m4.m22, m4.m23,
            m1.m31, m1.m31, m1.m32, m1.m33
        )
    #endif
}
func RMXMatrix4SetPosition(m4:RMXMatrix4, v4 row: RMXVector4) -> RMXMatrix4{
    #if true
    return SCNMatrix4(
        m11: m4.m11, m12: m4.m12, m13: m4.m13, m14: m4.m14,
        m21: m4.m21, m22: m4.m22, m23: m4.m23, m24: m4.m24,
        m31: m4.m31, m32: m4.m32, m33: m4.m33, m34: m4.m34,
        m41: row.x,  m42: row.y,  m43: row.z,  m44: row.w
        )
    #else
    return GLKMatrix4Make(
        m4.m00, m4.m01, m4.m02, m4.m03,
        m4.m10, m4.m11, m4.m12, m4.m13,
        m4.m20, m4.m21, m4.m22, m4.m23,
        row.x,  row.y,  row.z,  row.w
        )
    #endif
}
/*
func RMXGetThetaAndPhi(vectorA A: RMXVector3, vectorB B: RMXVector3) -> (theta:Float, phi:Float){
    let thetaA = GLKVector2Make(A.x, A.z); let thetaB = GLKVector2Make(B.x, B.z)
    let phiA = GLKVector2Make(A.z, A.y); let phiB = GLKVector2Make(B.z, B.y)
    let theta = RMXGetTheta(vectorA: thetaA, vectorB: thetaB)
    let phi = RMXGetTheta(vectorA: phiA, vectorB: phiB)
   // NSLog("theta: \(GLKMathRadiansToDegrees(theta)), phi: \(GLKMathRadiansToDegrees(phi)) ")
    return (theta:-theta, phi:-phi)
}
*/

func RMXGetTheta(vectorA A: GLKVector2, vectorB B: GLKVector2) -> RMFloatB{
    let delta = GLKVector2Subtract(B, A)
    let r: Float = GLKVector2Length(delta)
    let alpha: Float = asinf(delta.x/r)
    let beta: Float = acosf(delta.y/r)
//    let theta: Float = GLKMathRadiansToDegrees(atanf(delta.x/delta.y))
    let result = alpha * beta >= 0 ? beta : TWO_PIf - beta
    return RMFloatB(alpha.isNaN ? 0 : result)
}

func RMXGetPhi(vectorA A: GLKVector2, vectorB B: GLKVector2) -> RMFloatB{
    let delta = GLKVector2Subtract(B, A)
    let r: Float = GLKVector2Length(delta)
    let alpha: Float = asinf(delta.x/r)
    let beta: Float = acosf(delta.y/r)
    //    let theta: Float = GLKMathRadiansToDegrees(atanf(delta.x/delta.y))
    let result = alpha //alpha * beta >= 0 ? beta : TWO_PI - beta
    NSLog("PHI: \(GLKMathRadiansToDegrees(alpha))")
    return RMFloatB(alpha.isNaN ? 0 : result)
}

func RMXGetTheta(vectorA U: RMXVector3, vectorB V: RMXVector3) -> RMFloatB{
    let A = GLKVector2Make(Float(U.x), Float(U.z)); let B = GLKVector2Make(Float(V.x), Float(V.z))
    return RMXGetTheta(vectorA: A,vectorB: B)
}



func RMXGetPhi(vectorA U: GLKVector3, vectorB V: GLKVector3) -> RMFloatB{
    let A = GLKVector2Make(U.z, U.y); let B = GLKVector2Make(V.z, V.y)
    return RMXGetPhi(vectorA: A,vectorB: B)
}

func x (lhs: GLKVector3, rhs: GLKVector3) -> GLKVector3 {
    return GLKVector3CrossProduct(lhs, rhs)
}

func RMXVector4MakeWithVector3(v: RMXVector3, w: RMFloatB) -> RMXVector4{
    return RMXVector4Make(v.x,v.y,v.z,w)
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

let PI: RMFloatB = 3.14159265358979323846
let PIf = Float(PI)
let TWO_PI: RMFloatB = 2 * PI
let TWO_PIf = Float(TWO_PI)
let PI_OVER_2: RMFloatB = PI / 2
let PI_OVER_2f = Float(PI_OVER_2)
let PI_OVER_180: RMFloatB = PI / 180
let PI_OVER_180f = Float(PI_OVER_180)
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
*/
func RMXVector3MultiplyScalar(v: RMXVector3, s: RMFloatB) -> RMXVector3{
    #if true
    return SCNVector3Make(
        v.x * s,
        v.y * s,
        v.z * s
        )
    #else
        return GLKVector3MultiplyScalar(v, s)
    #endif
}
/*

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