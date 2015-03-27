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
    static var world: RMSWorld?
    static var effect: GLKBaseEffect? = GLKBaseEffect()
    static var actions: RMSActionProcessor?
    static var activeCamera: RMXCamera? {
        return self.world?.activeCamera
    }
    static var itemBody: RMSPhysicsBody? {
        return self.activeSprite?.actions?.item?.body
    }
    static var activeSprite: RMSParticle? {
        return self.world?.activeSprite
    }
    var displayPtr: CFunctionPointer<(Void)->Void>?
    var reshapePtr: CFunctionPointer<(Int32, Int32)->Void>?
    
    class func animateScene() {
        if self.world != nil {
            world?.animate()
        } else {
            fatalError("RMXWorld is nots set")
        }
        if RMX.usingDepreciated {
            DrawFog()
            RMXGLPostRedisplay()
        }
    }
    class func performAction(action: String!, speed: Float, point: [Float]){
        self.actions?.movement(action, speed: speed, point: point)
    }
    class func initialize(world: RMSWorld, callbacks: ()->Void ...){
        self.world = world
        self.activeCamera?.effect = self.effect
        for function in callbacks {
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
            self.world?.activeCamera?.makePerspective(width, height: height,effect: &self.effect)
            glMatrixMode(GLenum(GL_MODELVIEW))
        } else {
            self.world?.activeCamera!.viewHeight = Float(height)
            self.world?.activeCamera!.viewWidth = Float(width)
        }
        
        
    }

    
    class func display () -> Void {
        glClear(GLenum(GL_COLOR_BUFFER_BIT) | GLenum(GL_DEPTH_BUFFER_BIT))
        //glClearColor(art.r,art.g,art.b,art.k);
        glClearColor(0.8, 0.85, 1.8, 0.0)
        //[rmxDebugger add:RMX_DISPLAY_PROCESSOR n:@"DisplayProcessor" t:[NSString stringWithFormat:@"r%f, g%f, b%f, k%f",art.r,art.g,art.b,art.k]];
        glLoadIdentity(); // Load the Identity Matrix to reset our drawing locations
        if self.world?.activeCamera != nil {
            self.world?.activeCamera?.updateView()
        } else {
            fatalError("World Camera not initialised")
        }
        self.animateScene()
        for function in self.callbacks {
            function()
        }

        // Make sure changes appear onscreen
        RMXGlutSwapBuffers()
        glFlush()
        //tester.checks[1] = observer->toString();
        //NSLog([world.observer viewDescription]);
    }
    
        

}


extension RMXGLProxy {
    class func run(){
        RMXRun(Process.argc, Process.unsafeArgv)
    }
    
    class func setUpGL(){}
    
    class func GetLastMouseDelta(inout dx:Int32 , inout dy:Int32 ) {
        //RMXCLGetLastMouseDelta(dx,dy)
    }
    
}