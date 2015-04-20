//
//  GameView.swift
//  AiCubo
//
//  Created by Max Bilbow on 03/04/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
import GLUT

class GameView : RFOpenGLView, RMXView {
    
    var world: RMSWorld? {
        return self.interface?.world
    }
    
    var interface: RMXInterface?
    var gvc: RMXViewController?
    
    func initialize(gvc: RMXViewController, interface: RMXInterface) {
        self.gvc = gvc
        self.interface = interface
    }
    
    
    func setWorld(type: RMXWorldType){
        if self.world!.worldType != type {
            self.world!.setWorldType(worldType: type)
        }
    }
    
    var camera: RMXCamera {
        return self.world!.activeCamera
    }
    
    

    override required init(frame: CGRect) {
        super.init(frame: frame)
        self.viewDidLoad()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.viewDidLoad()
        
    }
    
    func viewDidLoad() {
//        self.context = EAGLContext(API:EAGLRenderingAPI.OpenGLES3)
//        self.drawableMultisample = GLKViewDrawableMultisample.Multisample4X
//        self.drawableDepthFormat = GLKViewDrawableDepthFormat.Format24
        RMXGLProxy.world = self.world
    }
    
    override func drawFrame() {
        super.drawFrame()
        RMXGLProxy.drawScene(self.world!)
    }
    override func animate() {
        super.animate()
        RMXGLProxy.animateScene()
    }
}