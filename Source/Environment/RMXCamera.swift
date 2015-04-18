//
//  RMXCamera.swift
//  RattleGL
//
//  Created by Max Bilbow on 13/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import GLKit

import SceneKit
class RMXCamera : SCNCamera {
    
    var pov: SCNNode? { return self.observer.node }
    var observer: RMXSprite! {
        return self.world.observer
    }
    var world: RMSWorld! = nil
    
    var facingVector: GLKVector3 = GLKVector3Zero

    var aspectRatio: Float  {
        return self.viewWidth / self.viewHeight
    }
//    override func projectionTransform() -> RMXMatrix4 {
//        let eye = self.eye; let center = self.center; let up = self.up
//        RMXLog(super.projectionTransform().print)
//        return SCNMatrix4FromGLKMatrix4(self.modelViewMatrix)
//            
//      
//    }
    var viewWidth: Float = 1280
    var viewHeight: Float = 750
    var modelViewMatrix: GLKMatrix4 {
        let eye = self.eye; let center = self.center; let up = self.up
        return GLKMatrix4MakeLookAt(
            eye.x,      eye.y,      eye.z,
            center.x,   center.y,   center.z,
            up.x,       up.y,       up.z)
    }

    
   
    
    var projectionMatrix: GLKMatrix4 {
        return GLKMatrix4MakePerspective(GLKMathDegreesToRadians(Float(self.yFov)), self.aspectRatio, Float(self.zNear), Float(self.zFar))
    }
    
    func getProjectionMatrix(width: Float, height: Float) -> GLKMatrix4 {
        self.viewWidth = width
        self.viewHeight = height
        return self.projectionMatrix
    }
    
    
    func makePerspective(width: Int32, height:Int32, inout effect: GLKBaseEffect?){
        if RMX.usingDepreciated {
            #if OPENGL_OSX
            RMXGLMakePerspective(self.yFov, Float(width) / Float(height), self.zNear, self.zFar)
            #endif
        }
    }
    

    
    init(_ world: RMSWorld, viewSize: (Float,Float) = (1280, 750)){
        self.viewHeight = viewSize.1
        self.viewWidth = viewSize.0
        self.world = world
        super.init()
        self.initCam()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initCam()
    }
    override init(){
        super.init()
        self.initCam()
    }

    
    private func initCam(){
        self.zNear = 0.1
        self.zFar = 10000
        self.yFov = 65
        self.xFov = 65
        self.focalBlurRadius = 0.05
        self.aperture = 0.005
        self.focalDistance = 0.001
    }
    var eye: GLKVector3 {
        let v = SCNVector3ToGLKVector3(self.pov!.position)
        return v
    }
    
    var center: GLKVector3{
        let r = self.observer.forwardVector + self.pov!.position
        let v = SCNVector3ToGLKVector3(r)
        return v
    }
    
    private let simple = false
    var up: GLKVector3 {
        if simple {
            return GLKVector3Make(0,1,0)
        } else {
            let r = self.observer.upVector
            let v = SCNVector3ToGLKVector3(r)
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