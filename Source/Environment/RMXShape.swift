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



    import SceneKit


class RMXShape : RMXSpriteProperty {
    var owner: RMXSprite! = nil
    var world: RMSWorld {
        return self.owner.world!
    }
    var type: ShapeType = .NULL
    
    var scaleMatrix: GLKMatrix4 {
        let radius = Float(self.owner.radius)
        return GLKMatrix4MakeScale(radius,radius,radius)
    }
        
    var rotationMatrix: GLKMatrix4 {
        return SCNMatrix4ToGLKMatrix4(self.owner.transform)
    }
        
    var translationMatrix: GLKMatrix4 {
        var p = self.owner.position
        if let parent = self.owner.parentSprite {
            p += parent.node.position
        }
        
        return GLKMatrix4MakeTranslation(Float(p.x), Float(p.y), Float(p.z))
    }
    
//    var rotation: RMFloatB {
//        return self.parent.rotation
//    }
        
    var radius: RMFloatB {
        return self.owner.radius
    }
    
    var color: GLKVector4 = GLKVector4Make(1.0,1.0,1.0,1)
    var isLight: Bool = false
    var gl_light_type, gl_light: Int32
    var isVisible: Bool = true
    var brigtness: RMFloatB = 1
    
    init(_ owner: RMXSprite? = nil, type: ShapeType = .NULL ) {
        self.gl_light_type = GL_POSITION
        self.gl_light = GL_LIGHT0
        self.type = type
        self.owner = owner
        
    }
    #if SceneKit
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    #endif
//    
//    func setColor(col: NSColor) {
//        self.firstMaterial?.diffuse.contents = col
//    }
    
    /*
    private var _rotation: RMFloatB = 0
    func makeAsSun(rDist: RMFloatB = 1000, isRotating: Bool = true, rAxis: RMXVector3 = RMXVector3Make(0,0,1)) -> RMXSprite {
        self.type = .SPHERE
        #if SceneKit
        self.owner.geometry = RMXArt.SPHERE
        #endif
        self.isVisible = true
        self.owner.rotationCenterDistance = rDist
        self.owner.isRotating = isRotating
        self.owner.setRotationSpeed(speed: 1)
        self.owner.hasGravity = false
        self.isLight = true
        self.owner.setColor(RMXVector4Make(1, 1, 1, 1.0))
        self.owner.rAxis = rAxis
        self._rotation = PI / 4
        return self.owner
    } */
        func animate(){
            
        }

    #if SceneKit
    static let CUBE = SCNBox(
        width: 1.0,
        height:1.0,
        length:1.0,
        chamferRadius:0.0)
    static let PLANE = SCNPlane(
        width: 1.0,
        height:1.0
    )
    
    static let FLOOR = SCNFloor()
    
    static let SPHERE = SCNSphere(radius:1)
    static let CYLINDER = SCNCylinder(radius:1, height:1.0)
    
    static let greenMat: SCNMaterial = SPHERE.firstMaterial!.copy() as! SCNMaterial
    static let redMat: SCNMaterial = SPHERE.firstMaterial!.copy() as! SCNMaterial
    static let blueMat: SCNMaterial = SPHERE.firstMaterial!.copy() as! SCNMaterial
    
    #endif

    
    
}


