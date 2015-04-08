//
//  RMXCamera.swift
//  RattleGL
//
//  Created by Max Bilbow on 13/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import GLKit
#if SceneKit
import SceneKit
    #else
    protocol SCNCamera {}
    #endif
class RMXCamera : SCNCamera, RMXNodeProperty {
    
    lazy var pov: RMXNode? = self.owner
    var owner: RMXNode! = nil
    var world: RMSWorld {
        return self.pov!.world
    }
    var facingVector: GLKVector3 = GLKVector3Zero

    var aspectRatio: Float  {
        return self.viewWidth / self.viewHeight
    }
    
    var viewWidth: Float = 1280
    var viewHeight: Float = 750
    
    #if !SceneKit
    var zNear:Float = 1
    var zFar: Float = 10000
    var yFov: Float = 65.0
    var xFov: Float = 65.0
   

    var projectionMatrix: GLKMatrix4 {
        return GLKMatrix4MakePerspective(GLKMathDegreesToRadians(self.yFov), self.aspectRatio, self.zNear, self.zFar)
    }
    
    func getProjectionMatrix(width: Float, height: Float) -> GLKMatrix4 {
        self.viewWidth = width
        self.viewHeight = height
        return self.projectionMatrix
    }
    var modelViewMatrix: GLKMatrix4 {
        let eye = self.eye; let center = self.center; let up = self.up
        return GLKMatrix4MakeLookAt(
            eye.x,      eye.y,      eye.z,
            center.x,   center.y,   center.z,
            up.x,       up.y,       up.z)
    }
    
    func makePerspective(width: Int32, height:Int32, inout effect: GLKBaseEffect?){
        if RMX.usingDepreciated {
            #if OPENGL_OSX
            RMXGLMakePerspective(self.yFov, Float(width) / Float(height), self.zNear, self.zFar)
            #endif
        } else {
            effect?.transform.projectionMatrix = GLKMatrix4MakePerspective(self.yFov, Float(width) / Float(height), self.zNear, self.zFar)
        }
    }
    
    #endif
    
    init(_ owner: RMXNode, viewSize: (Float,Float) = (1280, 750)){
        self.viewHeight = viewSize.1
        self.viewWidth = viewSize.0
        self.owner = owner
        #if SceneKit
        super.init()
        #endif
        self.initCam()
    }
    #if SceneKit
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initCam()
    }
    override init(){
        super.init()
        self.initCam()
    }
    #endif
    
    private func initCam(){
        self.zNear = 0.1
        self.zFar = 10000
        self.yFov = 65
        self.xFov = 65
        
    }
    var eye: GLKVector3 {
        #if SceneKit
            let v = SCNVector3ToGLKVector3(self.pov!.position)
            #else
            let v = self.pov!.position
        #endif
        return v
    
    }
    
    var center: GLKVector3{
        let r = self.pov!.forwardVector + self.pov!.position
        #if SceneKit
            let v = SCNVector3ToGLKVector3(r)
            #else
            let v = r
        #endif
        return v
    }
    
    private let simple = true
    var up: GLKVector3 {
        if simple {
            return GLKVector3Make(0,1,0)
        } else {
            let r = self.pov!.upVector
            #if SceneKit
                let v = SCNVector3ToGLKVector3(r)
                #else
                let v = r
            #endif
            return v
        }
    }
    
    
    var viewDescription: String {
        let eye = self.eye; let center = self.center; let up = self.up
        return "\n      EYE \(eye.print)\n   CENTRE \(center.print)\n      UP: \(up.print)\n"
    }
    

    
    
        
    /*
    var quatarnion: GLKQuaternion {
        return GLKQuaternionMakeWithMatrix4(self.pov.body!.orientation)
    }
    
    var orientation: GLKMatrix4 {
        return self.pov.body!.orientation
    }
*/
    
    func animate() {
        
    }

}