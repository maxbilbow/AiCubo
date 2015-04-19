//
//  RMXMouse.swift
//  RattleGL
//
//  Created by Max Bilbow on 15/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import GLKit
#if OPENGL_ES
    
    #elseif OPENGL_OSX
    
#endif

protocol RMXMouse {
    var x: Int32 {get}
    var y: Int32 {get}
    var hasFocus: Bool { get set }
    var speed: RMFloat { get set }
    func setMousePos(x: Int32, y:Int32)
    func mouse2view(x:Int32, y:Int32, speed: RMFloat)
    func toggleFocus()
//    func centerView(center: CFunctionPointer<(Int32, Int32)->Void>)
    func calibrateView(x: Int32, y:Int32)
}

class RMSMouse : RMXMouse{
    
    var parent: RMXNode
    var hasFocus = false
    var dx: Int32 = 0
    var dy: Int32 = 0
    var pos:(x:Int32, y:Int32) = ( x:0, y: 0 )
    var speed: RMFloat = 0.2

    var x: Int32 {
        return self.pos.x
    }
    
    var y: Int32 {
        return self.pos.y
    }
    
    init(parentNode parent: RMXNode){
        self.parent = parent
    }
    func toggleFocus()    {
        self.hasFocus = !self.hasFocus
        #if OPENGL_OSX
        if RMXGLProxy.mouse.hasFocus {
            RMGlutSetCursor(true)
            self.calibrateView(0, y:0)
            //self.mouse2view(0, y:0)
           
           
            
        }
        else {
            RMGlutSetCursor(false)
        }
        #endif
    }
    
    
    
    var position: RMXVector3 {
        #if OPENGL_OSX
            return RMXVector3Make(RMFloat(pos.x), RMFloat(pos.y), 0)
            #else
            return RMXVector3Zero
        #endif
        
    }

    
    func setMousePos(x: Int32, y:Int32) {
        self.pos.x = x// + dx;
        self.pos.y = y//;
    }
    
    func mouse2view(x:Int32, y:Int32, speed: RMFloat = PI_OVER_180) {
    //dx = dy = 0;
    
    
        var DeltaX: Int32 = 0; var DeltaY: Int32 = 0
    #if OPENGL_OSX
        RMXGLProxy.GetLastMouseDelta(&DeltaX, dy: &DeltaY)
        RMGLMouseCenter();
    #endif

        var dir: RMFloat = (self.hasFocus ? 1 : -1) * self.speed
    
        var theta: RMFloat = RMFloat(DeltaX) * dir
        var phi: RMFloat =   RMFloat(DeltaY) * dir// / 20.0f;
        
        self.parent.body!.addTheta(leftRightRadians: theta * speed)
        self.parent.body!.addPhi(upDownRadians:phi * -speed)
    
    }
    
    func calibrateView(x: Int32, y:Int32)    {
        #if OPENGL_OSX
//        RMXCGGetLastMouseDelta(&self.dx, &self.dy)
        RMGLMouseCenter();
        #endif
    }
    
}

