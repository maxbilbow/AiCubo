//
//  RMXViewController.swift
//  RattleGLES
//
//  Created by Max Bilbow on 26/03/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
import GLKit
import SceneKit
    
extension RMX {
#if iOS
    /* static func Controller(view: GameView, world: RMSWorld) -> RMXDPad {
        return RMXDPad(view: view, world: world)
    } */
    static func Controller(gvc: RMXViewController) -> RMXDPad {
        return RMXDPad(gvc: gvc)//.initialize(gvc, gameView: gvc.gameView) as! RMXDPad
    }
    #elseif OSX
    static func Controller(gvc: GameViewController, scene: SCNScene? = nil) -> RMSKeys {
        return RMSKeys(gvc: gvc, scene: scene)//.initialize(gvc, gameView: gvc.gameView) as! RMSKeys
    }
#endif
}

protocol RMXView {
    var world: RMSWorld? { get }
    var interface: RMXInterface? { get set }
    var gvc: RMXViewController? { get set }
    
    func initialize(gvc: RMXViewController, interface: RMXInterface)
}

protocol RMXViewController {
    
    var gameView: GameView? { get }
    var world: RMSWorld? { get }
    var interface: RMXInterface? { get set }
    
    #if iOS
        var view: UIView! { get set }
//        #elseif OPENGL_OSX
//        var view: NSOpenGLView! { get set }
    #endif

//    var interface: RMXInterface { get }


}



