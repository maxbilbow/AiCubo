//
//  RMXGLut.swift
//  RattleGL
//
//  Created by Max Bilbow on 15/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation


import GLKit

@objc public class RMXGLProxy {
    //let world: RMXWorld? = RMXArt.initializeTestingEnvironment()
    static var callbacks: [()->Void] = Array<()->Void>()
    static var world: RMSWorld = RMX.buildScene()
    static var effect: GLKBaseEffect? = GLKBaseEffect()
    static var actions: RMSActionProcessor {
        return self.world.actionProcessor
    }
    
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
    
    static var activeSprite: RMSParticle {
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
        RepeatedKeys()
        self.world.animate()
    }
    
    class func performAction(action: String){
        self.actions.movement(action, speed: 0, point: [])
    }
    
    class func performActionWithSpeed(speed: Float, action: String){
        self.actions.movement(action, speed: speed, point: [])
    }


    class func performActionWith(point: [Float], action: String!, speed: Float){
        self.actions.movement(action, speed: speed, point: point)
    }

    
    class func initialize(world: RMSWorld, callbacks: ()->Void ...){
        self.world = world
        self.activeCamera.effect = self.effect
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
        
        RMXGLMakeLookAt(self.activeCamera.eye, self.activeCamera.center, self.activeCamera.up)
      
        if self.drawNextFrame >= self.framerate {
        self.drawScene()
        // Make sure changes appear onscreen
       
       
            self.drawNextFrame = 0
        } else {
            self.drawNextFrame++
        }
        RMXGLPostRedisplay()
        
        RMXGlutSwapBuffers()
         glFlush()
        //tester.checks[1] = observer->toString();
        //NSLog([world.observer viewDescription]);
    }
    
}


extension RMXGLProxy {
    class func run(){
        self.world = RMX.buildScene()
        RMXGLRun(Process.argc, Process.unsafeArgv)
    }
    
    
    class func GetLastMouseDelta(inout dx:Int32 , inout dy:Int32 ) {
        RMXCGGetLastMouseDelta(&dx,&dy)
    }
    
    class func drawScene(){

        func shape(type: ShapeType, radius: Float){
            switch (type) {
            case .CUBE:
                DrawCubeWithTextureCoords(radius)
            case .SPHERE:
                RMXDrawSphere(radius)
            case .PLANE:
                DrawPlane(radius)
            default:
                return
            }
        }
        
        for object in self.world.sprites  {
            let position = object.body.position
            let radius = object.body.radius

            if object.isLightSource {
                RMXGLShine(object.shape.gl_light, object.shape.gl_light_type, GLKVector4MakeWithVector3(position, 1))
                
            }
            
            if object.isDrawable {
                glPushMatrix()
                RMXGLTranslate(object.anchor)
                RMXGLTranslate(position)
                if object.isLightSource {
                    RMXGLMaterialfv(GL_FRONT, GL_EMISSION, object.shape.color)
                } else {
                    RMXGLMaterialfv(GL_FRONT, GL_SPECULAR, object.shape.color)
                    RMXGLMaterialfv(GL_FRONT, GL_DIFFUSE, object.shape.color)
                }
               
                shape(object.shape.type, radius)

                RMXGLMaterialfv(GL_FRONT, GL_EMISSION, RMXVector4Zero);
                RMXGLMaterialfv(GL_FRONT, GL_SPECULAR, RMXVector4Zero);
                RMXGLMaterialfv(GL_FRONT, GL_DIFFUSE, RMXVector4Zero);
                
                glPopMatrix();
            
            }
        }
        
    
    }
    
}