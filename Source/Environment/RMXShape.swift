//
//  RMXShape.swift
//  RattleGL
//
//  Created by Max Bilbow on 13/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import GLKit
#if OSX
import OpenGL
import GLUT
    #endif
enum ShapeType: Int32 { case NULL = 0, CUBE = 1 , PLANE = 2, SPHERE = 3 }

#if SceneKit
    import SceneKit
    #else
    protocol SCNGeometry{}
#endif

class RMXShape : SCNGeometry, RMXNodeProperty {
    var owner: RMXNode! = nil
    var world: RMSWorld {
        return self.owner.world
    }
    var type: ShapeType = .NULL
    
    var scaleMatrix: GLKMatrix4 {
        let radius = Float(self.owner.radius)
        return GLKMatrix4MakeScale(radius,radius,radius)
    }
        
    var rotationMatrix: GLKMatrix4 {
        #if SceneKit
        return SCNMatrix4ToGLKMatrix4(self.owner.body!.orientation)
        #else
        return self.owner.body!.orientation
        #endif
    }
        
    var translationMatrix: GLKMatrix4 {
        var p = self.owner.position
        if self.owner.parent != nil {
            p += self.owner.parent!.position
        }
        
        return GLKMatrix4MakeTranslation(Float(p.x), Float(p.y), Float(p.z))
    }
    
//    var rotation: RMFloat {
//        return self.parent.rotation
//    }
        
    var radius: RMFloat {
        return self.owner.radius
    }
    
    var color: GLKVector4 = GLKVector4Make(0.5,0.5,0.5,1)
    var isLight: Bool = false
    var gl_light_type, gl_light: Int32
    var isVisible: Bool = true
    var brigtness: RMFloat = 1
    
    init(_ owner: RMXNode? = nil, type: ShapeType = .NULL ) {
        self.gl_light_type = GL_POSITION
        self.gl_light = GL_LIGHT0
        self.type = type
        self.owner = owner
        #if SceneKit
        super.init()
        #endif
    }
    #if SceneKit
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    #endif
    
    private var _rotation: RMFloat = 0
    func makeAsSun(rDist: RMFloat = 1000, isRotating: Bool = true, rAxis: RMXVector3 = RMXVector3Make(0,0,1)) -> RMXNode {
        self.type = .SPHERE
        self.isVisible = true
        self.owner.rotationCenterDistance = rDist
        self.owner.isRotating = isRotating
        self.owner.setRotationSpeed(speed: 1)
        self.color = GLKVector4Make(1, 1, 1, 1.0)
        self.owner.hasGravity = false
        self.isLight = true
        self.owner.rAxis = rAxis
        self._rotation = PI / 4
        return self.owner
    }
        func animate(){
            
        }
}