//
//  RMXGLut.swift
//  RattleGL
//
//  Created by Max Bilbow on 15/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
#if SceneKit
    import SceneKit
    #endif

import GLKit

@objc public class RMXGLProxy {
    //let world: RMXWorld? = RMXArt.initializeTestingEnvironment()
    static var callbacks: [()->Void] = Array<()->Void>()
    static var world: RMSWorld! = nil
    static var effect: GLKBaseEffect? = GLKBaseEffect()
    static var actions: RMSActionProcessor! = nil
    
    static var activeCamera: RMXCamera {
        return self.world.activeCamera
    }
    
    static var mouse: RMXMouse {
        return self.activeSprite.mouse
    }
    
    static var mouseX: Int32 {
        return self.mouse.x
    }
    
    static var mouseY: Int32 {
        return self.mouse.y
    }
    
    static var itemBody: RMSPhysicsBody? {
        return self.activeSprite.actions.item?.body
    }
    
    static var activeSprite: RMXNode {
        return self.world.activeSprite
    }
    
    class func calibrateView(x: Int32, y: Int32) {
        self.mouse.calibrateView(x, y: y)
    }
    
    class func mouseMotion(x: Int32, y:Int32) {
        if self.mouse.hasFocus {
            self.mouse.mouse2view(x, y:y, speed: PI_OVER_180)
        }
        else {
            self.mouse.setMousePos(x, y:y)
        }
    }
//    var displayPtr: CFunctionPointer<(Void)->Void>?
//    var reshapePtr: CFunctionPointer<(Int32, Int32)->Void>?
    
    class func animateScene() {
        #if OPENGL_OSX
        RepeatedKeys()
        #endif
        self.world.animate()
    }
    
    class func performAction(action: String){
        self.actions.movement(action, speed: 0, point: [])
    }
    
    class func performActionWithSpeed(speed: Float, action: String){
        self.actions.movement(action, speed: RMFloat(speed), point: [])
    }


    class func performActionWith(point: [RMFloat], action: String!, speed: Float){
        self.actions.movement(action, speed: RMFloat(speed), point: point)
    }

    
    class func initialize(world: RMSWorld, callbacks: ()->Void ...){
        self.world = world
        for function in self.callbacks {
            self.callbacks.append(function)
        }
    }
    
    
//initializeFrom(RMXGLProxy.reshape)
        
        
    class func reshape(width: Int32, height: Int32) -> Void {
        //[window setSize:width h:height]; //glutGet(GLUT_WINDOW_WIDTH);
        // window.height = height;// glutGet(GLUT_WINDOW_HEIGHT);
        
        if RMX.usingDepreciated {
            glViewport(0, 0, width, height)
            glMatrixMode(GLenum(GL_PROJECTION))
            glLoadIdentity()
            self.activeCamera.makePerspective(width, height: height,effect: &self.effect)
            glMatrixMode(GLenum(GL_MODELVIEW))
        } else {
            self.activeCamera.viewHeight = Float(height)
            self.activeCamera.viewWidth = Float(width)
        }
        
        
    }
    static var drawNextFrame = 1
    static let framerate = 0
    class func display () -> Void {
        
        for function in self.callbacks {
            function()
        }
        self.animateScene()
        
        
        glClear(GLenum(GL_COLOR_BUFFER_BIT) | GLenum(GL_DEPTH_BUFFER_BIT))
        glClearColor(0.8, 0.85, 1.8, 0.0)

        glLoadIdentity(); // Load the Identity Matrix to reset our drawing locations
        #if OPENGL_OSX
        RMXGLMakeLookAt(self.activeCamera.eye, self.activeCamera.center, self.activeCamera.up)
        #endif
        if self.drawNextFrame >= self.framerate {
        self.drawScene(self.world)
        // Make sure changes appear onscreen
       
       
            self.drawNextFrame = 0
        } else {
            self.drawNextFrame++
        }
        #if OPENGL_OSX
        RMXGLPostRedisplay()
        
        RMXGlutSwapBuffers()
         glFlush()
        #endif
        //tester.checks[1] = observer->toString();
        //NSLog([world.observer viewDescription]);
    }
    
}


extension RMXGLProxy {
    class func run(type: RMXWorldType){
        self.world = RMSWorld(worldType: type)
        self.actions = RMSActionProcessor(world: self.world)
        #if OPENGL_OSX
        RMXGLRun(Process.argc, Process.unsafeArgv)
        #endif
    }
    
    
    class func GetLastMouseDelta(inout dx:Int32 , inout dy:Int32 ) {
        #if OPENGL_OSX
        RMXCGGetLastMouseDelta(&dx,&dy)
        #endif
    }
    
    class func drawScene(parent: RMXNode){
        func shape(type: ShapeType, radius: RMFloat){
            switch (type) {
            case .CUBE:
                DrawCubeWithTextureCoords(Float(radius))
            case .SPHERE:
                RMXDrawSphere(Float(radius))
            case .PLANE:
                DrawPlane(Float(radius))
            default:
                DrawCubeWithTextureCoords(Float(radius))
                return
            }
        }
        
        for object in parent.children  {
            let position = object.position
            let radius = object.radius

            if object.isLight {
                #if SceneKit
                    RMXGLShine(object.shape.gl_light, object.shape.gl_light_type,SCNVector4ToGLKVector4(RMXVector4MakeWithVector3(position, 1)))
                    #else
                RMXGLShine(object.shape!.gl_light, object.shape!.gl_light_type, RMXVector4MakeWithVector3(position, 1))
                #endif
                
            }
            
            if object.isDrawable {
                glPushMatrix()
                RMXGLTranslatef(
                    Float(object.anchor.x),
                    Float(object.anchor.y),
                    Float(object.anchor.z)
                )
                RMXGLTranslatef(
                    Float(position.x),
                    Float(position.y),
                    Float(position.z)
                    )
                if object.isLight {
                    RMXGLMaterialfv(GL_FRONT, GL_EMISSION, object.shape!.color)
                } else {
                    RMXGLMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, object.shape!.color)
                    RMXGLMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, object.shape!.color)
//                    RMXGLMaterialfv(GL_FRONT_AND_BACK, GL_SHININESS, object.1.shape.color)
                }
                
                shape(object.shape!.type, radius)

                RMXGLMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, GLKVector4Zero);
                RMXGLMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, GLKVector4Zero);
                RMXGLMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, GLKVector4Zero);
//                RMXGLMaterialfv(GL_FRONT_AND_BACK, GL_SHININESS, RMXVector4Zero);
                
                self.drawScene(object)
                glPopMatrix();
            
            }
        }
        
    
    }
    
}