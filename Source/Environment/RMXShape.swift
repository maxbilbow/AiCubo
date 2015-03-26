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

class RMXShape {
//    enum Type: Int { case NULL = 0, CUBE = 1 , PLANE = 2, SPHERE = 3}
    var type: ShapeType = .NULL
    
    var scaleMatrix: GLKMatrix4 {
        return GLKMatrix4MakeScale(self.radius,self.radius,self.radius)
    }
    var rotationMatrix: GLKMatrix4 {
        return GLKMatrix4MakeRotation(self.rotation, self.parent.rAxis.x,self.parent.rAxis.y,self.parent.rAxis.z)
    }
//    var geometry: RMSGeometry!
    var translationMatrix: GLKMatrix4 {
        let p = self.parent.position
        return GLKMatrix4MakeTranslation(p.x, p.y, p.z)
    }
    
    var rotation: Float {
        return self.parent.rotation
    }
    var radius: Float {
        return self.parent.body.radius
    }
    var color: GLKVector4 = GLKVector4Make(0,0,0,0)
    var isLight: Bool = false
    var gl_light_type, gl_light: Int32
    var render: ((Float) -> Void)?//UnsafeMutablePointer<(Float) -> Void> = UnsafeMutablePointer<(Float) -> Void>()//.alloc(sizeof(<(Float) -> Void>))
    var parent: RMSParticle!
    var world: RMSWorld?
    var visible: Bool = true;
    //var shine: CFunctionPointer<(Int32, Int32, [Float])->Void>
    var brigtness: Float = 1
    
    init(parent: RMSParticle?, world: RMSWorld?, type: ShapeType = .NULL )    {
        self.parent = parent!
        self.world = world
        self.gl_light_type = GL_POSITION
        self.gl_light = GL_LIGHT0
        self.type = type
    }
    
   
//    class func Shape(parent: RMSParticle!, world: RMXWorld!, render: CFunctionPointer<(Float)->Void> = nil) -> RMXShape {
//        let s = RMXShape(parent: parent, world: world)
//        s.render = render
//        return s
//    }
    
    func makeAsSun(rDist: Float = 1000, isRotating: Bool = true){
        self.parent.rotationCenterDistance = rDist
        self.parent.isRotating = isRotating
        self.parent.setRotationSpeed(speed: 1)
        self.parent.setHasGravity(false)
        self.isLight = true
        
    }
    
    func draw() {
        if !self.visible { return }
        if self.type != .NULL {
            let v = self.parent.body.position
            
            let r: CGFloat = CGFloat(self.parent.body.radius)
            //self.node!.scale = SCNVector3(x: r,y: r,z: r)
            
        } else if RMX.usingDepreciated {
//            if self.isLight {
//                RMXGLShine(self.gl_light, self.type, GLKVector4MakeWithVector3(self.parent.body.position, 1))
//            }
//            if self.render != nil {
//                glPushMatrix();
//                RMXGLTranslate(parent.anchor)
//                RMXGLTranslate(parent.body.position)
//                self.setMaterial()
//    //            RMXGLRender(self.render, Float(self.parent.body.radius))
//                self.render!(Float(self.parent.body.radius))
//                self.unsetMaterial()
//                glPopMatrix();
//            }
        }
    
    }
/*
    private func setMaterial()
    {
        if self.isLight {
            RMXGLMaterialfv(GL_FRONT, GL_EMISSION, self.color)
        }
        
            RMXGLMaterialfv(GL_FRONT, GL_SPECULAR, self.color)
            RMXGLMaterialfv(GL_FRONT, GL_DIFFUSE, self.color)
        
    }
    
    private func unsetMaterial()    {
        let nill = GLKVector4Make( 0,0,0,0);
        RMXGLMaterialfv(GL_FRONT, GL_EMISSION, nill);
        RMXGLMaterialfv(GL_FRONT, GL_SPECULAR, nill);
        RMXGLMaterialfv(GL_FRONT, GL_DIFFUSE, nill);
    }
*/
    
    func getColorfv() -> GLKVector4 {
        return self.color
    }
    
    func setRenderer(render: (Float)->()) {
        
//       self.render.put(render
        self.render = render
    }
    func setColorfv(c: [Float]) {
        self.color = GLKVector4Make(c[0],c[1],c[2],c[3])
        
    }
    
}