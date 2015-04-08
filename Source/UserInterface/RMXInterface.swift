//
//  RMXInterface.swift
//  RattleGLES
//
//  Created by Max Bilbow on 25/03/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
    import GLKit
#if iOS
    import UIKit
    #elseif OSX

#endif

#if SceneKit
    import SceneKit
    typealias SceneObject = NSObject
    typealias RendererDelegate = SCNSceneRendererDelegate
    #else
    protocol RendererDelegate {}
    protocol SceneObject {}
    #endif

#if OPENGL_ES
    typealias RMSView = GLKView
    #elseif SceneKit
    typealias RMSView = SCNView
    #elseif iOS
    typealias RMSView = UIView
    #elseif OSX
    typealias RMSView = NSView
#endif

class RMXInterface : SceneObject, RendererDelegate {
    lazy var actionProcessor: RMSActionProcessor = RMSActionProcessor(world: self.world!)
    private let _isDebugging = false
    var debugData: String = "No Data"
    
    var gvc: RMXViewController?
    var gameView: GameView?
    
//    lazy var controllers: [ String : ( isActive: Bool, process: ()->() ) ] = [ "debug" : ( isActive: self._isDebugging,
//        process: {
//            
//    } ) ]
    
   
    
    var world: RMSWorld?

    var lookSpeed: RMFloatB = PI_OVER_180
    var moveSpeed: RMFloatB = 1
    
    var activeSprite: RMXNode? {
        return self.world?.activeSprite
    }
    
    #if iOS
    var view: UIView {
        return self.gvc!.gameView!
    }
    
    #elseif OPENGL_OSX
    var view: GameView {
        return self.gvc!.gameView!
    }
    #endif

    
    
    var activeCamera: RMXCamera? {
        return self.world?.activeCamera
    }
    
    init(gvc: RMXViewController, world: RMSWorld? = nil){
        self.gvc = gvc
        self.world = world
        #if SceneKit
        super.init()
        #endif
        self.initialize(gvc, gameView: gvc.gameView!, world: world)
        self.viewDidLoad()
        NSLog("\(__FUNCTION__)")
    }
    
    func initialize(gvc: RMXViewController?, gameView: GameView?, world: RMSWorld? = nil) -> RMXInterface {
        if gvc != nil {
            self.gvc = gvc
        }
        if gameView != nil {
            self.gameView = gameView
        }
        if world != nil {
            self.world = world
        }
        if self.world == nil {
            self.world = RMSWorld(worldType: .DEFAULT)
        }
        self.world!.clock = RMXClock(world: self.world!, interface: self)
        #if SceneKit
        self.gameView!.delegate = self
        #endif
        return self
    }
    
    
    func viewDidLoad(coder: NSCoder! = nil){
        #if SceneKit
        if coder != nil {
            self.world = RMSWorld(coder: coder)
        }
        #endif
        if self.world == nil {
            self.world = RMSWorld(worldType: .DEFAULT)
        }
//        self.controllers["debug"] = ( isActive: _isDebugging, process: self.debug )
        self.setUpGestureRecognisers()

    }
    
    func setUpGestureRecognisers() {
        
    }
    
    /*
    func setController(forKey key: String, run process: ()->() ) -> ( isActive: Bool, process: ()->() )? {
        let old = self.controllers.updateValue((isActive: false, process: process ), forKey: key)
        if old != nil {
           self.controllers[key]!.isActive = old!.isActive
        }
        return self.controllers[key]
    }

    func getController(forKey key: String) -> ( isActive: Bool, process: ()->() )? {
        return self.controllers[key]
    }

    func processControllers(){
        for controller in self.controllers {
            if controller.1.isActive {
                controller.1.process()
            }
        }
    }
*/

    func log(_ message: String = "", sender: String = __FUNCTION__, line: Int = __LINE__) {
        if _isDebugging {
            self.debugData += "  \(sender) on line \(line): \(message)"
        }
    }
    
    func debug() {
        if debugData != ""{
            println("\(debugData)")
//            self.log("\n x\(leftPanData.x.toData()), y\(leftPanData.y)",sender: "LEFT")
//            self.log("x\(rightPanData.x.toData()), y\(rightPanData.y.toData())",sender: "RIGHT")
        }
        debugData = ""
    }
    
    
    #if SceneKit
    func renderer(aRenderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        self.update()
    }
    #endif
    
    func update(){
        self.actionProcessor.animate()
        self.world?.animate()
    }
    
    ///Stop all inputs (i.e. no gestures received)
    ///@virtual
    func handleRelease(arg: AnyObject, args: AnyObject ...) { }

    func action(action: String = "reset",speed: RMFloatB = 0, point: [RMFloatB] = []) {
        self.actionProcessor.movement( action,speed: speed, point: point)
    }
}