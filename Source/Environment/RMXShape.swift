//
//  RMXShape.swift
//  RattleGL
//
//  Created by Max Bilbow on 13/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import GLKit
#if OPENGL_OSX
import OpenGL
import GLUT
    #endif

class RMXShape : RMSNodeProperty {

    var type: ShapeType = .NULL
    
    var scaleMatrix: GLKMatrix4 {
        return GLKMatrix4MakeScale(self.radius,self.radius,self.radius)
    }
    var rotationMatrix: GLKMatrix4 {
        return self.parent.body.orientation // + self.parent.parent!.body.orientation //GLKMatrix4MakeRotation(self.rotation, self.parent.rAxis.x,self.parent.rAxis.y,self.parent.rAxis.z)
    }
//    var geometry: RMSGeometry!
    var translationMatrix: GLKMatrix4 {
        var p = self.parent.position
        if self.parent.parent != nil {
            p += self.parent.parent!.position
        }
        return GLKMatrix4MakeTranslation(p.x, p.y, p.z)
    }
    
    var rotation: Float {
        return self.parent.rotation
    }
    var radius: Float {
        return self.parent.body.radius
    }
    
    var color: GLKVector4 = GLKVector4Make(0.5,0.5,0.5,1)
    var isLight: Bool = false
    var gl_light_type, gl_light: Int32
    var isVisible: Bool = true;
    var brigtness: Float = 1
    
    init(_ parent: RMSParticle, type: ShapeType = .NULL )    {
        self.gl_light_type = GL_POSITION
        self.gl_light = GL_LIGHT0
        self.type = type
        super.init(parent)
    }
    
    
    func makeAsSun(rDist: Float = 1000, isRotating: Bool = true, rAxis: GLKVector3 = GLKVector3Make(0,0,1)) -> RMSParticle{
        self.type = .SPHERE
        self.isVisible = true
        self.parent.rotationCenterDistance = rDist
        self.parent.isRotating = isRotating
        self.parent.setRotationSpeed(speed: 1)
        self.color = GLKVector4Make(1, 1, 1, 1.0)
        self.parent.setHasGravity(false)
        self.isLight = true
        self.parent.rAxis = rAxis
        self.parent.rotation = PI / 4
        return self.parent
    }
    
}