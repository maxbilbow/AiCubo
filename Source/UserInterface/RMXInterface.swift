//
//  RMXInterface.swift
//  RattleGLES
//
//  Created by Max Bilbow on 25/03/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
#if iOS
    import UIKit
    #elseif OSX
    import GLKit
#endif

class RMXInterface : NSObject {
    private let _isDebugging = false
    var debugData: String = "No Data"
//    #if OPENGL_ES
    var gvc: RMXViewController
//    #endif
    var world: RMSWorld {
        return self.gvc.gameView.world
    }
    
    var lookSpeed: Float = PI_OVER_180
    var moveSpeed: Float = 1
    
    var activeSprite: RMSParticle {
        return self.world.activeSprite
    }
    
    #if iOS
    var view: UIView {
        return self.gvc.gameView as! UIView
    }
    #else
    var view: NSObject {
        return self.gvc.gameView as NSObject
    }
    #endif

    var gameView: RMXView {
        return self.gvc.gameView
    }

    
    var controllers: [ String : ( isActive: Bool, process: ()->() ) ]
    
    var activeCamera: RMXCamera {
        return self.world.activeCamera
    }
    
    init(gvc: RMXViewController){
        self.gvc = gvc
//        self.actions = self.world.actions
        self.controllers = [ "debug" : ( isActive: _isDebugging,
            process: {
              
        } ) ]
        super.init()
        self.world.clock = RMXClock(world: world, interface: self)
        self.viewDidLoad()
    }
    
    func viewDidLoad(){
        self.controllers["debug"] = ( isActive: _isDebugging, process: self.debug )
        self.setUpGestureRecognisers()
    }

    func setUpGestureRecognisers() {
        
    }
    
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
    
        
    func update(){
        ///Includes debug()
        self.processControllers()
        self.world.animate()
    }
    
    ///Stop all inputs (i.e. no gestures received)
    ///@virtual
    func handleRelease(arg: AnyObject, args: AnyObject ...) { }


}