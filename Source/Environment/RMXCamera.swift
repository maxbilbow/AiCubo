//
//  RMXCamera.swift
//  RattleGL
//
//  Created by Max Bilbow on 13/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import GLKit

@objc public class RMXCamera {
    
    var world: RMSWorld?
    var pov: RMSParticle?
    var near, far, fieldOfView: Float
    var facingVector: GLKVector3 = RMXVector3Zero
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
    init(world: RMSWorld?, pov: RMSParticle! = nil, viewSize: (Float,Float) = (1280, 750), farPane far: Float = 10000 ){
        self.world = world ?? pov as! RMSWorld
        self.far = far
        self.near = 1
        self.fieldOfView = 65.0
        self.pov = pov ?? world?.activeSprite
        self.viewHeight = viewSize.1
        self.viewWidth = viewSize.0
    }
    
    public var eye: GLKVector3 {
        return self.position
    
    }
    
    public var center: GLKVector3{
        return GLKVector3Add(self.body.forwardVector,self.position)
    }
    
    private let simple = false
    public var up: GLKVector3 {
        
        if simple {
            return GLKVector3Make(0,1,0)
        } else {
            return self.body.upVector
        }
    }
    
    
    func updateView(){
        if RMX.usingDepreciated {
            //RMXGLMakeLookAt(self)
        } else {
            fatalError("Camera Error in \(__FILE__)")
        }

    }
    var viewDescription: String {
        let eye = self.eye; let center = self.center; let up = self.up
        return "\n      EYE \(eye.print)\n   CENTRE \(center.print)\n      UP: \(up.print)\n"
    }
    

    
    func makePerspective(width: Int32, height:Int32, inout effect: GLKBaseEffect?){
        if RMX.usingDepreciated {
            //RMXGLMakePerspective(self.fieldOfView, Float(width) / Float(height), self.near, self.far)
        } else {
            effect?.transform.projectionMatrix = GLKMatrix4MakePerspective(self.fieldOfView, Float(width) / Float(height), self.near, self.far)
        }
    }
    
    var position: GLKVector3 {
        return self.pov!.position
    }
    
    var body: RMSPhysicsBody {
        return self.pov!.body
    }
    
    var quatarnion: GLKQuaternion {
        return GLKQuaternionMakeWithMatrix3(self.body.orientation)
    }
    
    var orientation: GLKMatrix3 {
        return self.body.orientation
    }

}