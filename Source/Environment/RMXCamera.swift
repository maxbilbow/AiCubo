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
    
    lazy var pov: RMXNode? = self.parent
    var parent: RMXNode! = nil
    var world: RMSWorld {
        return self.pov!.world
    }
    
    var near, far, fieldOfView: Float
    var facingVector: GLKVector3 = GLKVector3Zero
    var effect: GLKBaseEffect! = nil

    var aspectRatio: Float  {
        return self.viewWidth / self.viewHeight
    }
    
    var viewWidth: Float
    var viewHeight: Float

    var projectionMatrix: GLKMatrix4 {
        return GLKMatrix4MakePerspective(GLKMathDegreesToRadians(self.fieldOfView), self.aspectRatio, self.near, self.far)
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
    init(_ parent: RMXNode, viewSize: (Float,Float) = (1280, 750), farPane far: Float = 10000 ){
        self.far = far
        self.near = 1
        self.fieldOfView = 65.0
        self.viewHeight = viewSize.1
        self.viewWidth = viewSize.0
        self.parent = parent
        #if SceneKit
        super.init()
        #endif
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        let r = self.pov!.body!.forwardVector + self.pov!.position
        #if SceneKit
            let v = SCNVector3ToGLKVector3(r)
            #else
            let v = r
        #endif
        return v
    }
    
    private let simple = false
    var up: GLKVector3 {
        if simple {
            return GLKVector3Make(0,1,0)
        } else {
            let r = self.pov!.body!.upVector
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
    

    
    func makePerspective(width: Int32, height:Int32, inout effect: GLKBaseEffect?){
        if RMX.usingDepreciated {
            #if OPENGL_OSX
            RMXGLMakePerspective(self.fieldOfView, Float(width) / Float(height), self.near, self.far)
            #endif
        } else {
            effect?.transform.projectionMatrix = GLKMatrix4MakePerspective(self.fieldOfView, Float(width) / Float(height), self.near, self.far)
        }
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