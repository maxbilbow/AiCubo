//
//  RMXViewController.swift
//  RattleGL
//
//  Created by Max Bilbow on 18/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import OpenGL


class RMSView : NSView {
    var program: GLuint = 0
    private var _openGLContext: NSOpenGLContext
    var openGLContext: NSOpenGLContext {
        return _openGLContext
    }
    private var _pixelFormat: NSOpenGLPixelFormat
    var pixelFormat: NSOpenGLPixelFormat {
        return _pixelFormat
    }
    
    var scene: RMXWorld?
    var camera: RMXCamera? {
        return scene?.activeCamera
    }
    
    static var defaultPixelFormat: NSOpenGLPixelFormat! {
        RMXLog()
        return nil
    }
    init(frame frameRect: NSRect,  pixelFormat format:NSOpenGLPixelFormat) {
        _pixelFormat = format //retain?
        _openGLContext = NSOpenGLContext(format: format, shareContext: nil)!
        //NSNotificationCenter.addObserver(self, forKeyPath: "_surfaceNeedsUpdate:", options: NSViewGlobalFrameDidChangeNotification, context: _surfaceNeedsUpdate)
    
        
        super.init(frame: frameRect)
    }
    private func _surfaceNeedsUpdate(notification: NSNotification){
        self.update()
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setOpenGLContext(context: NSOpenGLContext){
        _openGLContext = context
    }
   
    func clearGLContext(){}
    
    func prepareOpenGL(){}
    
    func update(){
        if self.scene != nil {
            self.scene?.animate()
        }
    }
    
    func setPixelFormat(pixelFormat: NSOpenGLPixelFormat){
        _pixelFormat = pixelFormat
    }
    
    override func lockFocus() {
        let context = self.openGLContext
        super.lockFocus()
        if (context.view != self) {
            context.view = self
        }
        context.makeCurrentContext()
    }
    
    override func drawRect(dirtyRect: NSRect) {
        let context = self.openGLContext
        context.makeCurrentContext()
        
        //Perform drawing here
        
        context.flushBuffer()
    }
    
    override func viewDidMoveToWindow() {
        let context = self.openGLContext
        super.viewDidMoveToWindow()
        if self.window == nil {
            context.clearDrawable()
        }
    }
    
    /*
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT);
    drawAnObject();
    glFlush();
*/
}